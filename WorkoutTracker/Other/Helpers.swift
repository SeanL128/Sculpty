//
//  Helpers.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/20/25.
//

import Foundation
import SwiftUI
import SwiftData

@Query var workouts: [Workout]

// Variable
var textColor: Color {
    Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? .white : .black
    })
}

// Functions
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

// Extensions
extension View {
    func limitText(_ text: Binding<String>, to characterLimit: Int) -> some View {
        self
            .onChange(of: text.wrappedValue) {
                text.wrappedValue = String(text.wrappedValue.prefix(characterLimit))
            }
    }
}

// Structs
struct ShareSheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        return activityVC
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}
