//
//  CaloriesHistorySection.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct CaloriesHistorySection: View {
    let log: CaloriesLog
    
    @State private var open: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingXS) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            open.toggle()
                        }
                    } label: {
                        HStack(alignment: .center, spacing: .spacingS) {
                            Text(formatDate(log.date))
                                .subheadingText()
                                .multilineTextAlignment(.leading)
                            
                            Image(systemName: "chevron.down")
                                .subheadingImage(weight: .medium)
                                .rotationEffect(.degrees(open ? -180 : 0))
                        }
                    }
                    .animatedButton()
                    .textColor()
                    
                    Spacer()
                    
                    NavigationLink {
                        SearchFood(log: log)
                    } label: {
                        Image(systemName: "plus")
                            .bodyText()
                    }
                    .animatedButton()
                }
                
                Text("\(Int(log.getTotalCalories()))cal")
                    .bodyText(weight: .regular)
                    .secondaryColor()
                    .monospacedDigit()
            }
            .padding(.bottom, open ? .spacingXS : 0)
            
            if open {
                VStack(alignment: .leading, spacing: .listSpacing) {
                    ForEach(log.entries.sorted { $0.date < $1.date }, id: \.id) { entry in
                        FoodEntryRow(
                            entry: entry,
                            log: log
                        )
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .bottom))
                        ))
                    }
                    .animation(.easeInOut(duration: 0.3), value: log.entries)
                }
            }
        }
        .padding(.bottom, open ? 0 : -.listSpacing)
    }
}
