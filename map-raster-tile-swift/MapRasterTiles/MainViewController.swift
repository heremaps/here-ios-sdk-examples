/*
 * Copyright (c) 2011-2018 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit
import NMAKit

class MainViewController: UIViewController {

    @IBOutlet weak var segmentedCtrl: UISegmentedControl!
    @IBOutlet weak var mapView: NMAMapView!

    var imageSourceTile: NMAMapTileLayer? = nil
    var urlSourceTile: NMAMapTileLayer? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create an instance of URL raster tile source
        if urlSourceTile == nil {
            urlSourceTile = URLTileSource()
        }
        // Create an instance of Image raster tile source
        if imageSourceTile == nil {
            imageSourceTile = ImageTileSource()
        }
    }

    /**
     * Remove all tile layers which have been added to NMAMapView
     **/
    private func removeTileLayers() {
        for layer in mapView.mapTileLayers() {
            mapView.remove(mapTileLayer: layer)
        }
    }

    /**
     * Add NMAMapTileLayer when segmented control value changed.
     **/
    @IBAction func segmentedCtrlValueChanged(_ sender: Any) {
        switch self.segmentedCtrl.selectedSegmentIndex {
        case 0:
            self.removeTileLayers()
            if let tile = self.urlSourceTile {
                self.mapView.add(mapTileLayer: tile);
            }
        case 1:
            self.removeTileLayers()
            if let tile = self.imageSourceTile {
                self.mapView.add(mapTileLayer: tile);
            }
        default:
            print("Trigger not implemented")
        }
    }
}
