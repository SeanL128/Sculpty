//
//  CaloriesHistory.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/7/25.
//

import SwiftUI
import SwiftData

struct CaloriesHistory: View {
    @Environment(\.modelContext) private var context
    
    @Query(filter: #Predicate<CaloriesLog> { !$0.entries.isEmpty }) private var caloriesLogs: [CaloriesLog]
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    HStack {
                        Text("Calories History")
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                    }
                    .padding()
                    
                    if caloriesLogs.isEmpty {
                        Text("NO DATA")
                            .font(.title3)
                    } else {
                        List {
                            ForEach(caloriesLogs) { log in
                                Section {
                                    ForEach(log.entries.sorted { $0.calories > $1.calories }) { entry in
                                        Text("\(entry.name) - \(entry.calories.formatted())cal (\(entry.carbs.formatted())g Carbs, \(entry.protein.formatted())g Protein, \(entry.fat.formatted())g Fat)")
                                            .swipeActions {
                                                Button("Delete") {
                                                    if let index = log.entries.firstIndex(where: { $0.id == entry.id }) {
                                                        log.entries.remove(at: index)
                                                    }
                                                }
                                                .tint(.red)
                                            }
                                    }
                                    .font(.caption)
                                } header: {
                                    Text("\(formatDate(log.date)) - \(log.getTotalCalories().formatted())cal")
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
        }
    }
}

#Preview {
    CaloriesHistory()
}
