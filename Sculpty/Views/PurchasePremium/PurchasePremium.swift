//
//  PurchasePremium.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/7/25.
//

import SwiftUI
import StoreKit

struct PurchasePremium: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var storeManager: StoreKitManager = StoreKitManager.shared
        
    var body: some View {
        ContainerView(title: "Upgrade", spacing: .spacingXL) {
            VStack(alignment: .leading, spacing: .spacingM) {
                Text("Pay once and get:")
                    .subheadingText()
                    .textColor()
                    .multilineTextAlignment(.leading)
                
                VStack(alignment: .leading, spacing: .listSpacing) {
                    PremiumFeatureRow(
                        image: "magnifyingglass",
                        title: "Unlimited Nutrition Database Access",
                        text: "Search and scan without limits"
                    )
                    
                    PremiumFeatureRow(
                        image: "square.and.arrow.down",
                        title: "Save Custom Foods",
                        text: "Create and store your own recipes"
                    )
                    
                    PremiumFeatureRow(
                        image: "chart.line.uptrend.xyaxis",
                        title: "Extended Progress History",
                        text: "Track your journey over longer periods of time"
                    )
                    
                    PremiumFeatureRow(
                        image: "icloud.and.arrow.up",
                        title: "Automatic iCloud Backups",
                        text: "Automatically backup your data to iCloud"
                    )
                    
                    PremiumFeatureRow(
                        image: "bell",
                        title: "Reminders",
                        text: "Receive reminders to stay on top of your progress"
                    )
                    
                    PremiumFeatureRow(
                        image: "clock",
                        title: "Lifetime Access",
                        text: "Guarantee access to all future features"
                    )
                }
            }
            
            VStack(alignment: .center, spacing: .spacingM) {
                Spacer()
                    .frame(height: 0)
                
                VStack(alignment: .center, spacing: .spacingL) {
                    if storeManager.hasPremiumAccess {
                        VStack(alignment: .center, spacing: .spacingXS) {
                            Text("You're all set with Premium")
                                .bodyText()
                                .accentColor()
                            
                            Text("Thank you for supporting Sculpty!")
                                .secondaryText()
                                .secondaryColor()
                        }
                    } else {
                        if let premiumProduct = storeManager.product(for: .premium) {
                            Button {
                                Task {
                                    await storeManager.purchase(premiumProduct)
                                    
                                    if storeManager.hasPremiumAccess {
                                        dismiss()
                                    }
                                }
                            } label: {
                                HStack(alignment: .center, spacing: .spacingS) {
                                    if storeManager.isLoading {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .frame(width: 20, height: 20)
                                            .tint(!storeManager.isLoading && !storeManager.hasPremiumAccess ? ColorManager.text : ColorManager.secondary) // swiftlint:disable:this line_length
                                    }
                                    
                                    Text("Upgrade")
                                        .bodyText()
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, storeManager.isLoading ? .spacingM : .spacingL)
                            }
                            .foregroundStyle(!storeManager.isLoading && !storeManager.hasPremiumAccess ? ColorManager.text : ColorManager.secondary) // swiftlint:disable:this line_length
                            .background(!storeManager.isLoading && !storeManager.hasPremiumAccess ? Color.accentColor : ColorManager.secondary.opacity(0.3)) // swiftlint:disable:this line_length
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .disabled(storeManager.isLoading || storeManager.hasPremiumAccess)
                            .animatedButton(
                                feedback: .impact(weight: .medium),
                                isValid: !storeManager.isLoading && !storeManager.hasPremiumAccess
                            )
                            .animation(.easeInOut(duration: 0.2), value: storeManager.isLoading)
                            .animation(.easeInOut(duration: 0.2), value: storeManager.hasPremiumAccess)
                        }
                        
                        Button {
                            Task {
                                await storeManager.restorePurchases()
                                
                                if storeManager.hasPremiumAccess {
                                    dismiss()
                                }
                            }
                        } label: {
                            Text("Restore Purchases")
                                .bodyText()
                        }
                        .textColor()
                        .animatedButton(feedback: .selection)
                        
                        Button {
                            Popup.dismissLast()
                        } label: {
                            Text("Maybe Later")
                                .bodyText()
                        }
                        .textColor()
                        .animatedButton(feedback: .selection)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            if let errorMessage = storeManager.errorMessage {
                Text(errorMessage)
                    .bodyText()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(ColorManager.destructive)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
