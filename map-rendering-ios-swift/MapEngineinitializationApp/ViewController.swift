/*
 * Copyright (c) 2011-2020 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit
import NMAKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: NMAMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        //create geo coordinate
        let geoCoordCenter = NMAGeoCoordinates(latitude: 49.260327, longitude: -123.115025)
        //set map view with geo center
        self.mapView.set(geoCenter: geoCoordCenter, animation: .none)
        //set zoom level
        self.mapView.zoomLevel = 13.2;
    }
}
