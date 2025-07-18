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
    
    var caloriesBreakdown: (Double, Double, Double, Double) {
        guard let log = log else { return (0, 0, 0, 0) }
        
        var calories: Double { log.entries.reduce(0) { $0 + $1.calories } }
        var carbs: Double { log.entries.reduce(0) { $0 + $1.carbs } }
        var protein: Double { log.entries.reduce(0) { $0 + $1.protein } }
        var fat: Double { log.entries.reduce(0) { $0 + $1.fat } }
        
        return (calories, carbs, protein, fat)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HomeSectionHeader(icon: "fork.knife", title: "Calories") {
                NavigationLink {
                    CaloriesStats()
                } label: {
                    Image(systemName: "chart.xyaxis.line")
                        .padding(.horizontal, 5)
                        .font(Font.system(size: 18))
                }
                .animatedButton()
                
                NavigationLink {
                    SearchFood(log: log ?? CaloriesLog())
                } label: {
                    Image(systemName: "plus")
                        .padding(.horizontal, 5)
                        .font(Font.system(size: 18))
                }
                .animatedButton()
            }
            
            NavigationLink {
                FoodEntries(
                    log: log ?? CaloriesLog(),
                    caloriesBreakdown: caloriesBreakdown
                )
            } label: {
                HStack(alignment: .center) {
                    Text("\(caloriesBreakdown.0.formatted())cal")
                        .statsText(size: 16)
                    
                    Image(systemName: "chevron.right")
                        .padding(.leading, -2)
                        .font(Font.system(size: 10))
                }
                .textColor()
                .padding(.bottom, -2)
            }
            
            HStack(spacing: 0) {
                Text("Remaining: ")
                    .bodyText(size: 14)
                
                if log != nil,
                   !caloriesLogs.isEmpty {
                    Text("\((Double(settings.dailyCalories) - caloriesBreakdown.0).formatted())cal")
                        .statsText(size: 14)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.3), value: caloriesBreakdown.0)
                } else {
                    Text("---")
                        .statsText(size: 14)
                        .opacity(0.5)
                }
            }
            .secondaryColor()
            
            if log != nil,
               !caloriesLogs.isEmpty {
                HStack(spacing: 16) {
                    MacroLabel(
                        value: caloriesBreakdown.1,
                        label: "Carbs",
                        size: 14,
                        color: Color.blue
                    )
                    
                    MacroLabel(
                        value: caloriesBreakdown.2,
                        label: "Protein",
                        size: 14,
                        color: Color.red
                    )
                    
                    MacroLabel(
                        value: caloriesBreakdown.3,
                        label: "Fat",
                        size: 14,
                        color: Color.orange
                    )
                }
            } else {
                Text("---")
                    .statsText(size: 14)
                    .secondaryColor()
                    .opacity(0.5)
            }
        }
        .frame(maxWidth: .infinity)
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
        let todaysLog = caloriesLogs.first { log in
            Calendar.current.isDate(log.date, inSameDayAs: Date())
        }
        
        if todaysLog == nil {
            let todaysLog = CaloriesLog()
            
            context.insert(todaysLog)
            
            do {
                try context.save()
            } catch {
                debugLog("Error: \(error.localizedDescription)")
            }
        }
        
        log = todaysLog
    }
}
