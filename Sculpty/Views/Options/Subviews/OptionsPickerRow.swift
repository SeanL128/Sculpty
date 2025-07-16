//
//  OptionsPickerRow.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI

struct OptionsPickerRow<PopupContent: View>: View {
    let title: String
    let text: String
    
    let popup: PopupContent
    
    var body: some View {
        HStack {
            Text(title)
                .bodyText(size: 18)
            
            Spacer()
            
            Button {
                Popup.show(content: {
                    popup
                })
            } label: {
                HStack(alignment: .center) {
                    Text(text)
                        .bodyText(size: 18, weight: .bold)
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .font(Font.system(size: 12, weight: .bold))
                }
            }
            .textColor()
            .animatedButton(scale: 0.98)
        }
    }
}
