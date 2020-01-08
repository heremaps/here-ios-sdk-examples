/*
 * Copyright (c) 2011-2020 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit
import NMAKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
UIPickerViewDelegate, UIPickerViewDataSource {
    static let availableLanguages = [
        "",
        "af-ZA",
        "sq-AL",
        "ar-SA",
        "az-Latn-AZ",
        "eu-ES",
        "be-BY",
        "bg-BG",
        "ca-ES",
        "zh-CN",
        "zh-TW",
        "hr-HR",
        "cs-CZ",
        "da-DK",
        "nl-NL",
        "en-GB",
        "en-US",
        "et-EE",
        "fa-IR",
        "fil-PH",
        "fi-FI",
        "fr-FR",
        "fr-CA",
        "gl-ES",
        "de-DE",
        "el-GR",
        "ha-Latn-NG",
        "he-IL",
        "hi-IN",
        "hu-HU",
        "id-ID",
        "it-IT",
        "ja-JP",
        "kk-KZ",
        "ko-KR",
        "lv-LV",
        "lt-LT",
        "mk-MK",
        "ms-MY",
        "nb-NO",
        "pl-PL",
        "pt-BR",
        "pt-PT",
        "ro-RO",
        "ru-RU",
        "sr-Latn-CS",
        "sk-SK",
        "sl-SI",
        "es-MX",
        "es-ES",
        "sv-SE",
        "th-TH",
        "tr-TR",
        "uk-UA",
        "uz-Latn-UZ",
        "vi-VN"
    ]

    @IBOutlet weak var resultTypeAddressSwitch: UISwitch!
    @IBOutlet weak var resultTypePlaceSwitch: UISwitch!
    @IBOutlet weak var resultTypeCategorySwitch: UISwitch!
    @IBOutlet weak var resultTypeQuerySwitch: UISwitch!
    @IBOutlet weak var resultTypeChainSwitch: UISwitch!

    @IBOutlet weak var languageLabel: UITextField!
    @IBOutlet weak var colSizeLabel: UITextField!
    @IBOutlet weak var centerLabel: UITextField!
    @IBOutlet weak var searchLabel: UITextField!

    @IBOutlet weak var resultTableView:UITableView!

    @IBOutlet var languagePickerView:UIPickerView?

    var searchResultData = [NMAAutoSuggest]()

    override func viewDidLoad() {
        super.viewDidLoad()

        languagePickerView = UIPickerView(frame: CGRect(x:0, y:50, width: 100, height: 150))
        languagePickerView?.dataSource = self
        languagePickerView?.delegate = self
        languagePickerView?.showsSelectionIndicator = true
        languageLabel.inputView = languagePickerView

    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        languageLabel.text = ViewController.availableLanguages[row]
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ViewController.availableLanguages[row]
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ViewController.availableLanguages.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultData.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style:.subtitle, reuseIdentifier:"cell")
        }

        cell?.textLabel?.numberOfLines = 1
        cell?.detailTextLabel?.numberOfLines = 5
        cell?.textLabel?.sizeToFit()

        let item:NMAAutoSuggest = searchResultData[indexPath.row]
        cell?.textLabel?.text = String(format:"Type:%@", typeToString(type:item.type))

        var text = String(format:"Title:%@", item.title ?? "")
        text = String(format:"%@\nHighlighted Title:%@", text, item.highlightedTitle ?? "")

        if let place = item as? NMAAutoSuggestPlace {
            text = String(format:"%@\nVicinity: %@", text, place.vicinityDescription ?? "")
            text = String(format:"%@\nCategory: %@", text, place.category ?? "")
        } else if let query = item as? NMAAutoSuggestQuery {
            text = String(format:"%@\nCompletion: %@", text, query.completion ?? "")
        } else if let search = item as? NMAAutoSuggestSearch {
            text = String(format:"%@\nCategory: %@", text, search.category ?? "")
        }

        cell?.detailTextLabel?.text = text

        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if  let query = searchResultData[indexPath.row] as? NMAAutoSuggestQuery {
            query.autoSuggestionRequest().start({ request, data, inError in

                guard inError == nil else {
                    print("autoSuggestionRequest returns error with error code:\((inError! as NSError).code)")
                    return
                }

                self.searchResultData = (data as? [NMAAutoSuggest])!
                self.resultTableView.reloadData()
                self.searchLabel.text = query.completion
            })
        } else {
            performSegue(withIdentifier: "showDetail", sender: self)
        }
    }

    @IBAction func onSearchEvent(_ sender: Any) {
        self.view.endEditing(true)
        let text = searchLabel.text
        let coords = centerLabel?.text?.components(separatedBy:",")
        guard coords?.count == 2 else {
            return
        }
        let  geo = NMAGeoCoordinates(latitude: (coords![0] as NSString).doubleValue,
                                     longitude: (coords![1] as NSString).doubleValue)

        let autoSuggestionRequest = NMAPlaces.sharedInstance()!.createAutoSuggestionRequest(location:geo,
            partialTerm:text, resultType:getResultType())

        autoSuggestionRequest?.languagePreference = languageLabel.text

        autoSuggestionRequest?.start({ request, data, inError in

            guard inError == nil else {
                print("autoSuggestionRequest returns error with error code:\((inError! as NSError).code)")
                return
            }

            self.searchResultData = (data as? [NMAAutoSuggest])!
            self.resultTableView.reloadData()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ResponseDetailViewController {
            destination.autoSuggests = searchResultData[(resultTableView.indexPathForSelectedRow?.row)!]
            resultTableView.deselectRow(at: resultTableView.indexPathForSelectedRow!, animated: true)
        }
    }
    
    func typeToString(type : NMAAutoSuggestType) -> String {
        switch (type) {
            case NMAAutoSuggestType.place:
                return "Place"
            case NMAAutoSuggestType.search:
                return "Search"
            case NMAAutoSuggestType.query:
                return "Query"
            case NMAAutoSuggestType.unknown:
                return "Unknown"
            default:
                return "Unknown"
        }
    }

    func getResultType() -> NMAPlacesAutoSuggestionResultType {
        var resultType = 0

        if (resultTypeAddressSwitch.isOn) {
            resultType ^= Int(NMAPlacesAutoSuggestionResultType.address.rawValue)
        }
        if (resultTypePlaceSwitch.isOn) {
            resultType ^= Int(NMAPlacesAutoSuggestionResultType.place.rawValue)
        }
        if (resultTypeCategorySwitch.isOn) {
            resultType ^= Int(NMAPlacesAutoSuggestionResultType.category.rawValue)
        }
        if (resultTypeChainSwitch.isOn) {
            resultType ^= Int(NMAPlacesAutoSuggestionResultType.chain.rawValue)
        }
        if (resultTypeQuerySwitch.isOn) {
            resultType ^= Int(NMAPlacesAutoSuggestionResultType.query.rawValue)
        }

        return NMAPlacesAutoSuggestionResultType(rawValue: NMAPlacesAutoSuggestionResultType.RawValue(resultType))
    }
}

