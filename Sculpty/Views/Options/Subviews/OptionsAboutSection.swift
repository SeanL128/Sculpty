//
//  OptionsAboutSection.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI

struct OptionsAboutSection: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var storeManager: StoreKitManager = StoreKitManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingS) {
            OptionsSectionHeader(title: "About", image: "info.circle")
            
            HStack {
                VStack(alignment: .leading, spacing: .spacingM) {
                    VStack(alignment: .leading, spacing: .spacingS) {
                        if !storeManager.hasPremiumAccess {
                            NavigationLink {
                                PurchasePremium()
                            } label: {
                                HStack(alignment: .center, spacing: .spacingXS) {
                                    Text("Upgrade")
                                        .bodyText()
                                    
                                    Image(systemName: "chevron.right")
                                        .bodyImage()
                                }
                            }
                            .foregroundStyle(ColorManager.text)
                            .hapticButton(.selection)
                            
                            OptionsButtonRow(
                                title: "Restore Purchases",
                                isValid: true,
                                action: {
                                    Task {
                                        await storeManager.restorePurchases()
                                        
                                        dismiss()
                                    }
                                },
                                feedback: .selection
                            )
                        } else {
                            VStack(alignment: .leading, spacing: .spacingXS) {
                                HStack(alignment: .center, spacing: .spacingS) {
                                    Text("Premium Activated")
                                        .bodyText(weight: .regular)
                                    
                                    Image(systemName: "crown.fill")
                                        .bodyImage()
                                }
                                .accentColor()
                                
                                Text("Thank you for supporting Sculpty!")
                                    .secondaryText()
                                    .secondaryColor()
                            }
                        }
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
                        Text("Version \(version) (\(build))")
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
