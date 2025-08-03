//
//  Input.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/14/25.
//

import SwiftUI

struct Input: View {
    var title: String
    @Binding var text: String
    @FocusState var isFocused: Bool
    var unit: String?
    var type: UIKeyboardType = .default
    var autoCapitalization: TextInputAutocapitalization = .never
    var axis: Axis = .horizontal
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingXS) {
            if !title.isEmpty {
                Text(title)
                    .captionText()
                    .textColor()
            }
            
            HStack(alignment: .bottom, spacing: .spacingXS) {
                TextField("", text: $text, axis: axis)
                    .keyboardType(type)
                    .textInputAutocapitalization(autoCapitalization)
                    .focused($isFocused)
                    .textFieldStyle(
                        UnderlinedTextFieldStyle(
                            isFocused: Binding<Bool>(
                                get: { isFocused },
                                set: { isFocused = $0 }
                            ),
                            text: $text
                        )
                    )
                
                if let unit = unit {
                    Text(unit)
                        .bodyText()
                        .textColor()
                }
            }
        }
    }
}
