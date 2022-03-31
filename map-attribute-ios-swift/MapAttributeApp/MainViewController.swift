/*
 * Copyright (c) 2011-2022 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit
import NMAKit

class MainViewController: UIViewController, SettingsViewControllerDelegate {

    @IBOutlet weak var mapView: NMAMapView!

/**
 * Notifies the view controller that a segue is about to be performed
 **/
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // navigate to SettingsViewController
    if segue.identifier == "Settings", let settingsController =
        (segue.destination as? UINavigationController)?.viewControllers.first as? SettingsViewController {
            // Set current view controller to be SettingsViewController's delegate
            settingsController.delegate = self
            // It shows current selections of map view's map scheme, transit display mode and whether
            // traffic is visible in settings.
            settingsController.mapScheme = self.mapView.mapScheme
            settingsController.transitDisplayMode = self.mapView.transitDisplayMode

            // If traffic is visible, it turns on/off traffic layer switch in settings
            if self.mapView.isTrafficVisible {
                if self.mapView.isTrafficLayerVisible(NMATrafficLayer.flow) {
                    settingsController.trafficLayers ^= NMATrafficLayer.flow.rawValue
                }
                if self.mapView.isTrafficLayerVisible(NMATrafficLayer.incidents) {
                    settingsController.trafficLayers ^= NMATrafficLayer.incidents.rawValue
                }
            }
    }
}

/**
 * Apply all the selections of map attributes from settings view to current map view.
 **/

 func applySettings(_ controller: SettingsViewController) -> Void {
    // set current map view's scheme
    self.mapView.mapScheme = controller.mapScheme
    // If traffic layers are selected, then turn on traffic visible and set traffic layers

    let layers: Int = controller.trafficLayers
    self.mapView.isTrafficVisible = layers > 0
    if layers > 0 {
        (layers & NMATrafficLayer.flow.rawValue != 0)
            ? self.mapView.show(trafficLayers: NMATrafficLayer.flow)
            : self.mapView.hide(trafficLayers: NMATrafficLayer.flow)

        (layers & NMATrafficLayer.incidents.rawValue != 0)
            ? self.mapView.show(trafficLayers: NMATrafficLayer.incidents)
            : self.mapView.hide(trafficLayers: NMATrafficLayer.incidents)
    }

    // Set selected transit display mode.
    self.mapView.transitDisplayMode = controller.transitDisplayMode ?? NMAMapTransitDisplayMode.nothing
}

    func settingsViewControllerDidCancel(_ controller: SettingsViewController) {
        self.dismiss(animated: true, completion: nil)
    }

    func settingsViewControllerDidDone(_ controller: SettingsViewController) {
        self.applySettings(controller);
        self.dismiss(animated: true, completion: nil)
    }
}

