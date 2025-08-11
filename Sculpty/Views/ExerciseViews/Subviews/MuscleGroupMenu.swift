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
        VStack(alignment: .leading, spacing: .spacingXS) {
            Text("Muscle Group")
                .captionText()
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
                HStack(alignment: .center, spacing: .spacingXS) {
                    Text(selectedMuscleGroup ?? "Select")
                        .bodyText()
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .captionText(weight: .medium)
                }
            }
            .textColor()
            .animatedButton(feedback: .selection)
        }
    }
}
