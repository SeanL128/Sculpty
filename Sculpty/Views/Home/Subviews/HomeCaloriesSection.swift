//
//  HomeCaloriesSection.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI
import SwiftData

struct HomeCaloriesSection: View {
    @Environment(\.modelContext) private var context
    
    @EnvironmentObject private var settings: CloudSettings
    
    @Query(sort: \CaloriesLog.date) private var caloriesLogs: [CaloriesLog]
    
    @State private var log: CaloriesLog?
    
    var caloriesBreakdown: (Int, Int, Int, Int) {
        guard let log = log else { return (0, 0, 0, 0) }
        
        var calories: Int { Int(log.entries.reduce(0) { $0 + $1.calories }) }
        var carbs: Int { Int(log.entries.reduce(0) { $0 + $1.carbs }) }
        var protein: Int { Int(log.entries.reduce(0) { $0 + $1.protein }) }
        var fat: Int { Int(log.entries.reduce(0) { $0 + $1.fat }) }
        
        return (calories, carbs, protein, fat)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingS) {
            HomeSectionHeader(icon: "fork.knife", title: "Calories") {
                NavigationLink {
                    CaloriesStats()
                } label: {
                    Image(systemName: "chart.xyaxis.line")
                        .headingImage()
                }
                .animatedButton()
                
                NavigationLink {
                    SearchFood(log: log ?? CaloriesLog())
                } label: {
                    Image(systemName: "plus")
                        .headingImage()
                }
                .animatedButton()
            }
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    NavigationLink {
                        FoodEntries(log: log ?? CaloriesLog())
                    } label: {
                        if log != nil,
                           !caloriesLogs.isEmpty {
                            HStack(alignment: .center, spacing: .spacingXS) {
                                Text("\(caloriesBreakdown.0)cal")
                                    .subheadingText(weight: .medium)
                                    .monospacedDigit()
                                
                                Image(systemName: "chevron.right")
                                    .subheadingImage(weight: .medium)
                            }
                            .textColor()
                        } else {
                            Text("---")
                                .subheadingText()
                                .secondaryColor()
                                .blinking()
                        }
                    }
                    
                    Text("Target: \(settings.dailyCalories)cal")
                        .secondaryText()
                        .secondaryColor()
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.3), value: settings.dailyCalories)
                    
                    Text("\(Int(settings.dailyCalories - caloriesBreakdown.0))cal remaining")
                        .secondaryText(weight: .light)
                        .secondaryColor()
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.3), value: caloriesBreakdown.0)
                        .animation(.easeInOut(duration: 0.3), value: settings.dailyCalories)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: .spacingXS) {
                    if log != nil,
                       !caloriesLogs.isEmpty {
                        MacroLabel(
                            value: caloriesBreakdown.1,
                            label: "Carbs",
                            color: Color.blue
                        )
                        .captionText()
                        
                        MacroLabel(
                            value: caloriesBreakdown.2,
                            label: "Protein",
                            color: Color.red
                        )
                        .captionText()
                        
                        MacroLabel(
                            value: caloriesBreakdown.3,
                            label: "Fat",
                            color: Color.orange
                        )
                        .captionText()
                    } else {
                        Text("---")
                            .secondaryColor()
                            .blinking()
                    }
                }
            }
            .card()
        }
        .onAppear {
            setCaloriesLog()
        }
        .onChange(of: log?.entries) {
            do {
                try context.save()
            } catch {
                debugLog("Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func setCaloriesLog() {
        var todaysLog = caloriesLogs.first { log in
            Calendar.current.isDate(log.date, inSameDayAs: Date())
        }
        
        if todaysLog == nil {
            todaysLog = CaloriesLog()
            
            context.insert(todaysLog ?? CaloriesLog())
            
            do {
                try context.save()
            } catch {
                debugLog("Error: \(error.localizedDescription)")
            }
        }
        
        log = todaysLog
    }
}
