//
//  FoodEntryRow.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI
import SwiftData

struct FoodEntryRow: View {
    @Environment(\.modelContext) private var context
    
    let entry: FoodEntry
    let log: CaloriesLog
    
    @State private var confirmDelete: Bool = false
    @State private var entryToDelete: FoodEntry?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(entry.name)
                    .bodyText(size: 16)
                    .multilineTextAlignment(.leading)
                    .textColor()
                
                Spacer()
                
                HStack {
                    Button {
                        if let food = entry.fatSecretFood {
                            Popup.show(content: {
                                LogFoodEntryPopup(log: log, entry: entry, food: food)
                            })
                        } else {
                            Popup.show(content: {
                                AddFoodEntryPopup(entry: entry, log: log)
                            })
                        }
                    } label: {
                        Image(systemName: "pencil")
                            .padding(.horizontal, 8)
                            .font(Font.system(size: 16))
                    }
                    .textColor()
                    .animatedButton()
                    
                    Button {
                        entryToDelete = entry
                        
                        Popup.show(content: {
                            ConfirmationPopup(
                                selection: $confirmDelete,
                                promptText: "Delete \(entry.name)?",
                                resultText: "This cannot be undone.",
                                cancelText: "Cancel",
                                confirmText: "Delete"
                            )
                        })
                    } label: {
                        Image(systemName: "xmark")
                            .padding(.horizontal, 8)
                            .font(Font.system(size: 16))
                    }
                    .textColor()
                    .animatedButton(feedback: .warning)
                    .onChange(of: confirmDelete) {
                        if confirmDelete,
                           let entry = entryToDelete {
                            log.entries.removeAll(where: { $0.id == entry.id })
                            context.delete(entry)
                            
                            try? context.save()
                            
                            confirmDelete = false
                            entryToDelete = nil
                        }
                    }
                }
            }
            
            HStack(spacing: 16) {
                Text("\(entry.calories.formatted())cal")
                    .statsText(size: 12)
                    .textColor()
                
                MacroLabel(
                    value: entry.carbs,
                    label: "Carbs",
                    size: 12,
                    color: Color.blue
                )
                
                MacroLabel(
                    value: entry.protein,
                    label: "Protein",
                    size: 12,
                    color: Color.red
                )
                
                MacroLabel(
                    value: entry.fat,
                    label: "Fat",
                    size: 12,
                    color: Color.orange
                )
            }
            
            Text(formatTime(entry.date))
                .statsText(size: 12)
                .secondaryColor()
        }
        .frame(maxWidth: .infinity)
    }
}
