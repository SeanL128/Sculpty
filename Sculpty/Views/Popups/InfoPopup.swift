//
//  InfoPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 4/27/25.
//

import SwiftUI
import MijickPopups

struct InfoPopup: CenterPopup {
    private var title: String
    private var text: String
    
    init(title: String, text: String) {
        self.title = title
        self.text = text
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            VStack (alignment: .center, spacing: 8){
                Text(title)
                    .bodyText(size: 18, weight: .bold)
                    .multilineTextAlignment(.center)
                
                Text(text)
                    .bodyText()
                    .textColor()
                    .multilineTextAlignment(.center)
            }
            
            Button {
                Task {
                    await dismissLastPopup()
                }
            } label: {
                Text("OK")
                    .bodyText(size: 18, weight: .bold)
            }
            .textColor()
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
