//
//  OptionsMiscSection.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI

struct OptionsMiscSection: View {
    var body: some View {
        VStack(alignment: .center, spacing: .spacingS) {
            Link("Website", destination: URL(string: "https://sculpty.app")!) // swiftlint:disable:this line_length force_unwrapping
                .bodyText()
                .accentColor()
            
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
               let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                Text("Sculpty Version \(version) Build \(build)")
                    .secondaryText()
                    .secondaryColor()
            }
        }
        .frame(maxWidth: .infinity)
    }
}
