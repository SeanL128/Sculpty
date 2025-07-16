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
            
            Link("Powered by fatsecret", destination: URL(string: "https://www.fatsecret.com")!) // swiftlint:disable:this line_length force_unwrapping
                .bodyText(size: 16)
            
            Spacer()
        }
    }
}
