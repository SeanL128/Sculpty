//
//  FeedbackError.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/8/25.
//

import Foundation

enum FeedbackError: LocalizedError {
    case emptyMessage
    case messageTooLong
    case invalidEmail
    case rateLimited
    case invalidURL
    case invalidResponse
    case invalidData
    case serverError
    
    var errorDescription: String? {
        switch self {
        case .emptyMessage:
            return "Please enter your feedback"
        case .messageTooLong:
            return "Feedback message is too long (max 2000 characters)"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .rateLimited:
            return "Please wait a moment before submitting another feedback"
        case .invalidURL:
            return "Invalid server URL"
        case .invalidResponse:
            return "Invalid server response"
        case .invalidData:
            return "Invalid feedback data"
        case .serverError:
            return "Server error occurred. Please try again later."
        }
    }
}
