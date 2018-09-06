/*
 * Copyright (c) 2011-2018 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit
import NMAKit

class MainViewController: UIViewController {

    @IBOutlet weak var mapView: NMAMapView!
    @IBOutlet weak var label: UILabel!

    class Defaults {
        static let latitude = 61.494713
        static let longitude = 23.775360
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Change data source to HERE position data source
        NMAPositioningManager.sharedInstance().dataSource = NMAHEREPositionSource()

        // Set initial position
        let geoCoodCenter = NMAGeoCoordinates(latitude: Defaults.latitude,
                                              longitude: Defaults.longitude)
        mapView.set(geoCenter: geoCoodCenter, animation: .none)
        mapView.copyrightLogoPosition = .center

        // Set zoom level
        mapView.zoomLevel = NMAMapViewMaximumZoomLevel - 1

        // Subscribe to position updates
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MainViewController.didUpdatePosition),
                                               name: NSNotification.Name.NMAPositioningManagerDidUpdatePosition,
                                               object: NMAPositioningManager.sharedInstance())

        // Set position indicator visible. Also starts position updates.
        mapView.positionIndicator.isVisible = true
    }

    @objc func didUpdatePosition() {
        guard let position = NMAPositioningManager.sharedInstance().currentPosition,
              let coordinates = position.coordinates else {
            return
        }

        // Update label text based on received position.
        var text = " Type: \(position.source == NMAGeoPositionSource.indoor ? "Indoor" : position.source == NMAGeoPositionSource.systemLocation ? "System" : "Unknown")\n"
                   + "Coordinate: \(coordinates.latitude), \(coordinates.longitude)\n"
                   + "Altitude: \(coordinates.latitude)\n"

        if let buildingName = position.buildingName, let buildingId = position.buildingId {
            text += "Building: \(buildingName) \(buildingId)\n"
        }

        if let floorId = position.floorId {
            text += "Floor: \(floorId)"
        }

        label.text = text

        // Update position indicator position.
        mapView.set(geoCenter: coordinates, animation: .linear)
    }
}
