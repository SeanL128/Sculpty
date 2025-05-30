//
//  SelectWorkout.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/27/25.
//

import SwiftUI
import SwiftData

struct SelectWorkout: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Query private var workouts: [Workout]
    private var workoutOptions: [Workout] {
        if forStats {
            return workouts.filter { !$0.workoutLogs.isEmpty }
        } else {
            return workouts
        }
    }
    
    @Binding var selectedWorkout: Workout?
    
    var forStats: Bool = false
    
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    
    var filteredWorkouts: [Workout] {
        if searchText.isEmpty {
            return workouts
        } else {
            return workouts.filter { workout in
                workout.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        ContainerView(title: "Select Workout", spacing: 16, showScrollBar: true, trailingItems: {
            if !forStats {
                NavigationLink(destination: UpsertWorkout()) {
                    Image(systemName: "plus")
                        .padding(.horizontal, 5)
                        .font(Font.system(size: 20))
                }
                .textColor()
            }
        }) {
            TextField("Search Workouts", text: $searchText)
                .focused($isSearchFocused)
                .textFieldStyle(UnderlinedTextFieldStyle(isFocused: Binding<Bool>(get: { isSearchFocused }, set: { isSearchFocused = $0 }), text: $searchText))
                .padding(.bottom, 5)
            
            ForEach(filteredWorkouts.sorted { $0.index < $1.index }, id: \.id) { workout in
                Button {
                    selectedWorkout = workout
                } label: {
                    HStack(alignment: .center) {
                        Text(workout.name)
                            .bodyText(size: 16, weight: selectedWorkout == workout ? .bold : .regular)
                            .multilineTextAlignment(.leading)
                        
                        if selectedWorkout == workout {
                            Spacer()
                            
                            Image(systemName: "checkmark")
                                .padding(.horizontal, 8)
                                .font(Font.system(size: 16))
                        }
                    }
                }
                .foregroundStyle(forStats && !workoutOptions.contains(where: { $0.id == workout.id }) ? ColorManager.secondary : ColorManager.text)
                .disabled(forStats && !workoutOptions.contains(where: { $0.id == workout.id }))
            }
        }
        .toolbar {
            ToolbarItemGroup (placement: .keyboard) {
                Spacer()
                
                KeyboardDoneButton(focusStates: [_isSearchFocused])
            }
        }
        .onChange(of: selectedWorkout) {
            if selectedWorkout != nil {
                dismiss()
            }
        }
    }
}
