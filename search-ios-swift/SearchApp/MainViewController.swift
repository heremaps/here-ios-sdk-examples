/*
 * Copyright (c) 2011-2022 HERE Europe B.V.
 * All rights reserved.
 */

import NMAKit

class MainViewController: UIViewController {

    @IBOutlet weak var requestControl: UISegmentedControl!
    @IBOutlet weak var mapView: NMAMapView!
    @IBOutlet weak var resultListButton: UIButton!

    var mapObjectsArray = [NMAMapObject]()
    var resultsArray: [NMALink] = []
    var requestCompletion: NMARequestCompletionBlock!

    override func viewDidLoad() {
        super.viewDidLoad()
        // create geo coordinate
        let geoCoordCenter = NMAGeoCoordinates(latitude: 49.260327, longitude: -123.115025)
        // set map view with geo center
        self.mapView.set(geoCenter: geoCoordCenter, animation:NMAMapAnimation.none)
        // set zoom level
        self.mapView.zoomLevel = 13.2
        self.requestControl.selectedSegmentIndex = UISegmentedControl.noSegment
        self.resultListButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.view.bringSubviewToFront(self.resultListButton)
        self.resultListButton.isHidden = true;

        // Initialize a request completion
        self.requestCompletion = {[weak self] request, data, inError in
            guard inError == nil else {
                print ("discovery request error \((inError! as NSError).code)")
                return
            }
            guard data is NMADiscoveryPage, let resultPage = data as? NMADiscoveryPage else {
                print ("invalid type returned \(String(describing: data))")
                return
            }
            if let strongSelf = self {
                strongSelf.resultListButton.isHidden = false
                Helper.hideIndicator()

                // The result is a DiscoveryResultpage object which represents a paginated collection of
                // items.The items can be either a PlaceLink or DiscoveryLink.The PlaceLink can be used to
                // retrieve place details by firing another PlaceRequest,while the DiscoveryLink is designed
                // to be used to fire another DiscoveryRequest to obtain more refined results.
                strongSelf.resultsArray = resultPage.discoveryResults;
                for link in strongSelf.resultsArray
                {
                    // Add a marker for each result of PlaceLink type.For best usability, map can be also
                    // adjusted to display all markers.This can be done by merging the bounding box of each
                    // result and then zoom the map to the merged one.
                    if let placeLink = link as? NMAPlaceLink {
                        strongSelf.addMarkerAtPlace(placeLink);
                    }
                }
            }
        }

    }

    @IBAction func handleRequestControl(_ sender: Any) {
        // Trigger the request
        self.cleanMap()
        switch self.requestControl.selectedSegmentIndex {
            case 0:
                self.triggerAroundRequest()
            case 1:
                self.triggerExploreRequest()
            case 2:
                self.triggerHereRequest()
            case 3:
                self.triggerSearchRequest()
            default:
                print("Trigger not implemented")
        }
        Helper.showIndicator(onView: self.view)
    }

    func triggerSearchRequest ()
    {
        // Trigger a SearchRequest based on the current map center and search query "Hotel".Please refer
        // to HERE Mobile SDK for iOS API doc for other supported location parameters and categories
        let searchRequest = NMAPlaces.sharedInstance()?.createSearchRequest(location: self.mapView.geoCenter, query: "Hotel")

        if let error = searchRequest?.start(self.requestCompletion) as NSError? {
            Helper.show("Error:search request fired with error code \(error.code)", onView: self.view)
            Helper.hideIndicator()
        }
    }

    func triggerHereRequest() {
        // Trigger a HereRequest based on the current map center.Please refer to HERE Mobile SDK for iOS API
        // doc for othe supported location parameters and categories.
        let hereRequest = NMAPlaces.sharedInstance()?.createHereRequest(location: self.mapView.geoCenter, filters: nil)
        if let error = hereRequest?.start(self.requestCompletion) as NSError? {
            Helper.show("Error:here request fired with error code \(error.code)", onView: self.view)
            Helper.hideIndicator()
        }
    }

    func triggerExploreRequest() {
        // Trigger an ExploreRequest based on the bounding box of the current map and the filter for
        // Shopping category.Please refer to HERE Mobile SDK for iOS API doc for other supported location
        // parameters and categories
        let filter = NMACategoryFilter()
        filter.add(fromUniqueId: "shopping")
        let exploreRequest = NMAPlaces.sharedInstance()?.createExploreRequest(location: nil, searchArea: self.mapView.boundingBox, filters: filter)
        if let error = exploreRequest?.start(self.requestCompletion) as NSError? {
            Helper.show("Error:explore request fired with error code \(error.code)", onView: self.view)
            Helper.hideIndicator()
        }
    }

    func triggerAroundRequest () {
        // Trigger and AroundRequest based on the current map center and the filter for Eat&Drink
        // category.Please refer to HERE Mobile SDK for iOS API doc for other supported location parameters and
        // categories
        let filter = NMACategoryFilter()
        filter.add(fromUniqueId:"eat-drink")
        let aroundRequest: NMADiscoveryRequest? = NMAPlaces.sharedInstance()?.createAroundRequest(location: self.mapView.geoCenter, searchArea: nil, filters: filter)
        if let error: NSError = aroundRequest?.start(self.requestCompletion) as NSError? {
            Helper.show("Error:around request fired with error code \(error.code)", onView: self.view)
            Helper.hideIndicator()
        }
    }

    func addMarkerAtPlace(_ placeLink: NMAPlaceLink) -> Void {
        if let uiImage = UIImage(named:"marker.png") {
            let mapMarker = NMAMapMarker(geoCoordinates: placeLink.position ?? self.mapView.geoCenter, image: uiImage)
            self.mapView.add(mapObject: mapMarker)
            self.mapObjectsArray.append(mapMarker)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the search results to the next view controller
        if segue.identifier == "ResultTableView" {
            if let navigationController = segue.destination as? UINavigationController {
                let resultTableViewController = navigationController.viewControllers.first as? ResultTableViewController
                resultTableViewController?.resultsArray = self.resultsArray;
            }
        }
    }

    func cleanMap () {
        if !self.mapObjectsArray.isEmpty {
            self.mapView.remove(mapObjects:self.mapObjectsArray)
            self.mapObjectsArray.removeAll()
        }
        self.resultListButton.isHidden = true;
    }
}
