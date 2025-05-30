//
//  KeyboardDoneButton.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/26/25.
//

import SwiftUI

struct KeyboardDoneButton: View {
    var focusStates: [FocusState<Bool>]
    
    var disabled: Bool {
        focusStates.allSatisfy { !$0.wrappedValue }
    }
    
    var body: some View {
        Button {
            for state in focusStates {
                state.wrappedValue = false
            }
        } label: {
            Text("Done")
                .bodyText(size: 18, weight: .bold)
        }
        .foregroundStyle(disabled ? ColorManager.secondary : ColorManager.text)
        .disabled(disabled)
    }
}
