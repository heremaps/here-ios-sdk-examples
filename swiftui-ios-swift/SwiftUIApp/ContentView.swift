/*
 * Copyright (c) 2011-2021 HERE Europe B.V.
 * All rights reserved.
 */

import SwiftUI
import NMAKit

struct ContentView: View {

    @EnvironmentObject var state: GlobalMapStateModel // Map Settings state
    @State var activeMapScheme = NMAMapSchemeNormalDay // Scheme selected by Picker

    var body: some View {
        VStack {
            HStack {
                MapSettinText(text: "Zoom", value: state.zoom)
                MapSettinText(text: "Tilt", value: state.tilt)
            }
            
            // A wrapped NMAMapView for SwiftUI usage
            HEREMapsView(stateModel: _state, mapScheme: $activeMapScheme)

            // SwiftUI way of creating UISegmentedControl equivalent
            SchemePicker(selectedMapScheme: $activeMapScheme).padding()
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(GlobalMapStateModel())
    }
}
#endif

class GlobalMapStateModel : ObservableObject {
    @Published var zoom: Float = 0
    @Published var tilt: Float = 0

    //Add another settigns for observation here
}
