/*
 * Copyright (c) 2011-2020 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit
import NMAKit

class ViewController: UIViewController, NMAMapDataPrefetcherListener {
    
    class Defaults {
        static let latitude = 49.260327
        static let longitude = -123.0
        static let zoomLevel : Float = 12.0
        
        static let hereBurnabyLatitude  = 49.264178
        static let hereBurnabyLongitude = -123.117542
        
        static let langleyLatitude  = 49.229185
        static let langleyLongitude = -123.094052
        
        static let defaultRadius: UInt = 600
    }
    
    // Initialize the NMACoreRouter
    private lazy var router = NMACoreRouter()
    private var route : NMARoute?
    private var mapRoute : NMAMapRoute?
    private var geoBoundingBox : NMAGeoBoundingBox?
    private var activityView = UIActivityIndicatorView(style: .medium)
    private let prefetcher = NMAMapDataPrefetcher.sharedInstance()
    @IBOutlet var mapView: NMAMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityView.hidesWhenStopped = true
        activityView.center = self.view.center
        self.view.addSubview(activityView)
        
        // set listener to fetch callbacks from data prefetcher
        prefetcher.addListener(self)
        
        let geoCoordCenter = NMAGeoCoordinates(latitude: Defaults.latitude,
                                               longitude: Defaults.longitude)
        // set map view with geo center
        mapView.set(geoCenter: geoCoordCenter, animation: .none)
        
        // set zoom level
        mapView.zoomLevel = Defaults.zoomLevel
    }
    
    // MARK: - Buttons action
    @IBAction func createRoute(_ sender: UIButton) {
        let hereBurnaby = NMAGeoCoordinates(latitude: Defaults.hereBurnabyLatitude,
                                            longitude: Defaults.hereBurnabyLongitude)
        
        let langley = NMAGeoCoordinates(latitude: Defaults.langleyLatitude,
                                        longitude: Defaults.langleyLongitude)
        
        let stops = [hereBurnaby, langley]
        
        let routingMode = NMARoutingMode(routingType: .fastest,
                                         transportMode: .car,
                                         routingOptions: NMARoutingOption.init(rawValue: 0))
        
        // Trigger the route calculation
        router.calculateRoute(withStops: stops ,
                              routingMode: routingMode)
        { [weak self] routeResult, error in
            guard error == .none else {
                self?.showMessage(title: "Error", message: "Can't create a route. Try again")
                return
            }
            
            guard let result = routeResult, let routes = result.routes, routes.count > 0 else {
                self?.showMessage(title: "Error", message: "Can't create a route. Try again")
                return
            }
            
            // Let's add the 1st result onto the map
            self?.route = routes[0]
            self?.updateMapRoute(with: self?.route)
        }
    }
    
    @IBAction func boundingBoxEstimate(_ sender: UIButton) {
        guard let boundingBox = self.mapView.boundingBox else {
            self.showMessage(title: "Error", message: "Can't get bounding box.")
            return
        }
        activityProcess()
        
        var error = NMAPrefetchRequestError.unknown
        prefetcher.estimateMapDataSizeForBoundingBox(boundingBox, error: &error)
        
        if error != .none {
            self.showMessage(title: "Error", message: "Can't estimate area. Error code: \(error.rawValue)")
            return
        }
    }
    
    @IBAction func boundingBoxFetch(_ sender: UIButton) {
        guard let boundingBox = self.mapView.boundingBox else {
            self.showMessage(title: "Error", message: "Can't get bounding box.")
            return
        }
        activityProcess()
        
        var error = NMAPrefetchRequestError.unknown
        prefetcher.fetchMapDataForBoundingBox(boundingBox, error: &error)
        
        if error != .none {
            self.showMessage(title: "Error", message: "Can't fetch area. Error code: \(error.rawValue)")
            return
        }
    }
    
    @IBAction func routeEstimate(_ sender: UIButton) {
        guard let route = self.route else {
            self.showMessage(title: "Error", message: "Route is nil, press on \"Create route\".")
            return
        }
        activityProcess()
        
        var error = NMAPrefetchRequestError.unknown
        prefetcher.estimateMapDataSizeForRoute(route, radius: Defaults.defaultRadius, error: &error)
        
        if error != .none {
            self.showMessage(title: "Error", message: "Can't estimate route. Error code: \(error.rawValue)")
            return
        }
        showRoute()
    }
    
    @IBAction func routeFetch(_ sender: UIButton) {
        guard let route = self.route else {
            self.showMessage(title: "Error", message: "Route is nil, press on \"Create route\".")
            return
        }
        activityProcess()
        
        var error = NMAPrefetchRequestError.unknown
        prefetcher.fetchMapDataForRoute(route, radius: Defaults.defaultRadius, error: &error)
        
        if error != .none {
            self.showMessage(title: "Error", message: "Can't fetch route. Error code: \(error.rawValue)")
            return
        }
        showRoute()
    }
    
    // MARK: - NMAMapDataPrefetcherListener
    func prefetcher(_ prefetcher: NMAMapDataPrefetcher, didEstimateSize dataSizeKB: Int,
                    forRequestId requestId: Int, withSuccess success: Bool) {
        if success {
            let message = dataSizeKB > 0 ? "Estimated size for this region is \(dataSizeKB) KB"
                : "This region is already fetched."
            showMessage(title: "Success", message: message)
            return
        }
        showMessage(title: "Error", message: "Estimation isn't success.")
    }
    
    // method calls, when your progress fetching(downloading) is over.
    func prefetcher(_ prefetcher: NMAMapDataPrefetcher, didUpdateProgress progress: Float,
                    forRequestId requestId: Int) {
        if progress == 1.0 {
            showMessage(title: "Success", message: "This region is fetched.")
        }
    }
    
    // MARK: - Route functions
    func showRoute() {
        if let route = self.route, let boundingBox = route.boundingBox {
            geoBoundingBox = boundingBox
            mapView.set(boundingBox: boundingBox, animation: .linear)
            return
        }
        self.showMessage(title: "Error", message: "Route is nil, try again.")
    }
    
    private func updateMapRoute(with route: NMARoute?) {
        // remove previously created map route from map
        if let previousMapRoute = mapRoute {
            mapView.remove(mapObject:previousMapRoute)
        }
        
        guard let unwrappedRoute = route else {
            return
        }
        
        mapRoute = NMAMapRoute(unwrappedRoute)
        _ = mapRoute.map{ mapView?.add(mapObject: $0) }
        showRoute()
    }
    
    //MARK: - UI Utility
    func activityProcess() {
        self.view.isUserInteractionEnabled = false
        activityView.startAnimating()
    }
    
    func showMessage(title: String, message: String) {
        activityView.stopAnimating()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        self.view.isUserInteractionEnabled = true
    }
}
