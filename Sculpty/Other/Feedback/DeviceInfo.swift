//
//  DeviceInfo.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/8/25.
//

import UIKit

struct DeviceInfo: Codable {
    let model: String
    let systemVersion: String
    let appVersion: String
    let buildNumber: String
    
    init() {
        self.model = UIDevice.current.model
        self.systemVersion = UIDevice.current.systemVersion
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        self.buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
}
