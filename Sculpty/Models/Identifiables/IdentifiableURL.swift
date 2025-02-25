//
//  IdentifiableURL.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/25/25.
//

import Foundation

struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}
