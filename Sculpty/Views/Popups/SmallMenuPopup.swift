//
//  SmallMenuPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/28/25.
//

import SwiftUI
import MijickPopups

struct SmallMenuPopup: CenterPopup {
    private var title: String
    private var options: [String]
    
    @Binding var selection: String
    
    init(title: String, options: [String], selection: Binding<String>) {
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
                HStack (alignment: .center) {
                    Spacer()
                    
                    ForEach(options, id: \.self) { option in
                        Button {
                            selection = option
                            
                            Task {
                                await dismissLastPopup()
                            }
                        } label: {
                            HStack(alignment: .center) {
                                Text(option)
                                    .bodyText(size: 16, weight: selection == option ? .bold : .regular)
                                    .textColor()
                                    .multilineTextAlignment(.leading)
                                
                                if selection == option {
                                    Image(systemName: "checkmark")
                                        .padding(.leading, 6)
                                        .font(Font.system(size: 16))
                                }
                            }
                        }
                        .textColor()
                        
                        if option != options.last {
                            Divider()
                                .frame(width: 1)
                                .padding(.horizontal, 4)
                        }
                    }
                    
                    Spacer()
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
