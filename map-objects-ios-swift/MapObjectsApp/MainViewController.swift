/*
 * Copyright (c) 2011-2022 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit
import NMAKit

class MainViewController: UIViewController {

    @IBOutlet weak private var mapView: NMAMapView!
    @IBOutlet weak private var segmentCtrl: UISegmentedControl!

    private var geoCoord : NMAGeoCoordinates!

    private var geoPolygon : NMAMapPolygon?
    private var geoPolyline : NMAMapPolyline?
    private var geoBox : NMAGeoBoundingBox?
    private var mapMarker : NMAMapMarker?
    private var mapCircle : NMAMapCircle?

    // Used for displaying the coordinates of draggable marker
    private var coordinatesUpdateView : UIView?
    private var coordinatesLabel : UILabel?

    // Identifiers for MapMarker event handlers
    private var mapMarkerMoveBeganEventHandlerId : Int = 0
    private var mapMarkerMoveEndedEventHandlerId : Int = 0
    private var mapMarkerMovedEventHandlerId : Int = 0

    private class Defaults {
        static let latitude = 52.500556
        static let longitude = 13.398889

        static let width : Float = 0.01
        static let height: Float = 0.01

        static let imageName = "cafe.png"
        static let radius = 250.0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //create geo coordinate
        geoCoord = NMAGeoCoordinates(latitude: Defaults.latitude,
                                     longitude: Defaults.longitude)
        // set map view with geo center
        mapView.set(geoCenter: geoCoord, animation: .none)
    }

    /**
     * remove map objects which were added to current active map view.
     */
    private func cleanup() {
        //if NMAMapPolygon map object alreasy exists, remove it from map view.
        _ = geoPolygon.map { mapView.remove(mapObject: $0) }
        geoPolygon = nil

        //if NMAMapPolyline map object alreasy exists, remove it from map view.
        _ = geoPolyline.map{ mapView.remove(mapObject: $0) }
        geoPolyline = nil

        //if NMAMapMarker map object alreasy exists, remove it from map view.
        _ = mapMarker.map{ mapView.remove(mapObject: $0) }
        mapMarker = nil
        removeMapMarkerEventHandlers()

        //if NMAMapCircle map object alreasy exists, remove it from map view.
        _ = mapCircle.map{ mapView.remove(mapObject: $0) }
        mapCircle = nil
    }

    /**
     * create a NMAMapPolygon object, then add it to current active map view.
     */
    private func createPolygon() {
        cleanup()

        //create a NMAGeoBoundingBox with center gec coordinates, width and hegiht in degrees.
        geoBox = NMAGeoBoundingBox(center: geoCoord,
                                    width: Defaults.width,
                                   height: Defaults.height)

        //create a NMAMapPolygon with bounding box's vertices.
        geoPolygon = geoBox.map{ NMAMapPolygon(vertices: [$0.topLeft,
                                                          $0.bottomLeft,
                                                          $0.bottomRight,
                                                          $0.topRight]) }

        //set fill color to be gray
        geoPolygon?.fillColor = UIColor.gray
        //set border line width in pixels
        geoPolygon?.lineWidth = 12
        //set line color to be red
        geoPolygon?.lineColor = UIColor.red
        //add this NMAMapPolygon to map view
        _ = geoPolygon.map{mapView.add(mapObject: $0)}
    }

    /**
     * create a NMAMapPolyline object, then add it to current active map view.
     */
    private func createPolyline() {
        cleanup()

        //create a NMAGeoBoundingBox with center gec coordinates, width and hegiht in degrees.
        geoBox = NMAGeoBoundingBox(center: geoCoord,
                                   width: Defaults.width,
                                   height: Defaults.height)

        //create a NMAGeoPolyline with bounding box's vertices.
        geoPolyline = geoBox.map{ NMAMapPolyline(vertices: [$0.topLeft,
                                                            $0.bottomLeft,
                                                            $0.bottomRight,
                                                            $0.topRight,
                                                            $0.topLeft]) }
        //set border line width in pixels
        geoPolyline?.lineWidth = 12;
        //set border line color to be red
        geoPolyline?.lineColor = UIColor.red
        //add NMAMapPolyline to map view
        _ = geoPolyline.map { mapView?.add(mapObject: $0) }
    }

    /**
     * create a NMAMapMarker object, then add it to current active map view.
     */
    private func createMapMarker() {
        cleanup()

        //create NMAImage with local cafe.png
        let markerImage = NMAImage(uiImage: UIImage(named: Defaults.imageName)!)
        //create NMAMapMarker located with geo coordinate and icon image
        mapMarker = markerImage.map{ NMAMapMarker(geoCoordinates: geoCoord, icon: $0) }
        //make marker able to receive dragging gesture from map
        mapMarker?.isDraggable = true
        //add view and handlers for *MarkerDrag* events:
        setupMapMarkerEventHandlers()
        //add NMAMapMarker to map view
        _ = mapMarker.map{ mapView.add(mapObject: $0) }
    }

    private func setupCoordinatesView()
    {
        let kCoordinatesViewHeight: CGFloat = 120.0
        let frame = CGRect.init(x: 0.0, y: 0.0, width: self.view.frame.size.width,
                                height: kCoordinatesViewHeight)
        createCoordinatesUpdateView(withFrame:frame)
        createCoordinatesLabel(withFrame:frame)
    }

    private func createCoordinatesUpdateView(withFrame frame: CGRect)
    {
        coordinatesUpdateView = UIView.init(frame: frame)
        coordinatesUpdateView?.backgroundColor = UIColor.white
        self.view.addSubview(coordinatesUpdateView!)

        coordinatesUpdateView?.translatesAutoresizingMaskIntoConstraints = false
        let coordinatesUpdateViewBindings: [String: Any] = ["coordinatesUpdateView": coordinatesUpdateView!]
        self.view.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[coordinatesUpdateView]-(0)-|",
                                           options: [], metrics: nil, views: coordinatesUpdateViewBindings))
        let updateViewVFCV = "V:|-(>=0)-[coordinatesUpdateView(\(frame.size.height))]-(0)-|"
        self.view.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: updateViewVFCV,
                                           options: [], metrics: nil, views: coordinatesUpdateViewBindings))
    }

    private func createCoordinatesLabel(withFrame frame: CGRect)
    {
        coordinatesLabel = UILabel.init(frame: frame)
        coordinatesLabel?.numberOfLines = 0
        coordinatesLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        coordinatesLabel?.text = "Make long press gesture on MapMarker to start dragging" +
        " then move finger to move marker to desired position."
        coordinatesUpdateView?.addSubview(coordinatesLabel!)

        coordinatesLabel?.translatesAutoresizingMaskIntoConstraints = false
        let coordinatesLabelBindings: [String: Any] = ["coordinatesLabel": coordinatesLabel!]
        coordinatesUpdateView?.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[coordinatesLabel]-(0)-|",
                                           options: [], metrics: nil, views: coordinatesLabelBindings))
        coordinatesUpdateView?.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[coordinatesLabel]-(0)-|",
                                           options: [], metrics: nil, views: coordinatesLabelBindings))
    }

    /**
     * Visualize the coordinates during the mapMarker drag event.
     * Only last dragged mapMarker event data is displayed.
     */
    private func updateLabelWith(_ coordinates: NMAGeoCoordinates?, event eventType: String) {
        let text = "\(eventType) :\n <latitude:\(coordinates!.latitude)," +
                                    " longitude:\(coordinates!.longitude)>"
        print(text);
        coordinatesLabel?.text = text
    }

    /**
     * Add view and handlers when first mapMarker is added.
     */
    private func setupMapMarkerEventHandlers() {
        setupCoordinatesView()

        /**
         * Add handlers for map events:
         * - NMAMapEventMarkerDragBegan,
         * - NMAMapEventMarkerDragged,
         * - NMAMapEventMarkerDragEnded.
         */
        mapMarkerMoveBeganEventHandlerId = mapView.respond(to: NMAMapEvent.markerDragBegan)
        { (_: NMAMapEvent, _ : NMAMapView, eventData: Any?  ) -> Bool in

            let mapMarkerFromEvent = eventData as! NMAMapMarker
            self.updateLabelWith(mapMarkerFromEvent.coordinates, event: "NMAMapEventMarkerDragBegan")
            return true
        }

        mapMarkerMoveEndedEventHandlerId = mapView.respond(to: NMAMapEvent.markerDragEnded)
        { (_: NMAMapEvent, _ : NMAMapView, eventData: Any?  ) -> Bool in

            let mapMarkerFromEvent = eventData as! NMAMapMarker
            self.updateLabelWith(mapMarkerFromEvent.coordinates, event: "NMAMapEventMarkerDragEnded")
            return true
        }

        mapMarkerMovedEventHandlerId = mapView.respond(to: NMAMapEvent.markerDragged)
        { (_: NMAMapEvent, _ : NMAMapView, eventData: Any?  ) -> Bool in
            let mapMarkerFromEvent = eventData as! NMAMapMarker
            self.updateLabelWith(mapMarkerFromEvent.coordinates, event: "NMAMapEventMarkerDragged")
            return true
        }
    }

    /**
     * Remove view and handlers when last mapMarker is removed.
     */
    private func removeMapMarkerEventHandlers() {
        /**
         * Remove handlers for map events:
         * - NMAMapEventMarkerDragBegan,
         * - NMAMapEventMarkerDragged,
         * - NMAMapEventMarkerDragEnded.
         */
        mapView.removeEventBlock(blockIdentifier: mapMarkerMoveBeganEventHandlerId)
        mapView.removeEventBlock(blockIdentifier: mapMarkerMoveEndedEventHandlerId)
        mapView.removeEventBlock(blockIdentifier: mapMarkerMovedEventHandlerId)

        coordinatesUpdateView?.removeFromSuperview()
        coordinatesUpdateView = nil
        coordinatesLabel = nil
    }

    /**
     * create a NMAMapCircel object, then add it to current active map view.
     */
    private func createCircle() {
        cleanup()

        //create NMAMapCircle located at geo coordiate and with radium in meters
        mapCircle = NMAMapCircle(geoCoord, radius: Defaults.radius)

        //set fill color to be gray
        mapCircle?.fillColor = UIColor.gray
        //set border line width.
        mapCircle?.lineWidth = 12;
        //set border line color to be red.
        mapCircle?.lineColor = UIColor.red
        //add Map Circel to map view
        _ = mapCircle.map{ mapView.add(mapObject: $0) }
    }

    /**
     * create an appropriate map object when clicking segment control
     */
    @IBAction func segmentedCtrlPressed(_ sender: Any) {
        switch segmentCtrl.selectedSegmentIndex {
        case 0:
            createPolygon()
        case 1:
            createPolyline()
        case 2:
            createCircle()
        case 3:
            createMapMarker()
        default:
            break
        }
    }

}
