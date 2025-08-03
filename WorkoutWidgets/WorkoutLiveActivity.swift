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
                        VStack(alignment:.leading, spacing: .spacingXS) {
                            Text(context.state.workoutName)
                                .bodyText()
                                .textColor()
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                            Text("Progress: \(round(context.state.workoutProgress * 100).formatted())%")
                                .secondaryText()
                                .secondaryColor()
                                .monospacedDigit()
                                .contentTransition(.numericText())
                                .animation(.easeInOut(duration: 0.2), value: context.state.workoutProgress)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: .spacingXS) {
                            Text(context.state.currentExerciseName)
                                .captionText()
                                .textColor()
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                            Text(context.state.currentSetText.isEmpty ? "No remaining \(context.state.currentExerciseName) sets" : context.state.currentSetText)
                                .bodyText()
                                .textColor()
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                            if !context.state.nextSetText.isEmpty {
                                Text(context.state.nextSetText)
                                    .bodyText(weight: .regular)
                                    .secondaryColor()
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                        }
                    }
                    .padding(.horizontal, .spacingXS)
                }
            } compactLeading: {
                Image("TransparentIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            } compactTrailing: {
                Text("\(round(context.state.workoutProgress * 100).formatted())%")
                    .bodyText()
                    .textColor()
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
            VStack(alignment:.leading, spacing: .spacingXS) {
                Text(context.state.workoutName)
                    .subheadingText()
                    .textColor()
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text("Progress: \(round(context.state.workoutProgress * 100).formatted())%")
                    .secondaryText()
                    .secondaryColor()
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: context.state.workoutProgress)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: .spacingXS) {
                Text(context.state.currentExerciseName)
                    .captionText()
                    .textColor()
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                if !context.state.currentSetText.isEmpty {
                    Text(context.state.currentSetText)
                        .bodyText()
                        .foregroundStyle(ColorManager.text)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                
                if !context.state.nextSetText.isEmpty {
                    Text(context.state.nextSetText)
                        .bodyText(weight: .regular)
                        .secondaryColor()
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
        }
        .padding(.spacingM)
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
