/*
 * Copyright (c) 2011-2021 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit
import NMAKit

class ViewController: UIViewController {

    let address = "4350 Still Creek Dr,Burnaby"
    let searchCenter = NMAGeoCoordinates(latitude: 49.266787, longitude: -123.056640)
    let searchRadius = 5000
    
    var position: NMAGeoCoordinates?

    @IBOutlet weak var reverseGeocodeBtn: UIButton!
    @IBOutlet weak var geocodeBtn: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reverseGeocodeBtn.layer.cornerRadius = 4
        geocodeBtn.layer.cornerRadius = 4
    }

    func parseResultFromReverseGeocodeRequest(request: NMARequest?, requestData data: Any?, error: Error?) {
        reverseGeocodeBtn.isEnabled = true

        if error != nil {
            print("error \(error!.localizedDescription)")
            return
        }
        
        if (!(request is NMAReverseGeocodeRequest)) {
            print("invalid type returned")
            return
        }
        
        guard let arr = data as? NSArray, arr.count != 0 else {
            return
        }
        
        if let address = (arr.object(at: 0) as? NMAReverseGeocodeResult)?.location?.address?.formattedAddress {
            locationLabel.text = address
        }
    }
    
    func parseResultFromGeocodeRequest(request: NMARequest?, requestData data: Any?, error: Error?) {
        geocodeBtn.isEnabled = true
        
        if error != nil {
            print("error \(error!.localizedDescription)")
            return
        }
        
        if (!(request is NMAGeocodeRequest)) {
            print("invalid type returned")
            return
        }
        
        guard let arr = data as? NSArray, arr.count != 0 else {
            return
        }
        
        if let tempPosition = (arr.object(at: 0) as? NMAGeocodeResult)?.location?.position {
            position = tempPosition
            locationLabel.text = "Lat: \(tempPosition.latitude) \n Long: \(tempPosition.longitude)"
        }
    }
    
    @IBAction func clickOnGeocodeBtn(_ sender: UIButton) {
        sender.isEnabled = false
        NMAGeocoder.sharedInstance().createGeocodeRequest(query: address, searchRadius: searchRadius, searchCenter: searchCenter).start(
            parseResultFromGeocodeRequest(request:requestData:error:)
        )
    }
    
    @IBAction func clickOnReverseGeocodeBtn(_ sender: UIButton) {
        guard let tempPosition = position else {
            locationLabel.text = "please first decode location"
            return
        }
        
        sender.isEnabled = false
        NMAGeocoder.sharedInstance().createReverseGeocodeRequest(coordinates: tempPosition).start(
            parseResultFromReverseGeocodeRequest(request:requestData:error:)
        )
    }
}
