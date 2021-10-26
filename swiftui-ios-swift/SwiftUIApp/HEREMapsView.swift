/*
 * Copyright (c) 2011-2021 HERE Europe B.V.
 * All rights reserved.
 */

import SwiftUI
import NMAKit

// Wrapper for NMAMapView
struct HEREMapsView: UIViewRepresentable {

    // Intended to notify of map state changes to external SwiftUI
    @EnvironmentObject var stateModel: GlobalMapStateModel

    // Intended to listen to external SwiftUI events and update NMAMapView scheme
    @Binding var mapScheme: String

    // Main map instance
    private let mapView = NMAMapView.init(frame: .zero)

    func makeUIView(context: Self.Context) -> NMAMapView {

        // Use coordinator approach to pass UIKit events to SwiftUI
        mapView.gestureDelegate = context.coordinator

        // Setup rest of mapView settins
        mapView.copyrightLogoPosition = .topRight
        mapView.zoomLevel = stateModel.zoom
        mapView.tilt = stateModel.tilt

        return mapView
    }

    func updateUIView(_ mapView: NMAMapView, context: Context) {
        // Update map scheme which might get changed by Picker selection
        mapView.mapScheme = mapScheme
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(stateModel: _stateModel)
    }

    class Coordinator: NSObject, NMAMapGestureDelegate {
        @EnvironmentObject private var stateModel: GlobalMapStateModel

        init(stateModel: EnvironmentObject<GlobalMapStateModel>) {
            self._stateModel = stateModel
        }

        // MARK: NMAMapGestureDelegate
        func mapView(_ mapView: NMAMapView,
                     didReceivePinch pinch: Float,
                     at location: CGPoint) {

            // Let the map handle this pinch
            mapView.defaultGestureHandler?.mapView?(mapView, didReceivePinch: pinch, at: location)

            // Notify of zoom change to shared state
            self.stateModel.zoom = mapView.zoomLevel
        }

        func mapView(_ mapView: NMAMapView,
                     didReceiveTwoFingerPan translation: CGPoint,
                     at location: CGPoint) {

            // Let the map handle this pan
            mapView.defaultGestureHandler?.mapView?(mapView,
                                                    didReceiveTwoFingerPan: translation,
                                                    at: location)
            // Notify of tilt change to shared state
            stateModel.tilt = mapView.tilt
        }
    }
}

#if DEBUG
struct HEREMapsView_Previews: PreviewProvider {
    @State private static var name = NMAMapSchemeNormalNight

    static var previews: some View {
        HEREMapsView(mapScheme: $name).environmentObject(GlobalMapStateModel())
    }
}
#endif
