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
            
            Link(destination: URL(string: "https://www.fatsecret.com")!) { // swiftlint:disable:this force_unwrapping
                HStack(alignment: .center, spacing: .spacingXS) {
                    Text("Powered by fatsecret")
                        .bodyText(weight: .regular)
                    
                    Image(systemName: "chevron.right")
                        .bodyImage()
                }
            }
            
            Spacer()
        }
    }
}
