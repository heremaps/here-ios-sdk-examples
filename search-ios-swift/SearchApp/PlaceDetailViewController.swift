/*
 * Copyright (c) 2011-2021 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit
import NMAKit

class PlaceDetailViewController: UIViewController {

    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeLocationLabel: UILabel!

    var placeLink: NMAPlaceLink? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        Helper.showIndicator(onView: self.view)

        // Fire a PlaceDetail request on the NMAPlaceLink passed from the previous controller.
        self.placeLink?.detailsRequest().start ( { request, data, inError in
            Helper.hideIndicator()

            guard inError == nil else {
                print("Place request returns error with error code:\((inError! as NSError).code)")
                return
            }
            if request is NMAPlaceRequest {
                // Display the name and the location of the place.Additional place details info ca also
                // be
                // retrieved at this moment as well.Please refer to the HERE Mobile SDK for iOS API doc for
                // details.
                if let place = data as? NMAPlace {
                    self.placeNameLabel.text = place.name;
                }
                if let position = (data as? NMAPlace)?.location?.position {
                    self.placeLocationLabel.text = "Position: \(position.latitude), \(position.longitude)"
                }
            }
        })
    }
}
