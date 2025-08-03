//
//  TabSelector.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct TabSelector: View {
    let tabs: [String]
    @Binding var selected: Int
    var animation: Namespace.ID

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                ForEach(tabs.indices, id: \.self) { index in
                    VStack(spacing: .spacingXS) {
                        Text(tabs[index])
                            .secondaryText(weight: .bold)
                            .foregroundStyle(selected == index ? ColorManager.text : ColorManager.secondary)
                            .frame(maxWidth: .infinity)

                        if selected == index {
                            Rectangle()
                                .fill(ColorManager.text)
                                .frame(height: 3)
                                .matchedGeometryEffect(id: "underline", in: animation)
                        } else {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 3)
                        }
                    }
                    .frame(width: geo.size.width / CGFloat(tabs.count))
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selected = index
                        }
                    }
                }
            }
        }
        .frame(height: 20)
    }
}
