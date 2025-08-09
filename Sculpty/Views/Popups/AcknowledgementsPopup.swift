//
//  AcknowledgementsPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/4/25.
//

import SwiftUI

struct AcknowledgementsPopup: View {
    var body: some View {
        VStack(alignment: .center, spacing: .spacingL) {
            VStack(alignment: .center, spacing: .spacingS) {
                Text("Third-Party Packages")
                    .subheadingText()
                    .textColor()
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .center, spacing: .listSpacing) {
                    if let url = URL(string: "https://github.com/airbnb/lottie-ios") {
                        Link("Lottie", destination: url)
                    } else {
                        Text("Lottie")
                    }
                    
                    if let url = URL(string: "https://github.com/hackiftekhar/IQKeyboardManager") {
                        Link("IQKeyboardManager", destination: url)
                    } else {
                        Text("IQKeyboardManager")
                    }
                }
                .bodyText()
                .accentColor()
            }
            
            VStack(alignment: .center, spacing: .spacingM) {
                Spacer()
                    .frame(height: 0)
                
                Button {
                    Popup.dismissLast()
                } label: {
                    Text("OK")
                        .bodyText()
                        .padding(.vertical, 12)
                        .padding(.horizontal, .spacingL)
                }
                .textColor()
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .animatedButton(feedback: .selection)
            }
        }
    }
}
