//
//  SetTimer.swift
//  Sculpty
//
//  Created by Sean Lindsay on 6/27/25.
//

import SwiftUI

class SetTimer: ObservableObject {
    @Published var elapsedTime: TimeInterval = 0
    @Published var isRunning = false
    @Published var status: TimerStatus = .notStarted
    
    private var timer: Timer?
    private var startTime: Date?
    private var pausedTime: TimeInterval = 0
    
    enum TimerStatus {
        case notStarted
        case running
        case paused
        case stopped
    }
    
    func start() {
        startTime = Date().addingTimeInterval(-pausedTime)
        isRunning = true
        status = .running
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if let startTime = self.startTime {
                self.elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    func pause() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        status = .paused
        pausedTime = elapsedTime
    }
    
    func resume() {
        start()
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        status = .stopped
    }
    
    func cancel() {
        stop()
        elapsedTime = 0
        pausedTime = 0
        status = .notStarted
    }
    
    func timeString() -> String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
