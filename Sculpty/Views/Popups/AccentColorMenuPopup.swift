//
//  AccentColorMenuPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/16/25.
//

import SwiftUI

struct AccentColorMenuPopup: View {
    @Binding var selection: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            HStack {
                Spacer()
                
                Text("Accent Color")
                    .subheadingText()
                    .textColor()
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: .listSpacing) {
                ForEach(AccentColor.displayOrder, id: \.self) { color in
                    let hex = AccentColor.colorMap[color] ?? "#2563EB"
                    
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selection = hex
                        }
                        
                        Popup.dismissLast()
                    } label: {
                        HStack(alignment: .center, spacing: .spacingS) {
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 8, height: 8)
                            
                            HStack(alignment: .center, spacing: .spacingXS) {
                                Text(color.rawValue)
                                    .bodyText(weight: selection == hex ? .bold : .regular)
                                    .multilineTextAlignment(.leading)
                                
                                Image(systemName: "chevron.right")
                                    .bodyImage(weight: selection == hex ? .bold : .medium)
                            }
                            
                            Spacer()
                            
                            if selection == hex {
                                Image(systemName: "checkmark")
                                    .bodyText()
                            }
                        }
                    }
                    .textColor()
                    .animatedButton(feedback: .selection)
                }
            }
        }
    }
}
