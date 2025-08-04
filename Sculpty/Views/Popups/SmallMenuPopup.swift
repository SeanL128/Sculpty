//
//  SmallMenuPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/28/25.
//

import SwiftUI

struct SmallMenuPopup: View {
    private var title: String
    private var options: [String]
    
    @Binding var selection: String
    
    init(title: String, options: [String], selection: Binding<String>) {
        self.title = title
        self.options = options
        self._selection = selection
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            HStack(alignment: .center) {
                Spacer()
                
                Text(title)
                    .subheadingText()
                    .textColor()
                    .multilineTextAlignment(.center)
                
                Spacer()
            }

            HStack(spacing: .spacingXS) {
                ForEach(Array(options.enumerated()), id: \.element.self) { index, option in
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selection = option
                        }
                        
                        Popup.dismissLast()
                    } label: {
                        HStack(alignment: .center, spacing: .spacingXS) {
                            Text(option)
                                .bodyText(weight: selection == option ? .bold : .regular)
                                .textColor()

                            if selection == option {
                                Image(systemName: "checkmark")
                                    .bodyImage(weight: .bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .textColor()
                    .animatedButton(feedback: .selection)
                    
                    if index < options.count - 1 {
                        Divider()
                            .frame(height: 24)
                            .background(ColorManager.text)
                    }
                }
            }
        }
    }
}
