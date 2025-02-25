//
//  MuscleGroupMenu.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/8/25.
//

import SwiftUI

struct MuscleGroupMenu: View {
    @EnvironmentObject var viewModel: ExerciseViewModel
    
    var body: some View {
        Menu {
            ForEach(MuscleGroup.displayOrder.reversed(), id: \.id) { muscleGroup in
                Button(action: {
                    viewModel.muscleGroup = viewModel.muscleGroup == muscleGroup ? MuscleGroup.other : muscleGroup
                }) {
                    HStack {
                        Text(muscleGroup.rawValue.capitalized)
                        
                        if viewModel.muscleGroup == muscleGroup {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Text("Select Muscle Groups")
        }
        .padding(.bottom, 25)
    }
}

#Preview {
    MuscleGroupMenu()
}
