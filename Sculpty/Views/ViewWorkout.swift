//
//  ViewWorkout.swift
//  Sculpty
//
//  Created by Sean Lindsay on 3/22/25.
//

import SwiftUI
import SwiftData
import MijickPopups

struct ViewWorkout: View {
    @Environment(\.modelContext) var context
    
    @State var log: WorkoutLog
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(log.workout.name)
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                    }
                    .padding()
                    
                    TabView {
                        ForEach(log.exerciseLogs, id: \.self) { exerciseLog in
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(exerciseLog.setLogs.sorted { $0.index < $1.index }, id: \.self) { setLog in
                                    HStack {
                                        Text("\(setLog.index)")
                                    }
                                }
                            }
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("REST TIME:")
                        
                        Text("TOTAL TIME:")
                    }
                }
                .padding()
            }
        }
    }
}
