/*
 * Copyright (c) 2011-2020 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit
import NMAKit

class ViewController: UIViewController, NMATrafficManagerObserver {

    @IBOutlet weak var ttaExcluded: UILabel?
    @IBOutlet weak var ttaIncluded: UILabel?
    @IBOutlet weak var ttaDownloaded: UILabel?
    @IBOutlet weak var mapView: NMAMapView?
    
    var coreRouter: NMACoreRouter?
    weak var calculatedRoute: NMARoute?
    var mapRoute: NMAMapRoute?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Initialize a CoreRouter */
        coreRouter = NMACoreRouter()
    }
    
    func setTtaTime() {
        // get time that includes traffic
        guard let timeIncluded = calculatedRoute?.ttaIncludingTraffic(
            forSubleg: UInt(NMARouteSublegWhole))?.duration else {
            return
        }
        
        // get time without traffic
        guard let timeExcluded = calculatedRoute?.ttaExcludingTraffic(
            forSubleg: UInt(NMARouteSublegWhole))?.duration else {
                return
        }
        
        self.ttaExcluded?.text = "ttaExcluded: \(String(describing: timeExcluded))"
        self.ttaIncluded?.text = "ttaIncluded: \(String(describing: timeIncluded))"
    }
    
    func trafficDataDidFinish() {
        // when downloading of traffic is completed set it to label
        guard let timeDownloaded = calculatedRoute?.ttaUsingDownloadedTraffic(
            forSubleg: UInt(NMARouteSublegWhole))?.duration else {
                return
        }
        
        self.ttaDownloaded?.text = "ttaDownloaded: \(String(describing: timeDownloaded))"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NMATrafficManager.sharedInstance().remove(observer: self)
    }
    
    @IBAction func calculateRoute(_ sender: UIButton) {
        // for calculating traffic on the route
        let penalty = NMADynamicPenalty()
        penalty.trafficPenaltyMode = NMATrafficPenaltyMode.optimal
        coreRouter?.dynamicPenalty = penalty
        
        // create route
        let routeContainer = createRoute()
        
        coreRouter?.calculateRoute(withStops: routeContainer.plan, routingMode: routeContainer.mode,
                                   { (result, error) in
                                    // check error and unwrap route
                                    guard let route = result?.routes?.first, error == NMARoutingError.none else {
                                        return
                                    }
                                    
                                    // check if map object already exist
                                    if let tempMapRoute = self.mapRoute {
                                        self.mapView?.remove(mapObject: tempMapRoute)
                                    }
                                    
                                    // assign new route
                                    self.calculatedRoute = route
                                    // create map object from route
                                    guard let mapRoute = NMAMapRoute(route) else {
                                        return
                                    }
                                    
                                    self.mapView?.add(mapObject: mapRoute)
                                    self.mapView?.set(boundingBox: route.boundingBox!, animation: NMAMapAnimation.none)
                                    
                                    // request for downloading traffic for current route
                                    let manager = NMATrafficManager.sharedInstance()
                                    manager.requestTraffic(on: route)
                                    manager.add(observer: self)
                                    self.setTtaTime()
        })
    }
}
