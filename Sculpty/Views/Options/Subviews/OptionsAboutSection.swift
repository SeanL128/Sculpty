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
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: .spacingS) {
                        if !storeManager.hasPremiumAccess {
                            NavigationLink {
                                UpgradeView()
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
                                    }
                                },
                                feedback: .selection
                            )
                        } else {
                            VStack(alignment: .leading, spacing: 0) {
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
                    
                    if let url = URL(string: "https://sculpty.app") {
                        Link(destination: url) {
                            HStack(alignment: .center, spacing: .spacingXS) {
                                Text("Website")
                                    .bodyText()
                                
                                Image(systemName: "chevron.right")
                                    .bodyImage()
                            }
                        }
                        .textColor()
                    }
                    
                    VStack(alignment: .leading, spacing: .spacingS) {
                        if let url = URL(string: "https://sculpty.app/privacy") {
                            Link(destination: url) {
                                HStack(alignment: .center, spacing: .spacingXS) {
                                    Text("Privacy Policy")
                                        .bodyText()
                                    
                                    Image(systemName: "chevron.right")
                                        .bodyImage()
                                }
                            }
                            .textColor()
                        }
                        
                        if let url = URL(string: "https://sculpty.app/terms") {
                            Link(destination: url) {
                                HStack(alignment: .center, spacing: .spacingXS) {
                                    Text("Terms of Use")
                                        .bodyText()
                                    
                                    Image(systemName: "chevron.right")
                                        .bodyImage()
                                }
                            }
                            .textColor()
                        }
                    }
                    
                    OptionsButtonRow(
                        title: "Send Feedback",
                        isValid: true,
                        action: {
                            sendFeedbackEmail()
                        },
                        feedback: .selection
                    )
                    
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
    
    private func sendFeedbackEmail() {
        let emailTo = "feedback@sculpty.app"
        let subject = "Sculpty Feedback"
        let body = getDeviceInfoBody()
        
        let mailtoString = "mailto:\(emailTo)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" // swiftlint:disable:this line_length
        
        if let url = URL(string: mailtoString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            Popup.show(content: {
                InfoPopup(
                    title: "Mail Not Available",
                    text: "Please send your feedback to feedback@sculpty.app using your preferred email app."
                )
            })
        }
    }
    
    private func getDeviceInfoBody() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        let device = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion
        
        return """
        
        
        
        --- Please write your feedback above this line ---
        
        App Version: \(version) (\(build))
        Device: \(device)
        iOS Version: \(systemVersion)
        """
    }
}
