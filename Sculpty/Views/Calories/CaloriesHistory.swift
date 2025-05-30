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
    
    @Query(sort: \CaloriesLog.date, order: .reverse) private var logs: [CaloriesLog]
    private var caloriesLogs: [CaloriesLog] { logs.filter { !$0.entries.isEmpty } }
    
    @State private var confirmDelete: Bool = false
    @State private var entryToDelete: FoodEntry? = nil
    
    var body: some View {
        ContainerView(title: "Calories History", spacing: 30, showScrollBar: true) {
            if !caloriesLogs.isEmpty {
                ForEach(caloriesLogs, id: \.id) { log in
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 2){
                            Text(formatDate(log.date))
                                .headingText(size: 14)
                                .textColor()
                            
                            Text("\(log.getTotalCalories().formatted())cal")
                                .statsText(size: 12)
                                .secondaryColor()
                        }
                        .padding(.bottom, -8)
                        
                        ForEach(log.entries.sorted { $0.date < $1.date }, id: \.id) { entry in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    HStack(spacing: 0) {
                                        Text("\(entry.name) - ")
                                            .bodyText(size: 16)
                                        
                                        Text("\(entry.calories.formatted())cal")
                                            .statsText(size: 16)
                                    }
                                    
                                    Spacer()
                                    
                                    HStack {
                                        Button {
                                            Task {
                                                await AddFoodEntryPoup(entry: entry, log: log).present()
                                            }
                                        } label: {
                                            Image(systemName: "pencil")
                                                .padding(.horizontal, 8)
                                                .font(Font.system(size: 16))
                                        }
                                        .textColor()
                                        
                                        Button {
                                            entryToDelete = entry
                                            
                                            Task {
                                                await ConfirmationPopup(selection: $confirmDelete, promptText: "Delete \(entry.name)?", resultText: "This cannot be undone.", cancelText: "Cancel", confirmText: "Delete").present()
                                            }
                                        } label: {
                                            Image(systemName: "xmark")
                                                .padding(.horizontal, 8)
                                                .font(Font.system(size: 16))
                                        }
                                        .textColor()
                                        .onChange(of: confirmDelete) {
                                            if confirmDelete,
                                               let entry = entryToDelete {
                                                log.entries.remove(at: log.entries.firstIndex(of: entry)!)
                                                context.delete(entry)
                                                
                                                try? context.save()
                                                
                                                confirmDelete = false
                                                entryToDelete = nil
                                            }
                                        }
                                    }
                                }
                                
                                HStack(spacing: 16) {
                                    HStack(spacing: 0) {
                                        Text("\(entry.carbs.formatted())g")
                                            .statsText(size: 12)
                                        
                                        Text(" Carbs")
                                            .bodyText(size: 12)
                                    }
                                    .foregroundStyle(.blue)
                                    
                                    HStack(spacing: 0) {
                                        Text("\(entry.protein.formatted())g")
                                            .statsText(size: 12)
                                        
                                        Text(" Protein")
                                            .bodyText(size: 12)
                                    }
                                    .foregroundStyle(.red)
                                    
                                    HStack(spacing: 0) {
                                        Text("\(entry.fat.formatted())g")
                                            .statsText(size: 12)
                                        
                                        Text(" Fat")
                                            .bodyText(size: 12)
                                    }
                                    .foregroundStyle(.orange)
                                }
                                
                                Text(formatTime(entry.date))
                                    .statsText(size: 12)
                                    .secondaryColor()
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            } else {
                Text("No Data")
                    .bodyText(size: 18)
                    .textColor()
            }
        }
                        
    }
}

#Preview {
    CaloriesHistory()
}
