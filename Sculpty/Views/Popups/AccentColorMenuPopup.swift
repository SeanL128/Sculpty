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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Spacer()
                
                Text("Accent Color")
                    .bodyText(size: 18, weight: .bold)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(AccentColor.displayOrder, id: \.self) { color in
                    let hex = AccentColor.colorMap[color] ?? "#2B7EFF"
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selection = hex
                        }
                        
                        Popup.dismissLast()
                    } label: {
                        HStack(alignment: .center) {
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 10, height: 10)
                            
                            Text(color.rawValue)
                                .bodyText(size: 18, weight: selection == hex ? .bold : .regular)
                                .textColor()
                                .multilineTextAlignment(.leading)
                            
                            if selection == hex {
                                Spacer()
                                
                                Image(systemName: "checkmark")
                                    .padding(.horizontal, 8)
                                    .font(Font.system(size: 16))
                            }
                        }
                    }
                    .textColor()
                    .animatedButton(scale: 0.98, feedback: .selection)
                }
            }
            .padding(.horizontal, 5)
        }
    }
}
