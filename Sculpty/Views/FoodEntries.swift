//
//  FoodEntries.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/21/25.
//

import SwiftUI
import SwiftData
import Neumorphic
import MijickPopups

struct FoodEntries: View {
    @Environment(\.modelContext) private var context
    
    @State var log: CaloriesLog
    @State private var entryToDelete: FoodEntry? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                ScrollView {
                    VStack {
                        HStack {
                            Text("Food Entries")
                                .font(.largeTitle)
                                .bold()
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text("(\(formatDate(log.date)))")
                                .font(.title2)
                                .bold()
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                    VStack {
                        if !log.entries.isEmpty {
                            ForEach(log.entries.indices, id: \.self) { index in
                                if log.entries.count > index {
                                    let entry = log.entries[index]
                                    
                                    VStack {
                                        HStack {
                                            Text("\(entry.name) - \(entry.calories.formatted())cal")
                                            
                                            Spacer()
                                            
                                            HStack {
                                                Button {
                                                    Task {
                                                        await AddFoodPopup(entry: entry, log: log).present()
                                                    }
                                                } label: {
                                                    Image(systemName: "pencil")
                                                }
                                                .foregroundStyle(Color.accentColor)
                                                .padding(.horizontal, 5)
                                                
                                                Button {
                                                    entryToDelete = entry
                                                } label: {
                                                    Image(systemName: "xmark")
                                                }
                                                .foregroundStyle(Color.accentColor)
                                                .padding(.horizontal, 5)
                                            }
                                        }
                                        
                                        HStack {
                                            HStack {
                                                Circle()
                                                    .fill(.blue)
                                                    .frame(width: 10, height: 10)
                                                
                                                Text("\(entry.carbs.formatted())g Carbs")
                                            }
                                            
                                            HStack {
                                                Circle()
                                                    .fill(.red)
                                                    .frame(width: 10, height: 10)
                                                
                                                Text("\(entry.protein.formatted())g Protein")
                                            }
                                            
                                            HStack {
                                                Circle()
                                                    .fill(.orange)
                                                    .frame(width: 10, height: 10)
                                                
                                                Text("\(entry.fat.formatted())g Fat")
                                            }
                                            
                                            Spacer()
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .transition(.opacity)
                                    
                                    if entry != log.entries.last {
                                        Divider()
                                            .background(ColorManager.text)
                                            .padding(.vertical)
                                    }
                                }
                            }
                        } else {
                            Text("No entries for \(formatDate(log.date))")
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .animation(.easeInOut, value: log.entries)
                    .background(
                        RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                            .softOuterShadow(darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, radius: 2)
                    )
                    .confirmationDialog("Delete \(entryToDelete?.name ?? "food entry")? This cannot be undone.", isPresented: Binding(
                        get: { entryToDelete != nil },
                        set: { if !$0 { entryToDelete = nil } }
                    ), titleVisibility: .visible) {
                        Button("Delete", role: .destructive) {
                            do {
                                if let entry = entryToDelete {
                                    log.entries.remove(at: log.entries.firstIndex(of: entry)!)
                                    context.delete(entry)
                                    
                                    try context.save()

                                    entryToDelete = nil
                                }
                            } catch {
                                print("Error deleting exercise: \(error)")
                            }
                        }
                    }
                }
                .padding()
                .scrollClipDisabled()
            }
        }
    }
}

#Preview {
    FoodEntries(log: CaloriesLog())
}
