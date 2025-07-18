//
//  MuscleGroupMenu.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct MuscleGroupMenu: View {
    @Binding var selectedMuscleGroup: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Muscle Group")
                .bodyText(size: 12)
                .textColor()
            
            Button {
                Popup.show(content: {
                    MenuPopup(
                        title: "Muscle Group",
                        options: MuscleGroup.stringDisplayOrder,
                        selection: $selectedMuscleGroup
                    )
                })
            } label: {
                HStack(alignment: .center) {
                    Text(selectedMuscleGroup ?? "Select")
                        .bodyText(size: 18, weight: .bold)
                    
                    Image(systemName: "chevron.right")
                        .padding(.leading, -2)
                        .font(Font.system(size: 12, weight: .bold))
                }
            }
            .textColor()
            .animatedButton(scale: 0.98, feedback: .selection)
        }
    }
}
