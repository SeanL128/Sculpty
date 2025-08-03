//
//  WorkoutPreviewPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/17/25.
//

import SwiftUI

struct WorkoutPreviewPopup: View {
    let workout: Workout
    
    @State private var height: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingL) {
            VStack(alignment: .leading, spacing: .spacingM) {
                HStack(alignment: .center) {
                    Spacer()
                    
                    Text(workout.name)
                        .headingText()
                        .textColor()
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        if workout.exercises.isEmpty {
                            EmptyState(
                                image: "dumbbell",
                                text: "No Exercises Found",
                                subtext: "Try adding an exercise to \(workout.name)",
                                topPadding: 0
                            )
                        } else {
                            VStack(alignment: .leading, spacing: .listSpacing) {
                                ForEach(
                                    Array(
                                        workout.exercises.sorted {
                                            $0.index < $1.index
                                        }.enumerated()
                                    ),
                                    id: \.element.id
                                ) { index, exercise in
                                    ExercisePreview(exercise: exercise, index: index)
                                }
                            }
                        }
                    }
                    .background(GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    height = geo.size.height
                                }
                            }
                            .onChange(of: geo.size.height) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    height = geo.size.height
                                }
                            }
                    })
                }
                .frame(maxHeight: min(height, 300))
                .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
            }
            
            HStack(alignment: .center) {
                Spacer()
                
                VStack(alignment: .center, spacing: .spacingM) {
                    Spacer()
                        .frame(height: 0)
                    
                    Button {
                        Popup.dismissLast()
                    } label: {
                        Text("OK")
                            .bodyText()
                            .padding(.vertical, 12)
                            .padding(.horizontal, .spacingL)
                    }
                    .textColor()
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .animatedButton()
                }
                
                Spacer()
            }
        }
    }
}
