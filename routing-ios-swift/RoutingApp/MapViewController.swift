/*
 * Copyright (c) 2011-2021 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit
import NMAKit
import CoreFoundation

// two Geo points for route.
let route = [
    NMAGeoCoordinates(latitude: 52.406425, longitude:13.193975),
    NMAGeoCoordinates(latitude: 52.638623, longitude:13.441998)
]

class ViewController: UIViewController {

    var coreRouter: NMACoreRouter!
    var mapRouts = [NMAMapRoute]()
    var progress: Progress? = nil
    
    @IBOutlet weak var mapView: NMAMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initValues()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        progress?.cancel()
    }

    /*
     Initialize CoreRouter and set center for map.
    */
    private func initValues() {
        coreRouter = NMACoreRouter()
        mapView.set(
            geoCenter: NMAGeoCoordinates(latitude: 52.406425, longitude:13.193975),
            zoomLevel: 10, animation: NMAMapAnimation.none
        )
    }
    
    @IBAction func clearMap(_ sender: UIButton) {
        // remove all routes from mapView.
        for route in mapRouts {
            mapView.remove(mapObject: route)
        }
        
        mapView.zoomLevel = 10
    }
    
    @IBAction func addRoute(_ sender: UIButton) {
        let routingMode = NMARoutingMode.init(
            routingType: NMARoutingType.fastest,
            transportMode: NMATransportMode.car,
            routingOptions: NMARoutingOption.avoidHighway
        )
        
        // check if calculation completed otherwise cancel.
        if !(progress?.isFinished ?? false) {
            progress?.cancel()
        }

        // Use banned areas if needed
        addBannedAreas(coreRouter);

        // store progress.
        progress = coreRouter.calculateRoute(withStops: route, routingMode: routingMode, { (routeResult, error) in
            if (error != NMARoutingError.none) {
                NSLog("Error in callback: \(error)")
                return
            }
            
            guard let route = routeResult?.routes?.first else {
                print("Empty Route result")
                return
            }
            
            guard let box = route.boundingBox, let mapRoute = NMAMapRoute.init(route) else {
                print("Can't init Map Route")
                return
            }
            
            if (self.mapRouts.count != 0) {
                for route in self.mapRouts {
                    self.mapView.remove(mapObject: route)
                }
                self.mapRouts.removeAll()
            }
            
            self.mapRouts.append(mapRoute)
    
            self.mapView.set(boundingBox: box, animation: NMAMapAnimation.linear)
            self.mapView.add(mapObject: mapRoute)
        })
    }

    private func addBannedAreas(_ router: NMACoreRouter) {
        // Example of usage banned areas API
        let dynamicPenalty = NMADynamicPenalty();

        // There are two options to avoid certain areas during routing,
        // 1. Add banned area using addBannedArea API

        let coordinates = [NMAGeoCoordinates(latitude:52.631692, longitude:13.437591),
            NMAGeoCoordinates(latitude:52.631905, longitude:13.437787),
            NMAGeoCoordinates(latitude:52.632577, longitude:13.438357)];

        let geoPolygon = NMAGeoPolygon(coordinates:coordinates);
        // Note, the maximum supported number of banned areas is 20.
        dynamicPenalty.addBannedArea(NMAMapPolygon(polygon: geoPolygon));


        // 2. Add banned road link using addPenaltyForRoadElement API
        // Note, map data needs to be present to get RoadElement by the GeoCoordinate.
        let roadElement = mapView.roadElement(at: NMAGeoCoordinates(latitude:52.406611, longitude:13.194916));
        if (roadElement != nil) {
            // use speed = 0 to completely exclude road link from routing
            dynamicPenalty.addPenalty(for:roadElement!,
                     drivingDirection:NMADrivingDirection.both,
                                    speed:0);
        }

        router.dynamicPenalty = dynamicPenalty;
    }

    @IBAction func didShowEnvZoneChange(_ sender: Any) {
        if (sender is UISwitch) {
            if ((sender as! UISwitch).isOn) {
                mapView.show(fleetFeature:NMAMapFleetFeatureType.environmentalZones)

            } else {
                mapView.hide(fleetFeature:NMAMapFleetFeatureType.environmentalZones)
            }
        }
    }
}
