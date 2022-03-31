/*
 * Copyright (c) 2011-2022 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit
import NMAKit
import CoreFoundation


class MainViewController: UIViewController {

    var ftcrRouter: NMAFTCRRouter!
    var mapRoute: NMAMapFTCRRoute?

    @IBOutlet weak var mapView: NMAMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set zoom level
        mapView.zoomLevel = 13

        // Initialize the NMAFTCRRouter
        ftcrRouter = NMAFTCRRouter.init()
    }

    private func createFTCRRoute() {

        // Create geo coordinates
        let startCoord = NMAGeoCoordinates(latitude: 52.484958, longitude: 13.376825)
        let endCoord = NMAGeoCoordinates(latitude: 52.4777, longitude: 13.3777)

        // Create waypoints
        let start = NMAWaypoint.init(geoCoordinates: startCoord)
        let end = NMAWaypoint.init(geoCoordinates: endCoord)

        // Create ftcr route options
        let routeOptions = NMAFTCRRouteOptions.init(routingType: .fastest, transportMode: .car)
        routeOptions.departureTime = Date()
        routeOptions.tunnelsAvoidance = .avoid

        // Initialize route plan with waypoints and options
        let routePlan = NMAFTCRRoutePlan.init(waypoints: [start, end], options: routeOptions)

        ftcrRouter.calculateRoute(withPlan: routePlan) { (routes: [NMAFTCRRoute]?, error: Error?) in

            // Check for calculation error
            if let routingError = error {
                print("Error: FTCR route calculation failed. %@", routingError.localizedDescription)
            }

            // Get the first calculated ftcr route
            guard let route = routes?.first else{
                print("Error: Returned empty results for ftcr route calculation")
                return
            }

            // Initialize map route with calculated route
            guard let bbox = route.boundingBox, let mapRoute = NMAMapFTCRRoute.init(route) else {
                print("Can't init NMAMapFTCRRoute")
                return
            }

            self.mapRoute = mapRoute

            // Add the calculated ftcr route onto the map
            self.mapView.add(mapObject: mapRoute)

            // In order to see the entire route, change the map view bounding box
            self.mapView.set(boundingBox: bbox, animation: .bow)
        }
    }

    @IBAction func createFTCRRouteButtonClicked(_ sender: UIButton) {

        // Clear map if previous result is still on the map
        if let mapRoute = self.mapRoute {
            self.mapView.remove(mapObject: mapRoute)
            self.mapRoute = nil
        }

        createFTCRRoute()
    }
}
