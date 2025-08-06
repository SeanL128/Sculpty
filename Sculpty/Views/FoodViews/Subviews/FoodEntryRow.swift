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
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: .spacingL) {
                Text(entry.name)
                    .bodyText(weight: .regular)
                    .textColor()
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Button {
                    switch entry.type {
                    case .fatSecret:
                        if let food = entry.fatSecretFood {
                            Popup.show(content: {
                                LogFatSecretFoodEntryPopup(log: log, entry: entry, food: food)
                            })
                        }
                    case .custom:
                        if let customFood = entry.customFood {
                            Popup.show(content: {
                                LogCustomFoodEntryPopup(log: log, entry: entry, customFood: customFood)
                            })
                        }
                    case .oneshot:
                        Popup.show(content: {
                            AddFoodEntryPopup(entry: entry, log: log)
                        })
                    }
                } label: {
                    Image(systemName: "pencil")
                        .bodyText(weight: .regular)
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
                        .bodyText(weight: .regular)
                }
                .textColor()
                .animatedButton(feedback: .warning)
                .onChange(of: confirmDelete) {
                    if confirmDelete,
                       let entry = entryToDelete {
                        log.entries.removeAll(where: { $0.id == entry.id })
                        context.delete(entry)
                        
                        do {
                            try context.save()
                            
                            Toast.show("\(entry.name) entry deleted", "trash")
                        } catch {
                            debugLog("Error: \(error.localizedDescription)")
                        }
                        
                        confirmDelete = false
                        entryToDelete = nil
                    }
                }
            }
            
            HStack(alignment: .center, spacing: .spacingM) {
                Text("\(entry.calories.formatted())cal")
                    .captionText()
                    .textColor()
                    .monospacedDigit()
                
                MacroLabel(
                    value: Int(entry.carbs),
                    label: "Carbs",
                    color: Color.blue
                )
                .captionText()
                
                MacroLabel(
                    value: Int(entry.protein),
                    label: "Protein",
                    color: Color.red
                )
                .captionText()
                
                MacroLabel(
                    value: Int(entry.fat),
                    label: "Fat",
                    color: Color.orange
                )
                .captionText()
            }
            
            Text(formatTime(entry.date))
                .captionText()
                .secondaryColor()
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
    }
}
