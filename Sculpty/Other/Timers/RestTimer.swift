//
//  RestTimer.swift
//  Sculpty
//
//  Created by Sean Lindsay on 6/27/25.
//

import SwiftUI

class RestTimer: ObservableObject {
    @Published var timeRemaining: TimeInterval = 0
    @Published var isRunning = false
    
    private var timer: Timer?
    private var endTime: Date?
    
    func start(duration: TimeInterval) {
        endTime = Date().addingTimeInterval(duration)
        timeRemaining = duration
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let endTime = self.endTime {
                let remaining = endTime.timeIntervalSinceNow
                self.timeRemaining = max(0, remaining)
                if remaining <= 0 {
                    self.timerFinished()
                }
            }
        }
    }
    
    func skip() {
        stop()
        timeRemaining = 0
    }
    
    private func timerFinished() {
        stop()
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    func timeString() -> String {
        let totalSeconds = Int(ceil(timeRemaining))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
