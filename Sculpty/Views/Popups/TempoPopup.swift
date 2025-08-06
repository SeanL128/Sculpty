//
//  TempoPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 3/9/25.
//

import SwiftUI

struct TempoPopup: View {
    private let arr: [String]
    private let zeroPresent: Bool
    
    init (tempo: String = "0000") {
        arr = tempo.map { String($0) }
        zeroPresent = tempo.contains(where: { $0 == "0" })
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: .spacingL) {
            VStack(alignment: .center, spacing: .spacingXS) {
                Text("\(arr[0]): Eccentric (Lowering/Lenthening)")
                    .bodyText(weight: .regular)
                    .textColor()
                    .monospacedDigit()
                    .multilineTextAlignment(.center)
                
                Text("\(arr[1]): Lengthened Pause (Fully Stretched)")
                    .bodyText(weight: .regular)
                    .textColor()
                    .monospacedDigit()
                    .multilineTextAlignment(.center)
                
                Text("\(arr[2]): Concentric (Lifting/Shortening)")
                    .bodyText(weight: .regular)
                    .textColor()
                    .monospacedDigit()
                    .multilineTextAlignment(.center)
                
                Text("\(arr[3]): Shortened Pause (Fully Shortened)")
                    .bodyText(weight: .regular)
                    .textColor()
                    .monospacedDigit()
                    .multilineTextAlignment(.center)
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
                .background(ColorManager.accent)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .animatedButton(feedback: .selection)
            }
        }
    }
}
