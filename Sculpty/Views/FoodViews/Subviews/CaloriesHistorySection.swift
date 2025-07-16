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
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .center) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            open.toggle()
                        }
                    } label: {
                        HStack(alignment: .center) {
                            Text(formatDate(log.date))
                                .headingText(size: 16)
                            
                            Image(systemName: "chevron.down")
                                .font(Font.system(size: 10, weight: .bold))
                                .rotationEffect(.degrees(open ? -180 : 0))
                                .animation(.easeInOut(duration: 0.5), value: open)
                        }
                    }
                    .animatedButton()
                    
                    Spacer()
                    
                    NavigationLink {
                        SearchFood(log: log)
                    } label: {
                        Image(systemName: "plus")
                            .padding(.horizontal, 5)
                            .font(Font.system(size: 16))
                    }
                    .animatedButton()
                }
                .textColor()
                
                Text("\(log.getTotalCalories().formatted())cal")
                    .statsText(size: 12)
                    .secondaryColor()
            }
            .padding(.bottom, -8)
            
            if open {
                ForEach(log.entries.sorted { $0.date < $1.date }, id: \.id) { entry in
                    FoodEntryRow(
                        entry: entry,
                        log: log
                    )
                }
            }
        }
    }
}
