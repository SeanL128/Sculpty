//
//  Helpers.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/20/25.
//

import SwiftUI

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
    Exercise(name: "Seated Leg Curl", muscleGroup: .hamstrings, type: .weight),
    Exercise(name: "Lying Leg Curl", muscleGroup: .hamstrings, type: .weight),
    Exercise(name: "One-Leg Leg Extension", muscleGroup: .quads, type: .weight),
    Exercise(name: "One-Leg Seated Leg Curl", muscleGroup: .hamstrings, type: .weight),
    Exercise(name: "One-Leg Lying Leg Curl", muscleGroup: .hamstrings, type: .weight),
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

func dismissKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

func round(_ number: Double, _ places: Double) -> Double {
    return round(number * pow(10, places)) / pow(10, places)
}
