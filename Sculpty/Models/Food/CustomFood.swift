//
//  CustomFood.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/5/25.
//

import Foundation
import SwiftData

@Model
class CustomFood: Identifiable {
    var id: UUID = UUID()
    
    var name: String = ""
    
    var servingOptions: [CustomServing] = []
    
    var hidden: Bool = false
    
    var _foodEntries: [FoodEntry]?
    var foodEntries: [FoodEntry] {
        get { _foodEntries ?? [] }
        set { _foodEntries = newValue.isEmpty ? nil : newValue }
    }
    
    init(name: String, servingOptions: [CustomServing], hidden: Bool = false) {
        self.name = name
        
        self.servingOptions = servingOptions
        
        self.hidden = hidden
    }
    
    init(id: UUID, name: String, servingOptions: [CustomServing], hidden: Bool = false) {
        self.id = id
        
        self.name = name
        
        self.servingOptions = servingOptions
        
        self.hidden = hidden
    }
    
    func hide() {
        hidden = true
    }
}
