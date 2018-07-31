/*
 * Copyright (c) 2011-2018 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit
import NMAKit

class MainViewController: UIViewController {

    @IBOutlet weak var segmentedCtrl: UISegmentedControl!
    @IBOutlet weak var mapView: NMAMapView!

    lazy var imageSourceTile: NMAMapTileLayer! = ImageTileSource()
    lazy var urlSourceTile: NMAMapTileLayer! = URLTileSource()

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
