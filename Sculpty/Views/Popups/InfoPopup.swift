//
//  InfoPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 4/27/25.
//

import SwiftUI

struct InfoPopup: View {
    let title: String
    let text: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            VStack(alignment: .center, spacing: 8) {
                Text(title)
                    .bodyText(size: 18, weight: .bold)
                    .textColor()
                    .multilineTextAlignment(.center)
                
                Text(text)
                    .bodyText(size: 16)
                    .textColor()
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 300)
            
            Button {
                Popup.dismissLast()
            } label: {
                Text("OK")
                    .bodyText(size: 18, weight: .bold)
            }
            .textColor()
            .animatedButton()
        }
    }
}
