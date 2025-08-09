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
    var optional: Bool = false
    var maxCharacters: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingXS) {
            if !title.isEmpty {
                HStack(alignment: .center, spacing: .spacingXS) {
                    Text(title)
                        .captionText()
                        .textColor()
                    
                    if optional {
                        Text("(Optional)")
                            .captionText()
                            .secondaryColor()
                    }
                    
                    if let max = maxCharacters {
                        Spacer()
                        
                        Text("\(text.count)/\(max)")
                            .captionText()
                            .foregroundStyle(text.count == max ? ColorManager.destructive : Double(text.count) >= Double(max) * 0.85 ? ColorManager.warning : ColorManager.text) // swiftlint:disable:this line_length
                    }
                }
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
                    .onChange(of: text) {
                        if let max = maxCharacters {
                            text = String(text.prefix(max))
                        }
                    }
                
                if let unit = unit {
                    Text(unit)
                        .bodyText()
                        .textColor()
                }
            }
        }
    }
}
