//
//  WorkoutLiveActivity.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/18/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct WorkoutLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            WorkoutLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image("TransparentIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 1, height: 1)
                        .foregroundStyle(Color.clear)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(alignment: .top) {
                        VStack(alignment:.leading, spacing: 2) {
                            Text(context.state.workoutName)
                                .font(.custom("PublicSans-Bold", size: 20))
                                .foregroundStyle(ColorManager.text)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                            HStack(spacing: 0) {
                                Text("Progress: ")
                                    .font(.custom("PublicSans-Regular", size: 14))
                                
                                Text("\(round(context.state.workoutProgress * 100).formatted())%")
                                    .font(.custom("IBMPlexMono-Regular", size: 14))
                                    .monospacedDigit()
                                    .contentTransition(.numericText())
                                    .animation(.easeInOut(duration: 0.2), value: context.state.workoutProgress)
                            }
                            .foregroundStyle(ColorManager.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(context.state.currentExerciseName)
                                .font(.custom("PublicSans-Regular", size: 12))
                                .foregroundStyle(ColorManager.text)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                            Text(context.state.currentSetText.isEmpty ? "No remaining \(context.state.currentExerciseName) sets" : context.state.currentSetText)
                                .font(.custom("PublicSans-Regular", size: 16))
                                .foregroundStyle(ColorManager.text)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                            if !context.state.nextSetText.isEmpty {
                                Text(context.state.nextSetText)
                                    .font(.custom("PublicSans-Regular", size: 14))
                                    .foregroundStyle(ColorManager.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            } compactLeading: {
                Image("TransparentIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            } compactTrailing: {
                Text("\(round(context.state.workoutProgress * 100).formatted())%")
                    .font(.custom("IBMPlexMono-Regular", size: 16))
                    .foregroundStyle(ColorManager.text)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: context.state.workoutProgress)
            } minimal: {
                Image("TransparentIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
        }
    }
}

struct WorkoutLockScreenView: View {
    let context: ActivityViewContext<WorkoutActivityAttributes>
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment:.leading, spacing: 2) {
                Text(context.state.workoutName)
                    .font(.custom("PublicSans-Bold", size: 20))
                    .foregroundStyle(ColorManager.text)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                HStack(spacing: 0) {
                    Text("Progress: ")
                        .font(.custom("PublicSans-Regular", size: 14))
                    
                    Text("\(round(context.state.workoutProgress * 100).formatted())%")
                        .font(.custom("IBMPlexMono-Regular", size: 14))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.2), value: context.state.workoutProgress)
                }
                .foregroundStyle(ColorManager.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(context.state.currentExerciseName)
                    .font(.custom("PublicSans-Regular", size: 12))
                    .foregroundStyle(ColorManager.text)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                if !context.state.currentSetText.isEmpty {
                    Text(context.state.currentSetText)
                        .font(.custom("PublicSans-Regular", size: 16))
                        .foregroundStyle(ColorManager.text)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                
                if !context.state.nextSetText.isEmpty {
                    Text(context.state.nextSetText)
                        .font(.custom("PublicSans-Regular", size: 14))
                        .foregroundStyle(ColorManager.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
        }
        .padding()
        .background(ColorManager.background)
        .cornerRadius(12)
    }
}

@main
struct WorkoutWidgets: WidgetBundle {
    var body: some Widget {
        WorkoutLiveActivity()
    }
}
