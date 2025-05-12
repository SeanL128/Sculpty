//
//  PageRenderer.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/11/25.
//

// This in an intermediate view to use when using @Query causes an infinite loop. Apple, please look into and fix the issue.
import SwiftUI

struct PageRenderer: View {
    let page: PageRendererType
    
    var body: some View {
        switch page {
        case .exerciseList:
            ExerciseList()
        case .upsertWorkout:
            UpsertWorkout()
        }
    }
}

enum PageRendererType {
    case exerciseList
    case upsertWorkout
}
