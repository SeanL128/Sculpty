//
//  MoveSlideButton.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/10/25.
//

import SwiftUI

struct MoveSlideButton: View {
    @Binding var selectedTab: Int
    var lastTab: Int
    
    var body: some View {
        HStack {
            if selectedTab > 0 {
                Button {
                    withAnimation {
                        selectedTab -= 1
                    }
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .padding(.horizontal, 20)
            } else {
                Spacer().frame(width: 80)
            }
            
            Spacer()
            
            if selectedTab < lastTab {
                Button {
                    withAnimation {
                        selectedTab += 1
                    }
                } label: {
                    HStack {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.horizontal, 20)
            } else {
                Spacer().frame(width: 80)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 10)
        .padding(.bottom, 30)
    }
}

#Preview {
    MoveSlideButton(selectedTab: .constant(0), lastTab: 5)
}
