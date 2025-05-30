//
//  Helpers.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/20/25.
//

import Foundation
import SwiftUI
import SwiftData

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
    Exercise(name: "Cable Lateral Raise", muscleGroup: .shoulders, type: .weight),
    Exercise(name: "One-Arm Cable Lateral Raise", muscleGroup: .shoulders, type: .weight),
    Exercise(name: "Rope Triceps Pushdown", muscleGroup: .triceps, type: .weight),
    Exercise(name: "Straight Bar Triceps Pushdown", muscleGroup: .triceps, type: .weight),
    Exercise(name: "One-Arm Triceps Pushdown", muscleGroup: .triceps, type: .weight),
    Exercise(name: "Rope Overhead Triceps Extension", muscleGroup: .triceps, type: .weight),
    Exercise(name: "Straight Bar Overhead Triceps Extension", muscleGroup: .triceps, type: .weight),
    Exercise(name: "One-Arm Overhead Triceps Extension", muscleGroup: .triceps, type: .weight),
    Exercise(name: "Dumbbell Calf Raise", muscleGroup: .calves, type: .weight),
    Exercise(name: "Barbell Calf Raise", muscleGroup: .calves, type: .weight),
    Exercise(name: "Smith Machine Calf Raise", muscleGroup: .calves, type: .weight),
    Exercise(name: "Machine Calf Raise", muscleGroup: .calves, type: .weight),
    Exercise(name: "Dumbbell Bulgarian Split Squat", muscleGroup: .quads, type: .weight),
    Exercise(name: "Barbell Bulgarian Split Squat", muscleGroup: .quads, type: .weight),
    Exercise(name: "Smith Machine Bulgarian Split Squat", muscleGroup: .quads, type: .weight),
    Exercise(name: "Dumbbell Wrist Curl", muscleGroup: .forearms, type: .weight),
    Exercise(name: "Barbell Wrist Curl", muscleGroup: .forearms, type: .weight),
    Exercise(name: "Cable Wrist Curl", muscleGroup: .forearms, type: .weight),
    Exercise(name: "EZ-Bar Wrist Curl", muscleGroup: .forearms, type: .weight),
    Exercise(name: "Dumbbell Reverse Wrist Curl", muscleGroup: .forearms, type: .weight),
    Exercise(name: "Barbell Reverse Wrist Curl", muscleGroup: .forearms, type: .weight),
    Exercise(name: "Cable Reverse Wrist Curl", muscleGroup: .forearms, type: .weight),
    Exercise(name: "EZ-Bar Reverse Wrist Curl", muscleGroup: .forearms, type: .weight),
    Exercise(name: "Dumbbell Reverse Curl", muscleGroup: .forearms, type: .weight),
    Exercise(name: "Barbell Reverse Curl", muscleGroup: .forearms, type: .weight),
    Exercise(name: "Cable Reverse Curl", muscleGroup: .forearms, type: .weight),
    Exercise(name: "EZ-Bar Reverse Curl", muscleGroup: .forearms, type: .weight),
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

// MARK: Structs
struct UnderlinedTextFieldStyle: TextFieldStyle {
    var isFocused: Binding<Bool>?
    var text: Binding<String>?
    
    var normalLineColor: Color = ColorManager.secondary
    var focusedLineColor: Color = ColorManager.text
    var normalLineHeight: CGFloat = 1
    var focusedLineHeight: CGFloat = 1.5
    var animationDuration: Double = 0.175
    var emptyBackgroundColor: Color = .clear
    
    init() {
        isFocused = nil
        text = nil
    }
    
    init(isFocused: Binding<Bool>) {
        self.isFocused = isFocused
        text = nil
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
        text = nil
        self.normalLineColor = normalLineColor
        self.focusedLineColor = focusedLineColor
        self.normalLineHeight = normalLineHeight
        self.focusedLineHeight = focusedLineHeight
        self.animationDuration = animationDuration
    }
    
    init(
        isFocused: Binding<Bool>,
        text: Binding<String>,
        normalLineColor: Color = ColorManager.secondary,
        focusedLineColor: Color = ColorManager.text,
        normalLineHeight: CGFloat = 1,
        focusedLineHeight: CGFloat = 1.5,
        animationDuration: Double = 0.175,
        emptyBackgroundColor: Color = ColorManager.secondary
    ) {
        self.isFocused = isFocused
        self.text = text
        self.normalLineColor = normalLineColor
        self.focusedLineColor = focusedLineColor
        self.normalLineHeight = normalLineHeight
        self.focusedLineHeight = focusedLineHeight
        self.animationDuration = animationDuration
        self.emptyBackgroundColor = emptyBackgroundColor
    }
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        VStack(alignment: .leading, spacing: 0) {
//            ZStack(alignment: .leading) {
//                let showBackground: Bool = text != nil && text!.wrappedValue.isEmpty && !(isFocused?.wrappedValue ?? false)
//                
//                emptyBackgroundColor
//                    .ignoresSafeArea(.container, edges: .horizontal)
//                    .frame(height: nil)
//                    .padding(.bottom, -2.5)
//                    .opacity(showBackground ? 0.05 : 0)
//                    .animation(.easeOut(duration: animationDuration), value: showBackground)
//                
//                configuration
//            }
            
            configuration
            
            Group {
                if let focusBinding = isFocused {
                    Rectangle()
                        .fill(focusBinding.wrappedValue ? focusedLineColor : normalLineColor)
                        .frame(height: focusBinding.wrappedValue ? focusedLineHeight : normalLineHeight)
                        .padding(.top, 2.25)
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

struct BorderedToFilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(configuration.isPressed ? ColorManager.text : Color.clear)
                    .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ColorManager.secondary, lineWidth: 2)
            )
            .foregroundStyle(configuration.isPressed ? ColorManager.background : ColorManager.text)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct DisabledBorderedToFilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(ColorManager.secondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ColorManager.secondary, lineWidth: 2)
            )
            .foregroundStyle(ColorManager.background.opacity(0.6))
    }
}

struct FilledToBorderedButtonStyle: ButtonStyle {
    var color: Color
    
    init(color: Color = ColorManager.text) {
        self.color = color
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(configuration.isPressed ? Color.clear : ColorManager.text)
                    .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ColorManager.secondary, lineWidth: 2)
            )
            .foregroundStyle(configuration.isPressed ? ColorManager.text : ColorManager.background)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct DisabledFilledToBorderedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(ColorManager.secondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ColorManager.secondary, lineWidth: 2)
            )
            .foregroundStyle(ColorManager.background.opacity(0.6))
    }
}

// MARK: Classes
final class ColorManager {
    static let background = Color("BackgroundColor")
    
    static let text = Color("TextColor")
    static let secondary = Color("SecondaryTextColor")
}

final class UnitsManager {
    static var selection: String { CloudSettings.shared.units }
    
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
            return "in"
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
    
    // Fonts
    
    // Heading: 32
    // Subheading: 24
    // Subheading 2: 18
    func headingText(size: CGFloat) -> some View {
        self.font(.custom("Oswald-Bold", size: size))
    }
    
    // Large: 18
    // Body: 16
    // Subbody: 14
    func bodyText(size: CGFloat, weight: FontWeight = .regular) -> some View {
        self.font(.custom("PublicSans-\(weight.rawValue)", size: size))
    }
    
    // Stats: 16
    // Substats: 14
    func statsText(size: CGFloat) -> some View {
        self.font(.custom("IBMPlexMono-Regular", size: size))
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

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict: [Element: Bool] = [:]

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
