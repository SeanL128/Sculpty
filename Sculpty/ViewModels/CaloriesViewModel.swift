//
//  CaloriesViewModel.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/4/25.
//

import Foundation
import SwiftUI
import SwiftData

class CaloriesViewModel: ObservableObject {
    var log: CaloriesLog
    var entries: [FoodEntry] {
         log.entries
    }
    
    var calories: Double { log.entries.reduce(0) { $0 + $1.calories } }
    var carbs: Double { log.entries.reduce(0) { $0 + $1.carbs } }
    var protein: Double { log.entries.reduce(0) { $0 + $1.protein } }
    var fat: Double { log.entries.reduce(0) { $0 + $1.fat } }
    
    @Published var nameInput: String = ""
    @Published var caloriesInput: String = ""
    @Published var carbsInput: String = ""
    @Published var proteinInput: String = ""
    @Published var fatInput: String = ""
    
    var isValid: Bool {
        !nameInput.isEmpty &&
        !caloriesInput.isEmpty &&
        !carbsInput.isEmpty &&
        !proteinInput.isEmpty &&
        !fatInput.isEmpty
    }
    
    init(log: CaloriesLog = CaloriesLog()) {
        self.log = log
    }
    
    // Functions
    func changeLog(log: CaloriesLog) {
        self.log = log
    }
}
