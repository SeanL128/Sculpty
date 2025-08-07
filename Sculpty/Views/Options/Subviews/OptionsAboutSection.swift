//
//  OptionsAboutSection.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI

struct OptionsAboutSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingS) {
            OptionsSectionHeader(title: "About", image: "info.circle")
            
            HStack {
                VStack(alignment: .leading, spacing: .spacingM) {
                    VStack(alignment: .leading, spacing: .spacingS) {
                        OptionsButtonRow(
                            title: "Upgrade",
                            isValid: true,
                            action: {
                                Popup.show(content: {
                                    InfoPopup(
                                        title: "N/A",
                                        text: "This feature is in development and will be made available at a later date." // swiftlint:disable:this line_length
                                    )
                                })
                            },
                            feedback: .selection
                        )
                        
                        OptionsButtonRow(
                            title: "Restore Purchases",
                            isValid: true,
                            action: {
                                Popup.show(content: {
                                    InfoPopup(
                                        title: "N/A",
                                        text: "This feature is in development and will be made available at a later date." // swiftlint:disable:this line_length
                                    )
                                })
                            },
                            feedback: .selection
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: .spacingS) {
                        Link(destination: URL(string: "https://sculpty.app")!) { // swiftlint:disable:this line_length force_unwrapping
                            HStack(alignment: .center, spacing: .spacingXS) {
                                Text("Website")
                                    .bodyText()
                                
                                Image(systemName: "chevron.right")
                                    .bodyImage()
                            }
                        }
                        
//                        Link(destination: URL(string: "https://sculpty.app/privacy")!) {
//                            HStack(alignment: .center, spacing: .spacingXS) {
//                                Text("Privacy Policy")
//                                    .bodyText(weight: .regular)
//                                
//                                Image(systemName: "chevron.right")
//                                    .bodyImage()
//                            }
//                        }
                    }
                    .textColor()
                    
                    OptionsButtonRow(
                        title: "Acknowledgements",
                        isValid: true,
                        action: {
                            Popup.show(content: {
                                AcknowledgementsPopup()
                            })
                        },
                        feedback: .selection
                    )
                }
                
                Spacer()
            }
            .card()
            
            Spacer()
                .frame(height: 0)
            
            HStack {
                Spacer()
                
                VStack(alignment: .center, spacing: .spacingXS) {
                    Text("Sculpty by Sean Lindsay")
                        .bodyText()
                    
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                       let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                        Text("Version \(version) Build \(build)")
                            .secondaryText()
                    }
                }
                .secondaryColor()
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
    }
}
