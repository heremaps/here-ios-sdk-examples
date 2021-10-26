//
// Copyright (C) 2017-2020 HERE Europe B.V.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import MSDKUI
import NMAKit
import UIKit

/// This example app shows how to build a simple navigation app using the
/// HERE Mobile SDK for iOS 3.9 (Premium) and the HERE Mobile SDK UI Kit v2.0.
/// Once a valid position is found the app will calculate a car route and start
/// navigation to HERE Berlin, Germany. The app shows a map view, a maneuver
/// view, the current driving speed and possible speed limits along the way.
///
/// Please note that this is just an app for demonstration.
/// Error handling is stripped down to bare minimum and edge cases like,
/// for example, leaving the route during navigation are not covered. The
/// focus of the app lies on the HERE Mobile SDK UI Kit v2.0 components. Feel
/// free to adapt the app to your needs. Have fun playing around with it.
class ViewController: UIViewController {

    @IBOutlet weak var mapView: NMAMapView!
    @IBOutlet weak var guidanceManeuverView: GuidanceManeuverView!
    @IBOutlet weak var guidanceSpeedView: GuidanceSpeedView!
    @IBOutlet weak var guidanceSpeedLimitView: GuidanceSpeedLimitView!

    private let geoCoordinatesOfHEREBerlin = NMAGeoCoordinates(latitude: 52.53102, longitude: 13.3848)
    private var coreRouter: NMACoreRouter!
    private var guidanceManeuverMonitor: GuidanceManeuverMonitor!
    private var guidanceSpeedMonitor: GuidanceSpeedMonitor!

    override func viewDidLoad() {
        super.viewDidLoad()

        customizeMapView()
        findCurrentPosition()
    }

    private func customizeMapView() {
        mapView.copyrightLogoPosition = NMALayoutPosition.bottomCenter
        mapView.positionIndicator.isVisible = true
        mapView.transformCenter = CGPoint(x: 0.5, y: 0.85)
        mapView.mapCenterFixedOnRotateZoom = true
        mapView.landmarksVisible = true
    }

    private func findCurrentPosition() {
        let positioningManager = NMAPositioningManager.sharedInstance()
        guard positioningManager.startPositioning() else {
            print("Error: Positioning failed to start.")
            return
        }

        // Subscribe to position updates.
        var token: NSObjectProtocol?
        token = NotificationCenter.default.addObserver(
            forName: .NMAPositioningManagerDidUpdatePosition,
            object: positioningManager,
            queue: OperationQueue.main) { _ in

                guard
                    let position = NMAPositioningManager.sharedInstance().currentPosition,
                    position.isValid,
                    let coordinates = position.coordinates else {
                        // Opt out until we get valid coordinates.
                        print("No position found.")
                        return
                }

                // Unsubscribe position updates. We want to start guidance only once.
                token.flatMap(NotificationCenter.default.removeObserver)

                self.calculateRoute(currentGeoCoordinates: NMAGeoCoordinates(
                    latitude: coordinates.latitude,
                    longitude: coordinates.longitude))
        }
    }

    private func calculateRoute(currentGeoCoordinates: NMAGeoCoordinates) {
        let startWaypoint = NMAWaypoint(geoCoordinates: currentGeoCoordinates)
        let destinationWaypoint = NMAWaypoint(geoCoordinates: geoCoordinatesOfHEREBerlin)
        let waypoints = [startWaypoint, destinationWaypoint]

        coreRouter = NMACoreRouter()
        coreRouter.calculateRoute(withStops: waypoints, routingMode: NMARoutingMode()) { routeResult, error in
            if error != NMARoutingError.none {
                print("Error: Routing failed. Maybe you are overseas?")
                return
            }

            guard let route = routeResult?.routes?.first else {
                print("Error: No route found.")
                return
            }

            self.setUpGuidanceViews(route: route)
            self.startGuidance(route: route)
        }
    }

    private func setUpGuidanceViews(route: NMARoute) {
        guidanceManeuverMonitor = GuidanceManeuverMonitor(route: route)
        guidanceManeuverMonitor.delegate = self
        customizeGuidanceManeuverView()

        guidanceSpeedMonitor = GuidanceSpeedMonitor()
        guidanceSpeedMonitor.delegate = self
        customizeCurrentSpeedView()
        customizeSpeedLimitView()

        guidanceManeuverView.isHidden = false
        guidanceSpeedView.isHidden = false
        guidanceSpeedLimitView.isHidden = false
    }

    private func customizeGuidanceManeuverView() {
        guidanceManeuverView.foregroundColor = .colorForeground
        guidanceManeuverView.backgroundColor = .colorBackgroundViewLight
    }

    private func customizeCurrentSpeedView() {
        guidanceSpeedView.layer.cornerRadius = guidanceSpeedView.bounds.height / 2
        guidanceSpeedView.textAlignment = .center
        setDefaultSpeedColors()
    }

    private func setDefaultSpeedColors() {
        guidanceSpeedView.backgroundColor = .colorBackgroundViewLight
        guidanceSpeedView.speedValueTextColor = .colorForeground
        guidanceSpeedView.speedUnitTextColor = .colorForeground
    }

    private func setOverspeedColors() {
        guidanceSpeedView.backgroundColor = .colorNegative
        guidanceSpeedView.speedValueTextColor = .colorBackgroundViewLight
        guidanceSpeedView.speedUnitTextColor = .colorBackgroundViewLight
    }

    private func customizeSpeedLimitView() {
        guidanceSpeedLimitView.layer.cornerRadius = guidanceSpeedLimitView.bounds.height / 2
        guidanceSpeedLimitView.layer.borderWidth = 4
        guidanceSpeedLimitView.layer.borderColor =
            UIColor(red: 208 / 255, green: 0, blue: 13 / 255, alpha: 1.0).cgColor
    }

    private func startGuidance(route: NMARoute) {
        mapView.add(mapObject: NMAMapRoute(route)!)
        NMANavigationManager.sharedInstance().map = mapView

        // Comment this out to start real guidance.
        enableGuidanceSimulation(route: route)
        NMANavigationManager.sharedInstance().startTurnByTurnNavigation(route)
    }

    private func enableGuidanceSimulation(route: NMARoute) {
        NMAPositioningManager.sharedInstance().stopPositioning()
        let dataSource = NMARoutePositionSource(route: route)
        dataSource.movementSpeed = 20.0 // 20 m/s
        NMAPositioningManager.sharedInstance().dataSource = dataSource
        NMAPositioningManager.sharedInstance().startPositioning()
    }
}

extension ViewController: GuidanceManeuverMonitorDelegate {
    func guidanceManeuverMonitor(_ monitor: GuidanceManeuverMonitor,
                                 didUpdateData data: GuidanceManeuverData?) {
        guidanceManeuverView.data = data
    }

    func guidanceManeuverMonitorDidReachDestination(_ monitor: GuidanceManeuverMonitor) {
        guidanceManeuverView.highlightManeuver(textColor: .colorAccentLight)
    }
}

extension ViewController: GuidanceSpeedMonitorDelegate {
    func guidanceSpeedMonitor(_ monitor: GuidanceSpeedMonitor,
                              didUpdateCurrentSpeed currentSpeed: Measurement<UnitSpeed>,
                              isSpeeding: Bool,
                              speedLimit: Measurement<UnitSpeed>?) {

        // Update the current speed view.
        guidanceSpeedView.speed = currentSpeed
        isSpeeding ? setOverspeedColors() : setDefaultSpeedColors()

        // Update the speed limit view.
        guidanceSpeedLimitView.speedLimit = speedLimit
        guidanceSpeedLimitView.isHidden = speedLimit == nil
    }
}
