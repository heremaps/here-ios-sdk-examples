/*
 * Copyright (c) 2011-2018 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit
import NMAKit

class ResultTableViewController: UITableViewController {

    @IBOutlet var resultTableView: UITableView!

    @IBOutlet weak var backButton: UIBarButtonItem!
    // Array that stores the search result from MapViewController
    var resultsArray: [NMALink] = []

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "tableCell")

        // Display vicinity information of each NMAPlaceLink item.Please refer to HERE iOS SDK API
        // doc for all supported APIs.
        let link = self.resultsArray[indexPath.row];
        if link is NMAPlaceLink {
            cell.textLabel?.text = (link as! NMAPlaceLink).vicinityDescription;
        }
        else if (link is NMADiscoveryLink) {
            cell.textLabel?.text = "This is a DiscoveryLink";
        }
        return cell;
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "PlaceDetailView") {
            guard let indexPath = self.resultTableView.indexPathForSelectedRow else {return}
            let placeDetailViewController = segue.destination as! PlaceDetailViewController
            // Pass the selected NMAPlaceLink object to the next view controller for retrieving place
            // details.
            let link = self.resultsArray[indexPath.row]
            if link is NMAPlaceLink {
                placeDetailViewController.placeLink = link as? NMAPlaceLink;
            } else {
                Helper.show("The item selected is a DiscoveryLink", onView: self.view)
            }
        }
    }
    @IBAction func onBackButtonClicked(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
