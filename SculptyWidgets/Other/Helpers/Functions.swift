//
//  Functions.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/5/25.
//

import Foundation

func debugLog(_ message: String) {
    #if DEBUG
    print("Sculpty Widget: \(message)")
    #endif
}
