/*
 * Copyright (c) 2011-2022 HERE Europe B.V.
 * All rights reserved.
 */

import NMAKit
import SwiftUI

struct SchemePicker: View {
    @Binding var selectedMapScheme: String
    @State var selectedMapSchemeIndex: Int = 0

    var mapSchemes = [NMAMapSchemeNormalDay, NMAMapSchemeNormalNight, NMAMapSchemeSatelliteDay]

    init(selectedMapScheme: Binding<String>) {
        _selectedMapScheme = selectedMapScheme

        setupPicker()
    }

    private func setupPicker() {
        let appearance = UISegmentedControl.appearance()
        appearance.selectedSegmentTintColor = .blue
        appearance.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        appearance.setTitleTextAttributes([.foregroundColor: UIColor.blue], for: .normal)
    }

    var body: some View {
        let binding = Binding<Int>(
            get: { self.selectedMapSchemeIndex },
            set: {
                self.selectedMapSchemeIndex = $0
                self.selectedMapScheme = self.mapSchemes[self.selectedMapSchemeIndex]
        })

        return Picker("Schemes", selection: binding) {
            ForEach(mapSchemes.indices) { index in
                Text(self.mapSchemes[index]).tag(index)
            }
        }.pickerStyle(SegmentedPickerStyle())
    }
}
