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
    
    var onDismiss: (() -> Void)?
    
    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .bodyText()
            
            Spacer()
            
            Button {
                Popup.show(content: {
                    popup
                }, onDismiss: { onDismiss?() })
            } label: {
                HStack(alignment: .center, spacing: .spacingXS) {
                    Text(text)
                        .bodyText()
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .captionText(weight: .bold)
                }
            }
            .textColor()
            .animatedButton(feedback: .selection)
        }
    }
}
