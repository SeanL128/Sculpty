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
    Exercise(name: "Push-Up", muscleGroup: .chest, type: .weight),
    Exercise(name: "Barbell Bench Press", muscleGroup: .chest, type: .weight),
    Exercise(name: "Incline Barbell Bench Press", muscleGroup: .chest, type: .weight),
    Exercise(name: "Decline Barbell Bench Press", muscleGroup: .chest, type: .weight),
    Exercise(name: "Dumbbell Bench Press", muscleGroup: .chest, type: .weight),
    Exercise(name: "Incline Dumbbell Bench Press", muscleGroup: .chest, type: .weight),
    Exercise(name: "Decline Dumbbell Bench Press", muscleGroup: .chest, type: .weight),
    Exercise(name: "Smith Machine Bench Press", muscleGroup: .chest, type: .weight),
    Exercise(name: "Incline Smith Machine Bench Press", muscleGroup: .chest, type: .weight),
    Exercise(name: "Decline Smith Machine Bench Press", muscleGroup: .chest, type: .weight),
    Exercise(name: "Pull-Up", muscleGroup: .back, type: .weight),
    Exercise(name: "Machine-Assisted Pull-Up", muscleGroup: .back, type: .weight),
    Exercise(name: "Band-Assisted Pull-Up", muscleGroup: .back, type: .weight),
    Exercise(name: "Deadlift", muscleGroup: .back, type: .weight),
    Exercise(name: "Dumbbell Deadlift", muscleGroup: .back, type: .weight),
    Exercise(name: "Smith Machine Deadlift", muscleGroup: .back, type: .weight),
    Exercise(name: "Dumbbell Biceps Curl", muscleGroup: .biceps, type: .weight),
    Exercise(name: "Dumbbell Hammer Curl", muscleGroup: .biceps, type: .weight),
    Exercise(name: "Cable Biceps Curl", muscleGroup: .biceps, type: .weight),
    Exercise(name: "Cable Hammer Curl", muscleGroup: .biceps, type: .weight),
    Exercise(name: "Alternating Dumbbell Biceps Curl", muscleGroup: .biceps, type: .weight),
    Exercise(name: "Alternating Dumbbell Hammer Curl", muscleGroup: .biceps, type: .weight),
    Exercise(name: "EZ-Bar Biceps Curl", muscleGroup: .biceps, type: .weight),
    Exercise(name: "Barbell Biceps Curl", muscleGroup: .biceps, type: .weight),
    Exercise(name: "Machine Preacher Curl", muscleGroup: .biceps, type: .weight),
    Exercise(name: "EZ-Bar Preacher Curl", muscleGroup: .biceps, type: .weight),
    Exercise(name: "Dumbbell Preacher Curl", muscleGroup: .biceps, type: .weight),
    Exercise(name: "Barbell Preacher Curl", muscleGroup: .biceps, type: .weight),
    Exercise(name: "Triceps Dip", muscleGroup: .triceps, type: .weight),
    Exercise(name: "Machine Triceps Dip", muscleGroup: .triceps, type: .weight),
    Exercise(name: "Dumbbell Shoulder Press", muscleGroup: .shoulders, type: .weight),
    Exercise(name: "Barbell Shoulder Press", muscleGroup: .shoulders, type: .weight),
    Exercise(name: "Smith Machine Shoulder Press", muscleGroup: .shoulders, type: .weight),
    Exercise(name: "Machine Shoulder Press", muscleGroup: .shoulders, type: .weight),
    Exercise(name: "Dumbbell Squat", muscleGroup: .quads, type: .weight),
    Exercise(name: "Smith Machine Squat", muscleGroup: .quads, type: .weight),
    Exercise(name: "Barbell Squat", muscleGroup: .quads, type: .weight),
    Exercise(name: "Dumbbell Lunge", muscleGroup: .quads, type: .weight),
    Exercise(name: "Barbell Lunge", muscleGroup: .quads, type: .weight),
    Exercise(name: "Smith Machine Lunge", muscleGroup: .quads, type: .weight),
    Exercise(name: "Dumbbell Romanian Deadlift", muscleGroup: .hamstrings, type: .weight),
    Exercise(name: "Barbell Romanian Deadlift", muscleGroup: .hamstrings, type: .weight),
    Exercise(name: "Smith Machine Romanian Deadlift", muscleGroup: .hamstrings, type: .weight),
    Exercise(name: "Barbell Hip Thrust", muscleGroup: .glutes, type: .weight),
    Exercise(name: "Smith Machine Hip Thrust", muscleGroup: .glutes, type: .weight),
    Exercise(name: "Plank", muscleGroup: .core, type: .weight),
    Exercise(name: "Leg Extension", muscleGroup: .quads, type: .weight),
    Exercise(name: "Leg Curl", muscleGroup: .hamstrings, type: .weight),
    Exercise(name: "One-Leg Leg Extension", muscleGroup: .quads, type: .weight),
    Exercise(name: "One-Leg Leg Curl", muscleGroup: .hamstrings, type: .weight),
    Exercise(name: "Leg Press", muscleGroup: .quads, type: .weight),
    Exercise(name: "Dumbbell Chest Fly", muscleGroup: .chest, type: .weight),
    Exercise(name: "Pec Deck", muscleGroup: .chest, type: .weight),
    Exercise(name: "Cable Rear Delt Fly", muscleGroup: .shoulders, type: .weight),
    Exercise(name: "Dumbbell Rear Delt Fly", muscleGroup: .shoulders, type: .weight),
    Exercise(name: "Machine Rear Delt Fly", muscleGroup: .shoulders, type: .weight),
    Exercise(name: "One-Arm Cable Rear Delt Fly", muscleGroup: .shoulders, type: .weight),
    Exercise(name: "One-Arm Dumbbell Rear Delt Fly", muscleGroup: .shoulders, type: .weight),
    Exercise(name: "One-Arm Machine Rear Delt Fly", muscleGroup: .shoulders, type: .weight),
    Exercise(name: "Lat Pulldown", muscleGroup: .back, type: .weight),
    Exercise(name: "Close-Grip Lat Pulldown", muscleGroup: .back, type: .weight),
    Exercise(name: "Wide-Grip Lat Pulldown", muscleGroup: .back, type: .weight),
    Exercise(name: "Machine Lat Pulldown", muscleGroup: .back, type: .weight),
    Exercise(name: "Cable Row", muscleGroup: .back, type: .weight),
    Exercise(name: "Close-Grip Cable Row", muscleGroup: .back, type: .weight),
    Exercise(name: "Wide-Grip Cable Row", muscleGroup: .back, type: .weight),
    Exercise(name: "Machine Row", muscleGroup: .back, type: .weight),
    Exercise(name: "Dumbbell Lateral Raise", muscleGroup: .shoulders, type: .weight),
    Exercise(name: "One-Arm Cable Lateral Raise", muscleGroup: .shoulders, type: .weight),
    Exercise(name: "Rope Triceps Pushdown", muscleGroup: .triceps, type: .weight),
    Exercise(name: "One-Arm Rope Triceps Pushdown", muscleGroup: .triceps, type: .weight),
    Exercise(name: "Straight Bar Triceps Pushdown", muscleGroup: .triceps, type: .weight),
    Exercise(name: "One-Arm Straight Bar Triceps Pushdown", muscleGroup: .triceps, type: .weight),
    Exercise(name: "Rope Overhead Triceps Extension", muscleGroup: .triceps, type: .weight),
    Exercise(name: "One-Arm Rope Overhead Triceps Extension", muscleGroup: .triceps, type: .weight),
    Exercise(name: "Straight Bar Overhead Triceps Extension", muscleGroup: .triceps, type: .weight),
    Exercise(name: "One-Arm Straight Bar Overhead Triceps Extension", muscleGroup: .triceps, type: .weight),
    Exercise(name: "Dumbbell Calf Raise", muscleGroup: .calves, type: .weight),
    Exercise(name: "Barbell Calf Raise", muscleGroup: .calves, type: .weight),
    Exercise(name: "Smith Machine Calf Raise", muscleGroup: .calves, type: .weight),
    Exercise(name: "Machine Calf Raise", muscleGroup: .calves, type: .weight),
    Exercise(name: "Dumbbell Bulgarian Split Squat", muscleGroup: .quads, type: .weight),
    Exercise(name: "Barbell Bulgarian Split Squat", muscleGroup: .quads, type: .weight),
    Exercise(name: "Smith Machine Bulgarian Split Squat", muscleGroup: .quads, type: .weight),
    Exercise(name: "Treadmill Walking", muscleGroup: .cardio, type: .distance),
    Exercise(name: "Treadmill Running", muscleGroup: .cardio, type: .distance),
    Exercise(name: "Walking", muscleGroup: .cardio, type: .distance),
    Exercise(name: "Running", muscleGroup: .cardio, type: .distance)
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

// MARK: Structs
struct UnderlinedTextFieldStyle: TextFieldStyle {
    var isFocused: Binding<Bool>?
    
    var normalLineColor: Color = ColorManager.secondary
    var focusedLineColor: Color = ColorManager.text
    var normalLineHeight: CGFloat = 1
    var focusedLineHeight: CGFloat = 1.5
    var animationDuration: Double = 0.175
    
    init() {
        self.isFocused = nil
    }
    
    init(isFocused: Binding<Bool>) {
        self.isFocused = isFocused
    }
    
    init(
        isFocused: Binding<Bool>,
        normalLineColor: Color = ColorManager.secondary,
        focusedLineColor: Color = ColorManager.text,
        normalLineHeight: CGFloat = 1,
        focusedLineHeight: CGFloat = 1.5,
        animationDuration: Double = 0.175
    ) {
        self.isFocused = isFocused
        self.normalLineColor = normalLineColor
        self.focusedLineColor = focusedLineColor
        self.normalLineHeight = normalLineHeight
        self.focusedLineHeight = focusedLineHeight
        self.animationDuration = animationDuration
    }
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            configuration
                .padding(.horizontal, 1)
            
            Group {
                if let focusBinding = isFocused {
                    Rectangle()
                        .fill(focusBinding.wrappedValue ? focusedLineColor : normalLineColor)
                        .frame(height: focusBinding.wrappedValue ? focusedLineHeight : normalLineHeight)
                        .padding(.top, focusBinding.wrappedValue ? 2.5 : 2)
                        .scaleEffect(x: focusBinding.wrappedValue ? 1.005 : 1, anchor: .center)
                        .animation(.easeOut(duration: animationDuration), value: focusBinding.wrappedValue)
                } else {
                    Rectangle()
                        .fill(normalLineColor)
                        .frame(height: normalLineHeight)
                        .padding(.top, 2)
                }
            }
        }
    }
}

struct RoundedBorderButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(15)
            .foregroundColor(ColorManager.text)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ColorManager.secondary, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct RoundedFilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(ColorManager.text)
            )
            .foregroundColor(ColorManager.background)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
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
    
    func secondaryColor() -> some View {
        self.foregroundStyle(ColorManager.secondary)
    }
    
    func accentColor() -> some View {
        self.foregroundStyle(Color.accentColor)
    }
    
    // Fonts
    func headingText(size: CGFloat = 32) -> some View {
        self.font(.custom("Oswald-Bold", size: size))
    }
    
    func subheadingText() -> some View {
        self.font(.custom("Oswald-Bold", size: 24))
    }
    
    func subheading2Text() -> some View {
        self.font(.custom("Oswald-Bold", size: 18))
    }
    
    func largeBodyText() -> some View {
        self.font(.custom("PublicSans-Regular", size: 18))
    }
    
    func boldLargeBodyText() -> some View {
        self.font(.custom("PublicSans-Bold", size: 18))
    }
    
    func bodyText(size: CGFloat = 16, weight: FontWeight = .regular) -> some View {
        self.font(.custom("PublicSans-\(weight.rawValue)", size: size))
    }
    
    func boldBodyText(size: CGFloat = 16) -> some View {
        self.font(.custom("PublicSans-Bold", size: size))
    }
    
    func subbodyText() -> some View {
        self.font(.custom("PublicSans-Regular", size: 14))
    }
    
    func boldSubbodyText() -> some View {
        self.font(.custom("PublicSans-Bold", size: 14))
    }
    
    func statsText(size: CGFloat = 16) -> some View {
        self.font(.custom("IBMPlexMono-Regular", size: size))
    }
    
    func substatsText() -> some View {
        self.font(.custom("IBMPlexMono-Regular", size: 14))
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
        UserKeys.allCases.forEach {
            removeObject(forKey: $0.rawValue)
        }
    }
}

// MARK: Enums
enum FontWeight: String {
    case regular = "Regular"
    case bold = "Bold"
}
