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
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .bodyText(size: 18, weight: .bold)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)

            HStack(spacing: 0) {
                ForEach(Array(options.enumerated()), id: \.element.self) { index, option in
                    Button {
                        selection = option
                        
                        Popup.dismissLast()
                    } label: {
                        HStack(spacing: 6) {
                            Text(option)
                                .bodyText(size: 16, weight: selection == option ? .bold : .regular)
                                .textColor()

                            if selection == option {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .medium))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                    .textColor()
                    .animatedButton(scale: 0.98, feedback: .selection)
                    
                    if index < options.count - 1 {
                        Divider()
                            .frame(height: 24)
                            .padding(.horizontal, 4)
                            .background(ColorManager.text)
                    }
                }
            }
        }
    }
}
