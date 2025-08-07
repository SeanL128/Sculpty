//
//  iCloudBackup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/7/25.
//

import Foundation

struct iCloudBackup: Identifiable, Comparable {
    let id = UUID()
    let url: URL
    let name: String
    let date: Date
    let size: String
    
    static func < (lhs: iCloudBackup, rhs: iCloudBackup) -> Bool {
        lhs.date > rhs.date
    }
    
    init(url: URL) {
        self.url = url
        self.name = url.deletingPathExtension().lastPathComponent
        
        if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
           let creationDate = attributes[.creationDate] as? Date {
            self.date = creationDate
        } else {
            self.date = Date()
        }
        
        if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
           let fileSize = attributes[.size] as? Int64 {
            self.size = ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
        } else {
            self.size = "Unknown"
        }
    }
}
