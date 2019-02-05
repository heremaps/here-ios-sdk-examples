/*
 * Copyright (c) 2011-2019 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit
import NMAKit
import CoreFoundation

// two Geo points for route.
let route = [
    NMAGeoCoordinates(latitude: 49.259149, longitude: -123.008555),
    NMAGeoCoordinates(latitude: 49.0736, longitude: -122.559549)
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
            geoCenter: NMAGeoCoordinates(latitude: 49.260327, longitude: -123.115025),
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
}
