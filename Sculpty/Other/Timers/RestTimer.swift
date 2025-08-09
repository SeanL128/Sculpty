//
//  RestTimer.swift
//  Sculpty
//
//  Created by Sean Lindsay on 6/27/25.
//

import SwiftUI
import UIKit

class RestTimer: ObservableObject {
    @Published var timeRemaining: TimeInterval = 0
    @Published var isRunning = false
    
    private var timer: Timer?
    private var endTime: Date?
    private var backgroundNotificationId: String?
    
    func start(duration: TimeInterval) {
        endTime = Date().addingTimeInterval(duration)
        timeRemaining = duration
        isRunning = true
        
        scheduleBackgroundNotification(delay: duration)
        
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
        stop(cancelNotification: true)
        
        timeRemaining = 0
    }
    
    private func timerFinished() {
        if UIApplication.shared.applicationState == .active {
            cancelBackgroundNotification()
            
            triggerHapticFeedback()
        }
        
        stop(cancelNotification: false)
    }
    
    func stop(cancelNotification: Bool = true) {
        timer?.invalidate()
        timer = nil
        isRunning = false
        
        if cancelNotification {
            cancelBackgroundNotification()
        }
    }
    
    func timeString() -> String {
        let totalSeconds = Int(ceil(timeRemaining))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func triggerHapticFeedback() {
        let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactGenerator.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            impactGenerator.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            impactGenerator.impactOccurred()
        }
    }
    
    private func scheduleBackgroundNotification(delay: TimeInterval) {
        backgroundNotificationId = "sculpty-rest-timer-\(UUID().uuidString)"
        
        if let notificationId = backgroundNotificationId {
            let content = UNMutableNotificationContent()
            content.title = "Rest Complete"
            content.body = "Time for your next set!"
            content.sound = .default
            
            let actualDelay = max(delay, 2.0)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: actualDelay, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: notificationId,
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    debugLog("Failed to schedule rest timer notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func cancelBackgroundNotification() {
        if let notificationId = backgroundNotificationId {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
            
            backgroundNotificationId = nil
        }
    }
}
