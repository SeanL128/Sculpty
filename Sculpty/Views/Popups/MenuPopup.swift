//
//  MenuPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/11/25.
//

import SwiftUI
import MijickPopups

struct MenuPopup: CenterPopup {
    private var title: String
    private var options: [String]
    
    @Binding var selection: String?
    
    init(title: String, options: [String], selection: Binding<String?>) {
        self.title = title
        self.options = options
        self._selection = selection
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Spacer()
                
                Text(title)
                    .bodyText(size: 18, weight: .bold)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            
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
                                Text(option)
                                    .bodyText(weight: selection == option ? .bold : .regular)
                                    .textColor()
                                    .multilineTextAlignment(.leading)
                                
                                if let selection = selection,
                                   selection == option {
                                    Spacer()
                                    
                                    Image(systemName: "checkmark")
                                        .font(.caption)
                                }
                            }
                            .textColor()
                            .padding(.trailing, 1)
                        }
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
