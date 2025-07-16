//
//  OptionsToggleRow.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI

struct OptionsToggleRow: View {
    let title: String
    
    @Binding var isOn: Bool
    
    @State private var toggleTrigger: Int = 0
    
    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .bodyText(size: 18)
                .textColor()
        }
        .padding(.trailing, 2)
        .onChange(of: isOn) {
            toggleTrigger += 1
        }
        .sensoryFeedback(.selection, trigger: toggleTrigger)
    }
}
