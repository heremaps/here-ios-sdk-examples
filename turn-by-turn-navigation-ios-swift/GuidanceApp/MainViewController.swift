/*
 * Copyright (c) 2011-2019 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit
import NMAKit

class MainViewController: UIViewController {

    class Defaults {
        static let latitude = 49.260327
        static let longitude = -123.115025
        static let zoomLevel : Float = 13.2

        static let hereBurnabyLatitude  = 49.259149
        static let hereBurnabyLongitude = -123.008555

        static let langleyLatitude  = 49.0736
        static let langleyLongitude = -122.559549

        static let frame = CGRect(x: 110, y: 200, width: 220, height: 120)

        static let durationInterval = 3.0
    }

    @IBOutlet weak var mapView: NMAMapView!
    @IBOutlet weak var navigationControlButton: UIButton!

    // Initialize the NMACoreRouter
    private lazy var router = NMACoreRouter()

    // Get the NavigationManager instance.It is responsible for providing voice and visual
    // instructions while driving and walking.
    private lazy var navigationManager = NMANavigationManager.sharedInstance()

    private var route : NMARoute?
    private var geoBoundingBox : NMAGeoBoundingBox?

    override func viewDidLoad() {
        super.viewDidLoad()
        // create geo coordinate
        let geoCoordCenter = NMAGeoCoordinates(latitude: Defaults.latitude,
                                               longitude: Defaults.longitude)

        // set map view with geo center
        mapView.set(geoCenter: geoCoordCenter, animation: .none)

        // set zoom level
        mapView.zoomLevel = Defaults.zoomLevel

        navigationControlButton.setTitle("Start Navigation", for: .normal)
        navigationControlButton.titleLabel?.adjustsFontSizeToFitWidth = true

        // Set this controller to be the delegate of NavigationManager, so that it can listening to the
        // navigation events through the different protocols.In this example, we will
        // implement 2 protocol methods for demo purpose, please refer to HERE iOS SDK API documentation
        // for details
        navigationManager.delegate = self
        navigationManager.isSpeedWarningEnabled = true
    }

    @IBAction func navigationControlButton(_ sender: Any) {
        // To start a turn-by-turn navigation, a concrete route object is required.We use same steps
        // from Routing sample app to create a route from 4350 Still Creek Dr to Langley BC without
        // going on HWY
        // The route calculation requires local map data.Unless there is pre-downloaded map
        // data on device by utilizing MapLoader APIs,it's not recommended to trigger the
        // route calculation immediately after the MapEngine is initialized.The
        // NMARoutingErrorInsufficientMapData error code may be returned by CoreRouter in this case.

        if self.route == nil {
            createRoute()
            return
        }

        navigationManager.stop()

        if !(NMAPositioningManager.sharedInstance().dataSource is NMADevicePositionSource) {
            NMAPositioningManager.sharedInstance().dataSource = nil
        }

        // Restore the map orientation to show entire route on screen
        self.geoBoundingBox.map{ mapView.set(boundingBox: $0, animation: .linear) }
        mapView.orientation = 0
        self.enableMapTracking(false)
        navigationControlButton.setTitle("Start Navigation", for: .normal)

        route = nil;
    }

    private func createRoute() {
        // Create an NSMutableArray to add two stops
        var stops = [Any]()

        // START: 4350 Still Creek Dr
        let hereBurnaby = NMAGeoCoordinates(latitude: Defaults.hereBurnabyLatitude,
                                            longitude: Defaults.hereBurnabyLongitude)

        // END: Langley BC
        let langley = NMAGeoCoordinates(latitude: Defaults.langleyLatitude,
                                        longitude: Defaults.langleyLongitude)

        stops.append(hereBurnaby)
        stops.append(langley)

        // Create an NMARoutingMode, then set it to find the fastest car route without going
        // on Highway.
        let routingMode = NMARoutingMode(routingType: .fastest,
                                         transportMode: .car,
                                         routingOptions: .avoidHighway)

        // Trigger the route calculation
        self.router.calculateRoute(withStops: stops ,
                                   routingMode: routingMode)
        { routeResult, error in
            guard error == .none else {
                self.showMessage("Error:route calculation returned error code \(error.rawValue)")
                return;
            }

            guard let result = routeResult, let routes = result.routes, routes.count > 0 else {
                self.showMessage("Error:route result returned is not valid")
                return
            }

            // Let's add the 1st result onto the map
            self.route = routes[0]
            let mapRoute = NMAMapRoute(routes[0])
            mapRoute?.traveledColor = .clear
            _ = mapRoute.map{ self.mapView.add(mapObject: $0) }

            // In order to see the entire route, we orientate the
            // map view accordingly
            if let boundingBox = self.route?.boundingBox {
                self.geoBoundingBox = boundingBox
                self.mapView.set(boundingBox: boundingBox, animation: .linear)
                self.startNavigation()
            }
        }
    }

    private func startNavigation() {
        navigationControlButton.setTitle("Stop Navigation", for: .normal)
        // Display the position indicator on map
        mapView?.positionIndicator.isVisible = true
        // Configure NavigationManager to launch navigation on current map
        navigationManager.map = mapView

        let alert = UIAlertController(title: "Choose Navigation mode",
                                      message: "Please choose a mode",
                                      preferredStyle: .alert)

        //Add Buttons

        let deviceButton = UIAlertAction(title: "Navigation",
                                         style: .default) { _ in

            guard let route = self.route else {
                return
            }

            // Start the turn-by-turn navigation.Please note if the transport mode of the passed-in
            // route is pedestrian, the NavigationManager automatically triggers the guidance which is
            // suitable for walking.
            self.startTurnByTurnNavigation(with: route, useSimulation: false)
        }

        let simulateButton = UIAlertAction(title: "Simulation",
                                           style: .default) { _ in

            guard let route = self.route else {
                return
            }

            self.startTurnByTurnNavigation(with: route, useSimulation: true)
        }

        alert.addAction(deviceButton)
        alert.addAction(simulateButton)

        present(alert, animated: true, completion: nil)
    }

    private func showMessage(_ message: String) {
        let label = UILabel(frame: Defaults.frame)
        label.backgroundColor = UIColor.groupTableViewBackground
        label.textColor = UIColor.blue
        label.text = message
        label.numberOfLines = 0;

        let text = label.text! as NSString
        let rect = text.boundingRect(with: Defaults.frame.size,
                                      options: [.usesLineFragmentOrigin, .usesFontLeading],
                                      attributes: [NSAttributedString.Key.font : label.font],
                                      context: nil)
        var frame = Defaults.frame
        frame.size = rect.size
        label.frame = frame

        view.addSubview(label)

        UIView.animate(withDuration: Defaults.durationInterval, animations: {
            label.alpha = 0
        }) { _ in
            label.removeFromSuperview()
        }
    }

    private func enableMapTracking(_ enabled: Bool) {
        navigationManager.mapTrackingAutoZoomEnabled = enabled
        navigationManager.mapTrackingEnabled = enabled
    }

    private func startTurnByTurnNavigation(with route: NMARoute, useSimulation: Bool) {
        if let error = self.navigationManager.startTurnByTurnNavigation(route) {
            self.showMessage("Error:start navigation returned error code \(error._code)")
        } else {
            // Set the map tracking properties
            self.enableMapTracking(true)
            if useSimulation {
                // Simulation navigation by init the PositionSource with route and set movement speed
                let source = NMARoutePositionSource(route: route)
                source.movementSpeed = 60
                NMAPositioningManager.sharedInstance().dataSource = source
            }
        }
    }
}

extension MainViewController : NMANavigationManagerDelegate {
    // Signifies that there is new instruction information available
    func navigationManager(_ navigationManager: NMANavigationManager, didUpdateManeuvers currentManeuver: NMAManeuver?, _ nextManeuver: NMAManeuver?) {
        showMessage("New maneuver is available")
    }

    // Signifies that the system has found a GPS signal
    func navigationManagerDidFindPosition(_ navigationManager: NMANavigationManager) {
        showMessage("New position has been found")
    }
}
