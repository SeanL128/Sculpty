//
//  FoodEntries.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/21/25.
//

import SwiftUI
import SwiftData
import MijickPopups

struct FoodEntries: View {
    @Environment(\.modelContext) private var context
    
    @State var log: CaloriesLog
    
    @State var caloriesBreakdown: (Double, Double, Double, Double)
    
    @State private var confirmDelete: Bool = false
    @State private var indexToDelete: Int? = nil
    
    var body: some View {
        ContainerView(title: "Food Entries", spacing: 20, showScrollBar: true, trailingItems: {
            Button {
                Task {
                    await AddFoodEntryPoup(log: log).present()
                }
            } label: {
                Image(systemName: "plus")
                    .padding(.horizontal, 5)
                    .font(Font.system(size: 20))
            }
            .textColor()
        }) {
            if !log.entries.isEmpty {
                ForEach(log.entries.indices, id: \.self) { index in
                    if log.entries.count > index {
                        let entry = log.entries[index]
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                HStack(spacing: 0) {
                                    Text("\(entry.name) - ")
                                        .bodyText(size: 16)
                                        .textColor()
                                    
                                    Text("\(entry.calories.formatted())cal")
                                        .statsText(size: 16)
                                        .textColor()
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
                                        indexToDelete = index
                                        
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
                                           let index = indexToDelete {
                                            log.entries.remove(at: index)
                                            context.delete(entry)
                                            
                                            try? context.save()
                                            
                                            confirmDelete = false
                                            indexToDelete = nil
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
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            } else {
                Text("No entries for \(formatDate(log.date))")
                    .bodyText(size: 16)
                    .textColor()
            }
        }
    }
}
