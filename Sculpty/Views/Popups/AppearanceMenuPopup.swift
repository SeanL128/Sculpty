//
//  AppearanceMenuPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/16/25.
//

import SwiftUI

struct AppearanceMenuPopup: View {
    @Binding var selection: Appearance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Spacer()
                
                Text("Appearance")
                    .bodyText(size: 18, weight: .bold)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Appearance.displayOrder, id: \.self) { appearance in
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selection = appearance
                        }
                        
                        Popup.dismissLast()
                    } label: {
                        HStack(alignment: .center) {
                            Text(appearance.rawValue)
                                .bodyText(size: 16, weight: selection == appearance ? .bold : .regular)
                                .textColor()
                                .multilineTextAlignment(.leading)
                            
                            if selection == appearance {
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
