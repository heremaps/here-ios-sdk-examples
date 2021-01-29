/*
 * Copyright (c) 2011-2020 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit
import NMAKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
UIPickerViewDelegate, UIPickerViewDataSource {

    private enum PickerViewTag: Int {
        case language = 1
        case country
    }

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

    @IBOutlet weak var languageTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var collectionSizeTextField: UITextField!
    @IBOutlet weak var centerTextField: UITextField!
    @IBOutlet weak var searchTextField: UITextField!

    @IBOutlet weak var resultTableView:UITableView!

    var searchResultData = [NMAAutoSuggest]()
    var availableCountries = [""]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupPickerViews()
        setupCountries()
    }

    // MARK: - UIPickerView
    func setupPickerViews() {
        let languagePickerView = UIPickerView(frame: .zero)
        languagePickerView.dataSource = self
        languagePickerView.delegate = self
        languagePickerView.tag = PickerViewTag.language.rawValue
        languageTextField.inputView = languagePickerView

        let countryPickerView = UIPickerView(frame: .zero)
        countryPickerView.dataSource = self
        countryPickerView.delegate = self
        countryPickerView.tag = PickerViewTag.country.rawValue
        countryTextField.inputView = countryPickerView
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        if pickerView.tag == PickerViewTag.language.rawValue {
            languageTextField.text = ViewController.availableLanguages[row]
        } else {
            countryTextField.text = availableCountries[row]
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView.tag == PickerViewTag.language.rawValue ?
            ViewController.availableLanguages[row] : availableCountries[row]
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView.tag == PickerViewTag.language.rawValue ?
            ViewController.availableLanguages.count : availableCountries.count
    }

    // MARK: - UITableView
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
                self.searchTextField.text = query.completion
            })
        } else {
            performSegue(withIdentifier: "showDetail", sender: self)
        }
    }

    @IBAction func onSearchEvent(_ sender: Any) {
        self.view.endEditing(true)
        let text = searchTextField.text
        let coords = centerTextField?.text?.components(separatedBy:",")
        guard coords?.count == 2 else {
            return
        }
        let  geo = NMAGeoCoordinates(latitude: (coords![0] as NSString).doubleValue,
                                     longitude: (coords![1] as NSString).doubleValue)

        // Create address filter if specified
        var addressFilter: NMAAddressFilter?
        if countryTextField.text!.count > 0 {
            addressFilter = NMAAddressFilter.init()
            addressFilter!.countryCode = countryTextField.text;
        }

        let autoSuggestionRequest = NMAPlaces.sharedInstance()!.createAutoSuggestionRequest(location:geo,
            partialTerm:text, resultType:getResultType(), filter: addressFilter)

        autoSuggestionRequest?.languagePreference = languageTextField.text

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

    private func setupCountries() {
        // Get available country codes from iOS system
        let systemCountryCodes = NSLocale.isoCountryCodes

        // Convert 2-digit long country codes to corresponding 3-digit values
        availableCountries += systemCountryCodes.compactMap{NMACountryInfo.toAlpha3CountryCode($0)}
    }
    
}

