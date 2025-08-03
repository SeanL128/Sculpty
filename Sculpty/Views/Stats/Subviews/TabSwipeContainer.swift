//
//  TabSwipeContainer.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct TabSwipeContainer: View {
    let selectedTab: Int
    let content: [AnyView]

    var body: some View {
        let width = UIScreen.main.bounds.width

        ZStack(alignment: .topLeading) {
            ForEach(content.indices, id: \.self) { index in
                content[index]
                    .offset(x: CGFloat(index - selectedTab) * width)
            }
        }
        .animation(.easeInOut, value: selectedTab)
    }
}
