//
//  EdgeSwipeManager.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/15/25.
//

import Foundation

class EdgeSwipeManager: ObservableObject {
    static let shared = EdgeSwipeManager()
    
    @Published var isDisabled = false
    
    private init() {}
    
    func disable() {
        isDisabled = true
    }
    
    func enable() {
        isDisabled = false
    }
}
