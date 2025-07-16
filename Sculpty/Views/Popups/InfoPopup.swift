//
//  InfoPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 4/27/25.
//

import SwiftUI

struct InfoPopup: View {
    private var title: String
    private var text: String
    
    init(title: String, text: String) {
        self.title = title
        self.text = text
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            VStack(alignment: .center, spacing: 8) {
                Text(title)
                    .bodyText(size: 18, weight: .bold)
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
