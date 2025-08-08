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
                    Link("Lottie", destination: URL(string: "https://github.com/airbnb/lottie-ios")!) // swiftlint:disable:this line_length force_unwrapping
                    
                    Link("IQKeyboardManager", destination: URL(string: "https://github.com/hackiftekhar/IQKeyboardManager")!) // swiftlint:disable:this line_length force_unwrapping
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
