//
//  HomeEmptySectionMessage.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct HomeEmptySectionMessage: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Ready to track your \(text) today")
                .bodyText(size: 16)
            
            HStack(alignment: .center, spacing: 0) {
                Text("Click the ")
                    .bodyText(size: 14)
                
                Image(systemName: "plus")
                    .font(Font.system(size: 8))
                
                Text(" to get started")
                    .bodyText(size: 14)
            }
        }
        .textColor()
        .transition(.scale.combined(with: .opacity))
    }
}
