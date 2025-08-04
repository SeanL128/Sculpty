//
//  OptionsToggleRow.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI

struct OptionsToggleRow: View {
    let text: String
    
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            Text(text)
                .bodyText()
                .textColor()
        }
        .toggleStyle(SmallToggleStyle())
    }
}
