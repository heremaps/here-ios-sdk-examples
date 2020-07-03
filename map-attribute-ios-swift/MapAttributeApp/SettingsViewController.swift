/*
 * Copyright (c) 2011-2020 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit
import NMAKit

protocol SettingsViewControllerDelegate {
    func settingsViewControllerDidCancel(_ controller: SettingsViewController)
    func settingsViewControllerDidDone(_ controller: SettingsViewController)
}

class SettingsViewController: UITableViewController {

    var delegate: SettingsViewControllerDelegate?
    var mapScheme: String = NMAMapSchemeNormalDay
    var trafficLayers: Int = 0
    var transitDisplayMode: NMAMapTransitDisplayMode?

    let mapSchemes = [
        "NORMAL_DAY" : NMAMapSchemeNormalDay,
        "HYBRID_DAY" : NMAMapSchemeHybridDay,
        "TERRAIN_DAY" : NMAMapSchemeTerrainDay
    ]

    let titles = [
        "Map Schemes", "Transit Mode Attributes", "Traffic Layer Attributes"
    ]

    let transitModes = [
        "NOTHING", "STOP_AND_ACCESSE", "EVERYTHING"
    ]

    var mapSchemeCtrl: UISegmentedControl?
    var transitModeCtrl: UISegmentedControl?
    var flowSwitch: UISwitch = UISwitch()
    var incidentSwitch: UISwitch = UISwitch()

    override func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 2 ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titles[section]
    }

    /**
    * Add segmetned switches for map scheme and transit mode, switch for traffic layer.
    **/
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SegmentedCell")

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SegmentedCell") else { return UITableViewCell() }

        if (indexPath.section == 0)
        {
            let mapSchemeCtrl = UISegmentedControl(items: Array(self.mapSchemes.keys))

            let textAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14.0)]
            mapSchemeCtrl.setTitleTextAttributes(textAttributes, for:UIControl.State.normal)
            mapSchemeCtrl.setTitleTextAttributes(textAttributes, for:UIControl.State.highlighted)
            self.mapSchemeCtrl = mapSchemeCtrl
            cell.contentView.addSubview(mapSchemeCtrl)

            if let index = Array(self.mapSchemes.values).firstIndex(of: self.mapScheme) {
                mapSchemeCtrl.selectedSegmentIndex = index;
            }

            mapSchemeCtrl.translatesAutoresizingMaskIntoConstraints = false;
            let metrics = ["ctrl" : mapSchemeCtrl ]
            cell.contentView.addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(10)-[ctrl]-(10)-|", metrics: nil, views: metrics)
            )
            cell.contentView.addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(10)-[ctrl]-(10)-|", metrics: nil, views: metrics)
            )
        }
        else if (indexPath.section == 1)
        {
            let transitModeCtrl = UISegmentedControl(items: self.transitModes)

            let textAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12.0)]
            transitModeCtrl.setTitleTextAttributes(textAttributes, for:UIControl.State.normal)
            transitModeCtrl.setTitleTextAttributes(textAttributes, for:UIControl.State.highlighted)
            self.transitModeCtrl = transitModeCtrl
            cell.contentView.addSubview(transitModeCtrl)

            if let index = self.transitDisplayMode?.rawValue {
                transitModeCtrl.selectedSegmentIndex = index
            }

            transitModeCtrl.translatesAutoresizingMaskIntoConstraints = false
            let metrics = ["ctrl" : transitModeCtrl ]
            cell.contentView.addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(10)-[ctrl]-(10)-|", metrics: nil, views: metrics)
            )
            cell.contentView.addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(10)-[ctrl]-(10)-|", metrics: nil, views: metrics)
            )
        }
        else if (indexPath.section == 2)
        {
            let switcher = UISwitch()
            cell.accessoryView = switcher;

            switch indexPath.row {
                case 0:
                    cell.textLabel?.text = "FLOW";
                    switcher.isOn = self.trafficLayers & NMATrafficLayer.flow.rawValue > 0
                    self.flowSwitch = switcher;
                case 1:
                    cell.textLabel?.text = "INCIDENT"
                    switcher.isOn = self.trafficLayers & NMATrafficLayer.incidents.rawValue > 0
                    self.incidentSwitch = switcher;
                default:
                    break;
            }
        }
        return cell;
    }

    @IBAction func done(_ sender: UIBarButtonItem) {
        // It gets selection for map scheme
        if let segmentIndex = self.mapSchemeCtrl?.selectedSegmentIndex {
            self.mapScheme = Array(self.mapSchemes.values)[segmentIndex]
        }
        // It gets selection for transit mode
        if let segmentIndex = self.transitModeCtrl?.selectedSegmentIndex {
            self.transitDisplayMode = NMAMapTransitDisplayMode(rawValue: segmentIndex)
        }
        // It gets selection for traffic layer
        self.trafficLayers = 0;
        if self.flowSwitch.isOn {
            self.trafficLayers ^= NMATrafficLayer.flow.rawValue;
        }
        if self.incidentSwitch.isOn {
            self.trafficLayers ^= NMATrafficLayer.incidents.rawValue;
        }

        self.delegate?.settingsViewControllerDidDone(self)
    }
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.delegate?.settingsViewControllerDidCancel(self)
    }
}
