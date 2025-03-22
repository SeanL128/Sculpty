//
//  Helpers.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/20/25.
//

import Foundation
import SwiftUI
import SwiftData
import Neumorphic

@Query private var workouts: [Workout]

// MARK: Variables
let defaultExercises = [
    Exercise(name: "Push-Up", muscleGroup: .chest),
    Exercise(name: "Barbell Bench Press", muscleGroup: .chest),
    Exercise(name: "Incline Barbell Bench Press", muscleGroup: .chest),
    Exercise(name: "Decline Barbell Bench Press", muscleGroup: .chest),
    Exercise(name: "Dumbbell Bench Press", muscleGroup: .chest),
    Exercise(name: "Incline Dumbbell Bench Press", muscleGroup: .chest),
    Exercise(name: "Decline Dumbbell Bench Press", muscleGroup: .chest),
    Exercise(name: "Smith Machine Bench Press", muscleGroup: .chest),
    Exercise(name: "Incline Smith Machine Bench Press", muscleGroup: .chest),
    Exercise(name: "Decline Smith Machine Bench Press", muscleGroup: .chest),
    Exercise(name: "Pull-Up", muscleGroup: .back),
    Exercise(name: "Machine-Assisted Pull-Up", muscleGroup: .back),
    Exercise(name: "Band-Assisted Pull-Up", muscleGroup: .back),
    Exercise(name: "Deadlift", muscleGroup: .back),
    Exercise(name: "Dumbbell Deadlift", muscleGroup: .back),
    Exercise(name: "Smith Machine Deadlift", muscleGroup: .back),
    Exercise(name: "Dumbbell Bicep Curl", muscleGroup: .biceps),
    Exercise(name: "Dumbbell Hammer Curl", muscleGroup: .biceps),
    Exercise(name: "Cable Bicep Curl", muscleGroup: .biceps),
    Exercise(name: "Cable Hammer Curl", muscleGroup: .biceps),
    Exercise(name: "Alternating Dumbbell Bicep Curl", muscleGroup: .biceps),
    Exercise(name: "Alternating Dumbbell Hammer Curl", muscleGroup: .biceps),
    Exercise(name: "EZ-Bar Bicep Curl", muscleGroup: .biceps),
    Exercise(name: "Barbell Bicep Curl", muscleGroup: .biceps),
    Exercise(name: "Machine Preacher Curl", muscleGroup: .biceps),
    Exercise(name: "EZ-Bar Preacher Curl", muscleGroup: .biceps),
    Exercise(name: "Dumbbell Preacher Curl", muscleGroup: .biceps),
    Exercise(name: "Barbell Preacher Curl", muscleGroup: .biceps),
    Exercise(name: "Tricep Dip", muscleGroup: .triceps),
    Exercise(name: "Machine Tricep Dip", muscleGroup: .triceps),
    Exercise(name: "Dumbbell Shoulder Press", muscleGroup: .shoulders),
    Exercise(name: "Barbell Shoulder Press", muscleGroup: .shoulders),
    Exercise(name: "Smith Machine Shoulder Press", muscleGroup: .shoulders),
    Exercise(name: "Machine Shoulder Press", muscleGroup: .shoulders),
    Exercise(name: "Dumbbell Squat", muscleGroup: .quads),
    Exercise(name: "Smith Machine Squat", muscleGroup: .quads),
    Exercise(name: "Barbell Squat", muscleGroup: .quads),
    Exercise(name: "Dumbbell Lunge", muscleGroup: .quads),
    Exercise(name: "Barbell Lunge", muscleGroup: .quads),
    Exercise(name: "Smith Machine Lunge", muscleGroup: .quads),
    Exercise(name: "Dumbbell Romanian Deadlift", muscleGroup: .hamstrings),
    Exercise(name: "Barbell Romanian Deadlift", muscleGroup: .hamstrings),
    Exercise(name: "Smith Machine Romanian Deadlift", muscleGroup: .hamstrings),
    Exercise(name: "Barbell Hip Thrust", muscleGroup: .glutes),
    Exercise(name: "Smith Machine Hip Thrust", muscleGroup: .glutes),
    Exercise(name: "Plank", muscleGroup: .core),
    Exercise(name: "Leg Extension", muscleGroup: .quads),
    Exercise(name: "Leg Curl", muscleGroup: .hamstrings),
    Exercise(name: "One-Leg Leg Extension", muscleGroup: .quads),
    Exercise(name: "One-Leg Leg Curl", muscleGroup: .hamstrings),
    Exercise(name: "Leg Press", muscleGroup: .quads),
    Exercise(name: "Dumbbell Chest Fly", muscleGroup: .chest),
    Exercise(name: "Pec Deck", muscleGroup: .chest),
    Exercise(name: "Cable Rear Delt Fly", muscleGroup: .shoulders),
    Exercise(name: "Dumbbell Rear Delt Fly", muscleGroup: .shoulders),
    Exercise(name: "Machine Rear Delt Fly", muscleGroup: .shoulders),
    Exercise(name: "One-Arm Cable Rear Delt Fly", muscleGroup: .shoulders),
    Exercise(name: "One-Arm Dumbbell Rear Delt Fly", muscleGroup: .shoulders),
    Exercise(name: "One-Arm Machine Rear Delt Fly", muscleGroup: .shoulders),
    Exercise(name: "Lat Pulldown", muscleGroup: .back),
    Exercise(name: "Close-Grip Lat Pulldown", muscleGroup: .back),
    Exercise(name: "Wide-Grip Lat Pulldown", muscleGroup: .back),
    Exercise(name: "Machine Lat Pulldown", muscleGroup: .back),
    Exercise(name: "Cable Row", muscleGroup: .back),
    Exercise(name: "Close-Grip Cable Row", muscleGroup: .back),
    Exercise(name: "Wide-Grip Cable Row", muscleGroup: .back),
    Exercise(name: "Machine Row", muscleGroup: .back),
    Exercise(name: "Dumbbell Lateral Raise", muscleGroup: .shoulders),
    Exercise(name: "One-Arm Cable Lateral Raise", muscleGroup: .shoulders),
    Exercise(name: "Rope Triceps Pushdown", muscleGroup: .triceps),
    Exercise(name: "One-Arm Rope Triceps Pushdown", muscleGroup: .triceps),
    Exercise(name: "Straigth Bar Triceps Pushdown", muscleGroup: .triceps),
    Exercise(name: "One-Arm Straight Bar Triceps Pushdown", muscleGroup: .triceps),
    Exercise(name: "Rope Overhead Triceps Extension", muscleGroup: .triceps),
    Exercise(name: "One-Arm Rope Overhead Triceps Extension", muscleGroup: .triceps),
    Exercise(name: "Straigth Bar Overhead Triceps Extension", muscleGroup: .triceps),
    Exercise(name: "One-Arm Straight Bar Overhead Triceps Extension", muscleGroup: .triceps),
    Exercise(name: "Dumbbell Calf Raise", muscleGroup: .calves),
    Exercise(name: "Barbell Calf Raise", muscleGroup: .calves),
    Exercise(name: "Smith Machine Calf Raise", muscleGroup: .calves),
    Exercise(name: "Machine Calf Raise", muscleGroup: .calves),
    Exercise(name: "Dumbbell Bulgarian Split Squat", muscleGroup: .quads),
    Exercise(name: "Barbell Bulgarian Split Squat", muscleGroup: .quads),
    Exercise(name: "Smith Machine Bulgarian Split Squat", muscleGroup: .quads)
]

// MARK: Functions
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

// MARK: Classes
final class ColorManager {
    static let background = Color("BackgroundColor")
    static let text = Color("TextColor")
    static let secondary = Color("SecondaryTextColor")
    static let lightShadow = Color("LightShadow")
    static let darkShadow = Color("DarkShadow")
}

final class UnitsManager {
    static let selection = UserDefaults.standard.object(forKey: UserKeys.units.rawValue) as? String ?? "Imperial"
    
    static var weight: String {
        switch selection {
        case "Metric":
            return "kg"
        default:
            return "lbs"
        }
    }
    
    static var shortLength: String {
        switch selection {
        case "Metric":
            return "cm"
        default:
            return "inch"
        }
    }
    
    static var mediumLength: String {
        switch selection {
        case "Metric":
            return "m"
        default:
            return "ft"
        }
    }
    
    static var longLength: String {
        switch selection {
        case "Metric":
            return "km"
        default:
            return "mi"
        }
    }
}

// MARK: Extensions
extension View {
    func limitText(_ text: Binding<String>, to characterLimit: Int) -> some View {
        self
            .onChange(of: text.wrappedValue) {
                text.wrappedValue = String(text.wrappedValue.prefix(characterLimit))
            }
    }
    
    func textColor() -> some View {
        self.foregroundStyle(ColorManager.text)
    }
}

extension String {
    func filteredNumeric() -> String {
        let filtered = self.filter { "0123456789.".contains($0) }
        let components = filtered.split(separator: ".")
        let string = components.count > 2 ? "\(components[0]).\(components[1])" : filtered
        return string.count > 1 ? string.replacing(/^([+-])?0+/, with: {$0.output.1 ?? ""}) : string
    }
    
    func filteredNumericWithoutDecimalPoint() -> String {
        let filtered = self.filter { "0123456789".contains($0) }
        return filtered.count > 1 ? filtered.replacing(/^([+-])?0+/, with: {$0.output.1 ?? ""}) : filtered
    }
}

extension Color {
    init(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized.replacingOccurrences(of: "#", with: "")).scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

extension UserDefaults {
    func resetUser(){
        UserKeys.allCases.forEach{
            removeObject(forKey: $0.rawValue)
        }
    }
}
