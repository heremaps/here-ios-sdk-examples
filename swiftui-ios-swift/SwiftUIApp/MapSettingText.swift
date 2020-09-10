/*
 * Copyright (c) 2011-2020 HERE Europe B.V.
 * All rights reserved.
 */

import NMAKit
import SwiftUI

struct MapSettinText: View {
    var text: String
    var value: Float

    var body: some View {
        Text("\(text): \(value, specifier: "%.1f")")
            .foregroundColor(.red)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10.0)
                    .stroke(lineWidth: 2.0)
                    .foregroundColor(Color.green)
        )
    }
}

#if DEBUG
struct MapSettingText_Previews: PreviewProvider {
    static var previews: some View {
        MapSettinText(text: "Setting", value: 99.9)
    }
}
#endif
