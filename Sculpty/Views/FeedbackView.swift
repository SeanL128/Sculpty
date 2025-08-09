//
//  FeedbackView.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/8/25.
//

import SwiftUI

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var feedbackManager: FeedbackManager = FeedbackManager()
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var selectedType: FeedbackType = .general
    @State private var message: String = ""
    
    @FocusState private var isNameFocused: Bool
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isMessageFocused: Bool
    
    private var isValid: Bool {
        !message.isEmpty && !feedbackManager.isSubmitting
    }
    
    var body: some View {
        ContainerView(title: "Send Feedback", spacing: .spacingXXL) {
            VStack(alignment: .leading, spacing: .spacingXL) {
                Text("Help improve Sculpty by sharing your feedback.")
                    .subheadingText()
                    .textColor()
                
                Input(
                    title: "Name",
                    text: $name,
                    isFocused: _isNameFocused,
                    autoCapitalization: .words,
                    optional: true
                )
                
                VStack(alignment: .leading, spacing: .spacingS) {
                    Input(
                        title: "Email",
                        text: $email,
                        isFocused: _isEmailFocused,
                        type: .emailAddress,
                        autoCapitalization: .never,
                        optional: true
                    )
                    
                    Text("Providing an email address will allow me to follow up with you.")
                        .captionText()
                        .secondaryColor()
                }
                
                VStack(alignment: .leading, spacing: .spacingS) {
                    LabeledTypedSegmentedControl(
                        label: "Feedback Type",
                        selection: $selectedType,
                        options: FeedbackType.displayOrder,
                        displayNames: FeedbackType.stringDisplayOrder
                    )
                    
                    if let subtitle = selectedType.subtitle {
                        Text(subtitle)
                            .captionText()
                            .secondaryColor()
                    }
                }
                
                Input(
                    title: "Message",
                    text: $message,
                    isFocused: _isMessageFocused,
                    autoCapitalization: .sentences,
                    axis: .vertical,
                    maxCharacters: 2000
                )
            }
            
            VStack(alignment: .leading, spacing: .spacingM) {
                HStack(alignment: .center) {
                    Spacer()
                    
                    VStack(alignment: .center, spacing: .spacingM) {
                        Spacer()
                            .frame(height: 0)
                        
                        Button {
                            if isValid {
                                Task {
                                    do {
                                        try await feedbackManager.submitFeedback(
                                            name: name.isEmpty ? nil : name,
                                            email: email.isEmpty ? nil : email,
                                            type: selectedType,
                                            message: message
                                        )
                                        
                                        dismiss()
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            Popup.show(content: {
                                                InfoPopup(
                                                    title: "Feedback Sent",
                                                    text: "Thank you for your feedback!\(email.isEmpty ? "" : " Please keep an eye out for a possible follow up email in the coming days")" // swiftlint:disable:this line_length
                                                )
                                            })
                                        }
                                    } catch {
                                        Popup.show(content: {
                                            InfoPopup(title: "Error", text: error.localizedDescription)
                                        })
                                    }
                                }
                            }
                        } label: {
                            HStack(alignment: .center, spacing: .spacingS) {
                                if feedbackManager.isSubmitting {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .frame(width: 20, height: 20)
                                        .tint(isValid ? ColorManager.text : ColorManager.secondary)
                                    
                                    Text("Sending...")
                                        .bodyText()
                                } else {
                                    Text("Send Feedback")
                                        .bodyText()
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, feedbackManager.isSubmitting ? .spacingM : .spacingL)
                        }
                        .foregroundStyle(isValid ? ColorManager.text : ColorManager.secondary)
                        .background(isValid ? Color.accentColor : ColorManager.secondary.opacity(0.3)) // swiftlint:disable:this line_length
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .disabled(!isValid)
                        .animatedButton(feedback: .success, isValid: isValid)
                        .animation(.easeInOut(duration: 0.2), value: isValid)
                    }
                    
                    Spacer()
                }
                
                Text("Along with the information you have provided, the app version, device model, and operating system will be automatically included.") // swiftlint:disable:this line_length
                    .secondaryText()
                    .secondaryColor()
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardDoneButton()
            }
        }
    }
}
