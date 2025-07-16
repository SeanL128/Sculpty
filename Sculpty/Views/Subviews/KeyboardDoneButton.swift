//
//  KeyboardDoneButton.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/26/25.
//

import SwiftUI

struct KeyboardDoneButton: View {
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            
            Button {
                dismissKeyboard()
            } label: {
                Text("Done")
                    .bodyText(size: 18, weight: .bold)
            }
            .textColor()
            .animatedButton()
        }
    }
}
