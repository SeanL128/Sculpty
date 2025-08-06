//
//  WorkoutLiveActivityLockScreenView.swift
//  SculptyWidgetsExtension
//
//  Created by Sean Lindsay on 8/5/25.
//

import SwiftUI
import WidgetKit

struct WorkoutLiveActivityLockScreenView: View {
    let context: ActivityViewContext<WorkoutLiveActivityAttributes>
    
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
