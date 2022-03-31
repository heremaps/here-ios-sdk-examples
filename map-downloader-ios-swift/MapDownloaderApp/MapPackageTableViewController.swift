/*
 * Copyright (c) 2011-2022 HERE Europe B.V.
 * All rights reserved.
 */

import Foundation
import UIKit
import NMAKit

class MapPackageTableViewController : UITableViewController, NMAMapLoaderDelegate {
    @IBOutlet weak private var mapPackageTableView: UITableView!
    @IBOutlet weak private var cancelButton: UIBarButtonItem!
    @IBOutlet weak private var mapUpdateButton: UIBarButtonItem!

    private var mapLoader: NMAMapLoader!
    private var currentPackages: [NMAMapPackage] = []
    private var progressLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initMaploader()
    }

    func initMaploader() {
        // Instantiate a MapLoader
        self.mapLoader = NMAMapLoader.sharedInstance()
        self.mapLoader.delegate = self

        // Obtain the current state of the map package hierachies.
        self.mapLoader.getMapPackages()
    }

    // Helper function to refresh the table view. Please note that for code simplicity, this app
    // refreshes the table view to display the highest level of the map hierachies i.e continent map
    // whenever a map installation/un-installation has been completed. Application developers can
    // implement their own logic in this case to handle how they want to present to end users.
    func refreshMapPackageTableWithArray(_ mapPackages: [NMAMapPackage]?) {
        if let mapPackages = mapPackages {
            self.currentPackages = mapPackages
            self.tableView.reloadData()
        }
    }

    // Helper function to pop up an alert window
    func showAlertWithMessage(_ message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)

        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            alert.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - User Actions
    @IBAction func didCancelButtonClick(_ sender: Any) {
        // Cancel the current MapLoader operation.
        let success = self.mapLoader.cancelCurrentOperation()
        if success {
            self.progressLabel?.text = "Cancelling...."
        } else {
            self.showAlertWithMessage("No ongoing Maploader operations to be cancelled.")
        }
    }

    @IBAction func didUpdateButtonClick(_ sender: Any) {
        // Check map update.
        let success = self.mapLoader.checkForMapDataUpdate()
        if !success {
            self.showAlertWithMessage("MapLoader is being busy with other operations")
        }
    }

    // MARK: - MapLoader delegate protocols
    func mapLoader(_ mapLoader: NMAMapLoader, didGetPackages mapLoaderResult: NMAMapLoaderResult) {
        if mapLoaderResult == .success {
            // Please note that to get the latest MapPackage status,the application should always
            // access the rootPackage property of the maploader.
            let root = self.mapLoader.rootPackage
            self.refreshMapPackageTableWithArray(root?.children)
        } else {
            self.showAlertWithMessage(
                String(format:"MapLoader failed to get map packages with error code %lu",
                      mapLoaderResult.rawValue))
        }
    }

    func mapLoader(_ mapLoader: NMAMapLoader,
                   didFindUpdate updateIsAvailable: Bool,
                   from currentMapVersion: String,
                   to newestMapVersion: String,
                   _ mapLoaderResult: NMAMapLoaderResult) {
        if mapLoaderResult == .success {
            if updateIsAvailable {
                // Update map if there is a new version available
                self.showAlertWithMessage(String(format:"Found new map version %@",
                                                 newestMapVersion))
                let success = self.mapLoader.performMapDataUpdate()
                if !success {
                    self.showAlertWithMessage("MapLoader is being busy with other operations")
                }
            } else {
                self.showAlertWithMessage(String(format:"Current map version %@ is the latest.",
                                                 currentMapVersion))
            }
        }
    }

    func mapLoader(_ mapLoader: NMAMapLoader, didUpdate mapLoaderResult: NMAMapLoaderResult) {
        if mapLoaderResult == .success {
            let root = self.mapLoader.rootPackage
            self.refreshMapPackageTableWithArray(root?.children)
        }
    }

    func mapLoader(_ mapLoader: NMAMapLoader, didUpdate progress: Float) {
        if progress < 1.0 {
            self.progressLabel?.text = "Progress:" + progress.description
        } else {
            self.progressLabel?.text = "" // Already finished
        }
    }

    func mapLoader(_ mapLoader: NMAMapLoader,
                   didInstallPackages mapLoaderResult: NMAMapLoaderResult) {
        self.progressLabel?.text = ""
        if mapLoaderResult == .success {
            let root = self.mapLoader.rootPackage
            self.refreshMapPackageTableWithArray(root?.children)
        } else if mapLoaderResult == .operationCancelled {
            self.showAlertWithMessage("Installation is cancelled...")
        }
    }

    func mapLoader(_ mapLoader: NMAMapLoader,
                   didUninstallPackages mapLoaderResult: NMAMapLoaderResult) {
        self.progressLabel?.text = ""
        if mapLoaderResult == .success {
            let root = self.mapLoader.rootPackage
            self.refreshMapPackageTableWithArray(root?.children)
        } else if mapLoaderResult == .operationCancelled {
            self.showAlertWithMessage("Uninstallation is cancelled...")
        }
    }
}

// MARK: - UITableViewDelegate and UITableViewDataSource
extension MapPackageTableViewController {
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return self.currentPackages.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "mapPackageTableViewCell"
        var cell: MapPackageTableViewCell?  = tableView
            .dequeueReusableCell(withIdentifier: cellIdentifier) as? MapPackageTableViewCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("MapPackageTableViewCell",
                                            owner: self,
                                            options: nil)?[0] as? MapPackageTableViewCell
        }
        cell?.selectionStyle = UITableViewCell.SelectionStyle.none
        let mapPackage: NMAMapPackage? = self.currentPackages[indexPath.row]

        // Display title and size information of each map package.
        // Please refer to HERE Mobile SDK for iOS API doc for all support APIs.
        cell?.mapPackageTitleLabel.text = mapPackage?.title
        cell?.mapPackageTitleLabel.sizeToFit()

        if let package = mapPackage {
            switch package.installationStatus {
            case .none:
                cell?.mapPackageStatusLabel.text = "Not Installed"
            case .explicit:
                cell?.mapPackageStatusLabel.text = "Installed"
            case .implicit:
                cell?.mapPackageStatusLabel.text = "Installed by parent"
            default:
                print("Unknown installation status")
            }
        }

        // sizeOnDisk property represents the maximum size of a map pacakge. If there are some
        // pacakges already been installed, the actual size consumed may be smaller
        // because of the shared data between packages.
        cell?.mapPackageSizeLabel.text = (mapPackage?.sizeOnDisk)!.description + " KB"

        return cell ?? UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPackage = self.currentPackages[indexPath.row]
        let selectedCell = tableView.cellForRow(at: indexPath) as? MapPackageTableViewCell

        if selectedPackage.children.count > 0 {
            // Children map pacakges exist.Refresh the table view.
            self.refreshMapPackageTableWithArray(selectedPackage.children)
        } else {
            // No children map packages.Perform either downloading or uninstallation action.
            self.progressLabel = selectedCell?.mapPackageProgressLabel
            let packageArray = [selectedPackage]
            if selectedPackage.installationStatus == .implicit
                || selectedPackage.installationStatus == .explicit {
                let success = self.mapLoader.uninstall(packageArray)
                if !success {
                    self.showAlertWithMessage("MapLoader is being busy with other operations")
                } else {
                    self.progressLabel?.text = "Uninstalling..."
                }
            } else {
                let success = self.mapLoader.install(packageArray)
                if !success {
                    self.showAlertWithMessage("MapLoader is being busy with other operations")
                } else {
                    self.progressLabel?.text = "Installing..."
                }
            }
        }
    }
}
