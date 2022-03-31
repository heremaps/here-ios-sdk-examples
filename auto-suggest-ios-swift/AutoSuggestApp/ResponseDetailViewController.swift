/*
 * Copyright (c) 2011-2022 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit
import NMAKit

class ResponseDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var autoSuggests:NMAAutoSuggest!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var responseDescription: UILabel!

    var searchResultData = [NMALink]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // perform detail request for these types of autoSuggest
        if let place = autoSuggests as? NMAAutoSuggestPlace {
            place.placeDetailsRequest().start({ request, data, inError in

                guard inError == nil else {
                    print("placeDetailsRequest returns error with error code:\((inError! as NSError).code)")
                    return
                }

                let response:NMAPlace = data as! NMAPlace
                var lableText = String(format:"name: %@", response.name ?? "")
                lableText = String(format:"%@\nAlternative names:", lableText)

                for (key, val) in response.alternativeNames ?? [:] {
                    lableText = String(format:"%@\n%@=%@", lableText, key, val)
                }

                self.responseDescription.text = lableText

            })
        } else if let searchRequest = autoSuggests as? NMAAutoSuggestSearch {
            tableView.isHidden = false
            tableView.dataSource = self

            searchRequest.suggestedSearchRequest().start({ request, data, inError in
                guard inError == nil else {
                    print("suggestedSearchRequest returns error with error code:\((inError! as NSError).code)")
                    return
                }
                
                if let page = data as? NMADiscoveryPage {
                    self.searchResultData = page.discoveryResults
                    self.tableView.reloadData()
                }
            })
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier:"cell")
        if cell == nil {
            cell = UITableViewCell(style:.subtitle, reuseIdentifier:"cell")
        }

        cell?.textLabel?.numberOfLines = 1
        cell?.detailTextLabel?.numberOfLines = 5
        cell?.textLabel?.sizeToFit()

        let item = searchResultData[indexPath.row]
        cell?.textLabel?.text = String(format:"Name:%@", item.name ?? "")

        if let placeLink = item as? NMAPlaceLink {
            var text = String(format:"Vicinity:%@", placeLink.vicinityDescription ?? "")
            text = String(format:"%@\nCategory:%@", text, placeLink.category?.name ?? "")
            text = String(format:"%@\nDistance:%ld", text, placeLink.distance)
            cell?.detailTextLabel?.text = text
        }

        return cell!
    }
}
