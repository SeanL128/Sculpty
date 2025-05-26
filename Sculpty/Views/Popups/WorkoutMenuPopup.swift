//
//  WorkoutMenuPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/24/25.
//

import SwiftUI
import MijickPopups

struct WorkoutMenuPopup: CenterPopup {
    private var options: [Workout]
    
    @Binding var selection: Workout?
    
    init(options: [Workout], selection: Binding<Workout?>) {
        self.options = options
        self._selection = selection
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            selection = option
                            
                            Task {
                                await dismissLastPopup()
                            }
                        } label: {
                            HStack(alignment: .center) {
                                Text(option.name)
                                    .bodyText(size: 16, weight: selection == option ? .bold : .regular)
                                    .textColor()
                                    .multilineTextAlignment(.leading)
                                
                                if selection == option {
                                    Spacer()
                                    
                                    Image(systemName: "checkmark")
                                        .padding(.horizontal, 8)
                                        .font(Font.system(size: 16))
                                }
                            }
                        }
                        .textColor()
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .padding(.horizontal, 5)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 8)
    }
    
    func configurePopup(config: CenterPopupConfig) -> CenterPopupConfig {
        config
            .backgroundColor(ColorManager.background)
            .popupHorizontalPadding(24)
    }
}
