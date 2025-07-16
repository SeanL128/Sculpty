//
//  PageRenderer.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/11/25.
//

// This in an intermediate view to use when using @Query causes an infinite loop.
// Apple, please look into and fix the issue.
import SwiftUI

struct PageRenderer: View {
    private let page: PageRendererType
    
    @Binding private var selectedExercise: Exercise?
    
    init (page: PageRendererType, selectedExercise: Binding<Exercise?> = .constant(nil)) {
        self.page = page
        self._selectedExercise = selectedExercise
    }
    
    var body: some View {
        switch page {
        case .exerciseList:
            ExerciseList()
        case .upsertWorkout:
            UpsertWorkout()
        case .upsertExercise:
            UpsertExercise(selectedExercise: $selectedExercise)
        }
    }
}

enum PageRendererType {
    case exerciseList
    case upsertWorkout
    case upsertExercise
}
