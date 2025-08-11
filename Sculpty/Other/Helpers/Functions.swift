//
//  Functions.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/25/25.
//

import SwiftUI
import UIKit

func lengthToString(length: Double) -> String {
    let hours = Int(length) / 3600
    let minutes = (Int(length) % 3600) / 60
    let seconds = Int(length) % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}

func formatDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM dd, yyyy"
    return dateFormatter.string(from: date)
}

func formatDateNoYear(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM dd"
    return dateFormatter.string(from: date)
}

func formatMonth(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM ''yy"
    return dateFormatter.string(from: date)
}

func formatTime(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h:mm a"
    return dateFormatter.string(from: date)
}

func formatDateWithTime(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM dd, yyyy h:mm a"
    return dateFormatter.string(from: date)
}

func debugLog(_ message: String) {
    #if DEBUG
    print("DEBUG:\t\t\(message)")
    #endif
}

func dismissKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

func round(_ number: Double, _ places: Double) -> Double {
    return round(number * pow(10, places)) / pow(10, places)
}

func openSettings() {
    if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
    }
}

func levenshteinDistance(_ string1: String, _ string2: String) -> Int {
    let s1 = Array(string1)
    let s2 = Array(string2)
    
    let m = s1.count
    let n = s2.count
    
    if m == 0 { return n }
    if n == 0 { return m }
    
    var previousRow = Array(0...n)
    var currentRow = Array(repeating: 0, count: n + 1)
    
    for i in 1...m {
        currentRow[0] = i
        
        for j in 1...n {
            let cost = s1[i - 1] == s2[j - 1] ? 0 : 1
            
            currentRow[j] = min(
                currentRow[j - 1] + 1,
                previousRow[j] + 1,
                previousRow[j - 1] + cost
            )
        }
        
        (previousRow, currentRow) = (currentRow, previousRow)
    }
    
    return previousRow[n]
}
