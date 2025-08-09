//
//  FeedbackSubmission.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/8/25.
//

import Foundation

struct FeedbackSubmission: Codable {
    let name: String?
    let email: String?
    let type: String
    let message: String
    let appVersion: String
    let buildNumber: String
    let deviceInfo: DeviceInfo
}
