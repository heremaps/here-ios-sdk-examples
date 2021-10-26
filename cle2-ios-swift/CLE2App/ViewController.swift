/*
 * Copyright (c) 2011-2020 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit
import NMAKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var mapView: NMAMapView!
    @IBOutlet weak var layerNameTextField: UITextField!
    @IBOutlet weak var searchRadiusSlider: UISlider!
    @IBOutlet weak var connectivityModeControl: UISegmentedControl!

    var geometries = [NMACLE2Geometry]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //create geo coordinate
        let geoCoordCenter = NMAGeoCoordinates(latitude: 49.260327, longitude: -123.115025)
        //set map view with geo center
        self.mapView.set(geoCenter: geoCoordCenter, animation: .none)
        //set zoom level
        self.mapView.zoomLevel = 13.2

        self.layerNameTextField.delegate = self
        self.connectivityModeControl.selectedSegmentIndex = 2
    }

    func clearMap() {
        self.geometries.removeAll()
        self.mapView.removeAllMapObjects()
    }

    func add(geometry : NMACLE2GeometryPoint) {
        self.geometries.append(geometry);

        let markerImage = NMAImage(uiImage: UIImage(named: "marker.png")!)
        let marker = NMAMapMarker(geoCoordinates: geometry.coordinates!, icon: markerImage!)
        self.mapView.add(mapObject: marker)
    }

    func displayDialog(title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert);
        let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }

// MARK: User actions

    /**
     * Download all layer data from remote storage
     */
    @IBAction func downloadButtonPressed(_ sender: Any) {
        self.clearMap()

        // create download layer task
        let task = NMACLE2DataManager.sharedInstance()?.downloadLayerTask(self.layerNameTextField.text!)

        // start downloading
        task?.start({ (result, error) in
            if (error != nil) {
                self.displayDialog(title: "Download error", message: error!.localizedDescription)
                return
            }

            let message = String(format:"%@ geometries downloaded.", result!.affectedItemCount)
            self.displayDialog(title: "Layer Download Completed", message: message)

            // now fetch geometry from local storage
            let task = NMACLE2DataManager.sharedInstance()?.fetchLocalLayersTask([self.layerNameTextField.text!])
            task?.start({ (array, error) in
                if (error != nil) {
                    self.displayDialog(title: "Download error", message: error!.localizedDescription)
                    return
                }

                for item in array! {
                    if let geometry = item as? NMACLE2GeometryPoint {
                        self.add(geometry: geometry)
                    }
                }
            })
        })
    }

    /**
    * Upload all layer data to remote storage
    */
    @IBAction func uploadButtonPressed(_ sender: Any) {
        // create upload layer task
        let task = NMACLE2DataManager.sharedInstance()?.uploadLayerTask(self.layerNameTextField.text!, withGeometries: self.geometries)

        // start uploading
        task?.start({ (result, error) in
            if (error != nil) {
                self.displayDialog(title: "Upload error", message: error!.localizedDescription)
                return
            }

            let message = String(format:"%@ geometries uploaded.", result!.affectedItemCount)
            self.displayDialog(title: "Layer Upload Completed", message: message)
        })
    }

    @IBAction func clearMapButtonPressed(_ sender: Any) {
        self.clearMap()
    }

    @IBAction func addGeometryButtonPressed(_ sender: Any) {
        // add some geometry to map using map center
        let point = NMACLE2GeometryPoint()
        point.coordinates = self.mapView.geoCenter
        self.add(geometry: point)
    }

    @IBAction func purgeLocalStoragePressed(_ sender: Any) {
        // create purge local storage task
        let task = NMACLE2DataManager.sharedInstance()?.purgeLocalStorageTask()

        // start purging
        task?.start({ (result, error) in
            if (error != nil) {
                self.displayDialog(title: "Purge error", message: error!.localizedDescription)
                return
            }

            let message = String(format:"%@ geometries purged.", result!.affectedItemCount)
            self.displayDialog(title: "Purge Local Storage Completed", message: message)
        })
    }

    /**
    * Demonstration of the proximity search feature.
    * Search for all geometries from the center of the map in the desired search radius.
    */
    @IBAction func searchPressed(_ sender: Any) {
        self.clearMap()

        let circle = NMAMapCircle(self.mapView.geoCenter, radius: Double(self.searchRadiusSlider.value))
        circle.fillColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.5)
        self.mapView.add(mapObject: circle)

        // create proximity search request using map center as center.
        let request = NMACLE2ProximityRequest(layer: self.layerNameTextField.text!,
                                              center: self.mapView.geoCenter,
                                              radius: Int(self.searchRadiusSlider.value))

        // set desired connectivity mode
        // if the connectivity mode is OFFLINE, the geometries will be searched in local storage,
        // otherwise in remote storage.
        switch self.connectivityModeControl.selectedSegmentIndex {
        case 0:
            request?.connectivityMode = .online;
        case 1:
            request?.connectivityMode = .offline;
        default:
            request?.connectivityMode = .automatic;
        }

        // execute the request
        request?.start({ (_, result, error) in
            if (error != nil) {
                self.displayDialog(title: "Search error", message: error!.localizedDescription)
                return
            }

            for item in result.geometriesArray! {
                if let geometry = item as? NMACLE2GeometryPoint {
                    self.add(geometry: geometry)
                }
            }

            let message = String(format:"%d geometries found.", result.geometriesArray!.count)
            self.displayDialog(title: "Search Completed", message: message)
        })
    }

// MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
