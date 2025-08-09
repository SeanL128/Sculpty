//
//  FeedbackManager.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/8/25.
//

import Foundation

@MainActor
class FeedbackManager: ObservableObject {
    @Published var isSubmitting: Bool = false
    @Published var lastSubmissionTime: Date?
    
    private let baseURL: String = "https://feedback.sculpty.app"
    private let minimumSubmissionInterval: TimeInterval = 60
    
    var canSubmitFeedback: Bool {
        guard let lastSubmission = lastSubmissionTime else { return true }
        
        return Date().timeIntervalSince(lastSubmission) > minimumSubmissionInterval
    }
    
    func submitFeedback(
        name: String?,
        email: String?,
        type: FeedbackType,
        message: String
    ) async throws {
        guard canSubmitFeedback else {
            throw FeedbackError.rateLimited
        }
        
        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw FeedbackError.emptyMessage
        }
        
        guard message.count <= 2000 else {
            throw FeedbackError.messageTooLong
        }
        
        if let email = email, !email.isEmpty, !isValidEmail(email) {
            throw FeedbackError.invalidEmail
        }
        
        isSubmitting = true
        
        defer {
            isSubmitting = false
        }
        
        let deviceInfo = DeviceInfo()
        
        let feedback = FeedbackSubmission(
            name: name?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true ? nil : name?.trimmingCharacters(in: .whitespacesAndNewlines), // swiftlint:disable:this line_length
            email: email?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true ? nil : email?.trimmingCharacters(in: .whitespacesAndNewlines), // swiftlint:disable:this line_length
            type: type.rawValue,
            message: message.trimmingCharacters(in: .whitespacesAndNewlines),
            appVersion: deviceInfo.appVersion,
            buildNumber: deviceInfo.buildNumber,
            deviceInfo: deviceInfo
        )
        
        guard let url = URL(string: "\(baseURL)/feedback") else {
            throw FeedbackError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(feedback)
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw FeedbackError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                lastSubmissionTime = Date()
            case 429:
                throw FeedbackError.rateLimited
            case 400:
                throw FeedbackError.invalidData
            default:
                throw FeedbackError.serverError
            }
        } catch {
            await MainActor.run {
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet:
                        Toast.show("No internet connection.", "wifi.slash")
                    case .timedOut:
                        Toast.show("Request timed out. Try again.", "clock.badge.exclamationmark")
                    default:
                        Toast.show("Failed to send feedback.", "exclamationmark.triangle")
                    }
                } else if let feedbackError = error as? FeedbackError {
                    switch feedbackError {
                    case .rateLimited:
                        Toast.show("Please wait before sending more feedback.", "hand.raised")
                    case .invalidEmail:
                        Toast.show("Please enter a valid email.", "envelope.badge.shield.half.filled")
                    case .emptyMessage:
                        Toast.show("Please enter your feedback.", "text.bubble")
                    default:
                        Toast.show("Unable to send feedback.", "exclamationmark.triangle")
                    }
                } else {
                    Toast.show("Unable to send feedback.", "exclamationmark.triangle")
                }
            }
            
            throw error
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
