//
//  OptionsInputRow.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI

struct OptionsInputRow: View {
    let title: String
    let unit: String
    
    @Binding var text: String
    @FocusState var isFocused: Bool
    
    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .bodyText()
                .textColor()
            
            Spacer()
            
            Input(
                title: "",
                text: $text,
                isFocused: _isFocused,
                unit: unit,
                type: .numberPad
            )
            .frame(maxWidth: 100)
            .onChange(of: text) {
                text = text.filteredNumericWithoutDecimalPoint()
                
                if text.isEmpty {
                    text = "0"
                }
            }
        }
    }
}
