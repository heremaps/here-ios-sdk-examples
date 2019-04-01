/*
 * Copyright (c) 2011-2019 HERE Europe B.V.
 * All rights reserved.
 */

import UIKit
import NMAKit

let colorSchemeName = "color"
let floatSchemeName = "float"


class ViewController: UIViewController {

    @IBOutlet weak var map: NMAMapView!
    
    let zoom = NMAZoomRange(minimum: 0, maximum: 20)
    var colorScheme: NMACustomizableScheme?
    var floatScheme: NMACustomizableScheme?

    @IBAction func segmentedCtrlClicked(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                //if first segmented clicked, create customized map scheme for specific color property
                colorCustomization()
            case 1:
                //if second segmented clicked, create customized map scheme for specific float property
                floatCustomization()
            default:
                break
        }
    }
    
    func colorCustomization() {
        //if customized map scheme already exists, remove it first.
        if map.getCustomizableScheme(floatSchemeName) != nil {
            //it is not allowed to remove map scheme which is active.
            //set to other map scheme then remove.
            map.mapScheme = NMAMapSchemeNormalDay
            map.removeCustomizableScheme(floatSchemeName)
        }
        
        //create customizable scheme with specific scheme name based on NMAMapSchemeNormalDay
        if (colorScheme == nil) {
            colorScheme = map.createCustomizableScheme(colorSchemeName, basedOn: NMAMapSchemeNormalDay)
        }
        
        //create customizable color for property NMASchemeBuildingColor for specific zoom level
        let buildingColor = colorScheme?.colorForProperty(NMASchemeColorProperty.buildingColor, zoomLevel: 18.0)
        
        buildingColor?.red = 100
        buildingColor?.green = 100
        buildingColor?.blue = 133
        
        //set color property
        if let color = buildingColor {
            colorScheme?.setColorProperty(color, zoomRange: zoom)
        }
        
        //set map scheme to be customized scheme
        map.mapScheme = colorSchemeName
        map.set(geoCenter: NMAGeoCoordinates(latitude: 52.500556, longitude: 13.398889), zoomLevel: 18, animation: NMAMapAnimation.none)
    }
    
    func floatCustomization() {
        //if customized map scheme already exists, remove it first.
        if map.getCustomizableScheme(colorSchemeName) != nil {
            //it is not allowed to remove map scheme which is active.
            //set to other map scheme then remove.
            map.mapScheme = NMAMapSchemeNormalDay
            map.removeCustomizableScheme(colorSchemeName)
        }
        
        //create customizable scheme with specific scheme name based on NMAMapSchemeNormalDay
        if (floatScheme == nil) {
            floatScheme = map.createCustomizableScheme(floatSchemeName, basedOn: NMAMapSchemeNormalDay)
        }
        
        //set its float property boundary width to be 10.0 for specific zoom range
        floatScheme?.setFloatProperty(NMASchemeFloatProperty.countryBoundaryWidth, value: 10, zoomRange: zoom)
        
        //set map scheme to be customized scheme
        map.mapScheme = floatSchemeName
        map.zoomLevel = 4.0
    }
}
