//
//  ExerciseTypeMenu.swift
//  Sculpty
//
//  Created by Sean Lindsay on 4/5/25.
//

import SwiftUI

struct ExerciseTypeMenu: View {
    @EnvironmentObject var viewModel: ExerciseViewModel
    
    var body: some View {
        Menu {
            ForEach(ExerciseType.displayOrder, id: \.id) { type in
                Button {
                    viewModel.type = type
                } label: {
                    HStack {
                        Text(type.rawValue)
                        
                        if viewModel.type == type {
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
