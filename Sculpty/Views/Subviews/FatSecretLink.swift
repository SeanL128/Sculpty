//
//  FatSecretLink.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/12/25.
//

import SwiftUI

struct FatSecretLink: View {
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            
            if let url = URL(string: "https://www.fatsecret.com") {
                Link(destination: url) {
                    HStack(alignment: .center, spacing: .spacingXS) {
                        Text("Powered by fatsecret")
                            .bodyText(weight: .regular)
                        
                        Image(systemName: "chevron.right")
                            .bodyImage()
                    }
                }
            } else {
                Text("Powered by fatsecret")
                    .bodyText(weight: .regular)
                    .textColor()
            }
            
            Spacer()
        }
    }
}
