//
//  MacroTextField.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/8/25.
//

import SwiftUI
import Neumorphic

struct MacroTextField: View {
    var title: String
    @Binding var value: String
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .bodyText(size: 12)
                .textColor()
            
            HStack(alignment: .bottom) {
                TextField("", text: $value)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .textFieldStyle(UnderlinedTextFieldStyle(isFocused: Binding<Bool>(get: { isFocused }, set: { isFocused = $0 })))
                    .onChange(of: value) {
                        value = value.filteredNumericWithoutDecimalPoint()
                    }
                
                Text("g")
                    .bodyText(size: 16)
                    .textColor()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}
#Preview {
    MacroTextField(title: "Test", value: .constant("123"))
}
