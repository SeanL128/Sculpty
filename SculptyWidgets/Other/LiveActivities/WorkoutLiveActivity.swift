//
//  WorkoutLiveActivity.swift
//  SculptyWidgetsExtension
//
//  Created by Sean Lindsay on 8/5/25.
//

import SwiftUI
import ActivityKit
import WidgetKit

struct WorkoutLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutLiveActivityAttributes.self) { context in
            WorkoutLiveActivityLockScreenView(context: context)
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
            } minimal: {
                Image("TransparentIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
        }
    }
}
