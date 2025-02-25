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
        VStack {
            HStack {
                Text(title)
                    .font(.footnote)
                
                Spacer()
            }
            
            HStack {
                TextField("", text: $value)
                    .keyboardType(.numberPad)
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .focused($isFocused)
                    .onChange(of: value) {
                        value = value.filteredNumericWithoutDecimalPoint()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                            .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.05, radius: 2)
                    )
                Text("g")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}
#Preview {
    MacroTextField(title: "Test", value: .constant("123"))
}
