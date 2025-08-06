//
//  SculptyWidgets.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/5/25.
//

import SwiftUI
import WidgetKit

@main
struct SculptyWidgets: WidgetBundle {
    var body: some Widget {
        WorkoutLiveActivity()
        
        CaloriesWidget()
        CaloriesLoggedWidget()
        CaloriesRemainingWidget()
    }
}
