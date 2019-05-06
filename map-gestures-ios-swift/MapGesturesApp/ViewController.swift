/*
 * Copyright (c) 2011-2019 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit
import NMAKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: NMAMapView!

    private var gestureMarker: NMAMapMarker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set current controller to be delegate of map view's gesture
        mapView.gestureDelegate = self

        //add image icon to show current positon, which can shows map view motion when gestures were applied
        guard let image = UIImage(named: "indicator") else { return }
        let indicatorMarker = NMAMapMarker(geoCoordinates: mapView.geoCenter, image: image)
        mapView.add(mapObject: indicatorMarker)
    }

    /**
     * helper function to show a message label when gesture was applied.
     */
    private func showMessage(_ message: String) {
        var frame = CGRect(x: 110, y: 200, width: 220, height: 120)

        let label = UILabel(frame: frame)
        label.backgroundColor = UIColor.groupTableViewBackground
        label.textColor = UIColor.blue
        label.text = message
        label.numberOfLines = 0

        let text = message as NSString
        let options : NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]

        let rect = text.boundingRect(with: frame.size,
                                     options: options,
                                     attributes: [NSAttributedString.Key.font :label.font],
                                     context: nil)

        frame.size = rect.size
        label.frame = frame

        self.view.addSubview(label)

        UIView.animate(withDuration: 2.0,
                       animations: { label.alpha = 0 })
                                   { _ in label.removeFromSuperview() }
    }
}

extension ViewController : NMAMapGestureDelegate {
    /**
     * callback when tap gesture occurred. It showed a image icon at location when tap gesture was applied.
     */
    func mapView(_ mapView: NMAMapView, didReceiveTapAt location: CGPoint) {

        // it showed a message label for tap gesture
        showMessage("Tap gesture")

        //calculate geoCoordinates of tap gesture
        guard let markerCoordinates = mapView.geoCoordinates(from: location) else { return }

        //it added a image icon to map view at location where tap gesture was applied.
        if gestureMarker == nil {
            let image = UIImage(named: "markerIcon")
            gestureMarker = NMAMapMarker(geoCoordinates: markerCoordinates, image: image!)
            mapView.add(mapObject: gestureMarker!)
        } else {
            gestureMarker?.coordinates = markerCoordinates
        }

        if let defaultHandler = mapView.defaultGestureHandler {
            defaultHandler.mapView!(mapView, didReceiveTapAt: location)
        }
    }

    /**
     * callback when pan gesture occurred. It showed a message when pan gesture was applied.
     */
    func mapView(_ mapView: NMAMapView, didReceivePan translation: CGPoint, at location: CGPoint) {
        showMessage("Pan gesture")
        if let defaultHandler = mapView.defaultGestureHandler {
            defaultHandler.mapView!(mapView, didReceivePan: translation, at: location)
        }
    }

    /**
     * callback when totation gesture occurred. It showed a message when rotation gesture was applied.
     */
    func mapView(_ mapView: NMAMapView, didReceiveRotation rotation: Float, at location: CGPoint) {
        showMessage("Rotation gesture")
        if let defaultHandler = mapView.defaultGestureHandler {
            defaultHandler.mapView!(mapView, didReceiveRotation: rotation, at: location)
        }
    }
}
