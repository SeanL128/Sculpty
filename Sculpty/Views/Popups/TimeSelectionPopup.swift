//
//  TimeSelectionPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/24/25.
//

import SwiftUI

struct TimeSelectionPopup: View {
    private var title: String
    
    @Binding private var day: Int
    private var showDay: Bool

    @Binding private var time: Date
    
    private let weekdays = [
        (1, "Sun"),
        (2, "Mon"),
        (3, "Tue"),
        (4, "Wed"),
        (5, "Thu"),
        (6, "Fri"),
        (7, "Sat")
    ]
    
    init(
        title: String,
        day: Binding<Int>? = nil,
        time: Binding<Date>
    ) {
        self.title = title
        
        _day = day ?? .constant(0)
        showDay = day != nil

        _time = time
    }

    var body: some View {
        VStack(alignment: .center, spacing: .spacingL) {
            VStack(alignment: .center, spacing: .spacingM) {
                Text(title)
                    .subheadingText()
                    .textColor()
                    .multilineTextAlignment(.center)

                VStack(spacing: .spacingS) {
                    if showDay {
                        TypedSegmentedControl(
                            selection: $day,
                            options: weekdays.sorted { $0.0 < $1.0 }.map { $0.0 },
                            displayNames: weekdays.sorted { $0.0 < $1.0 }.map { $0.1 }
                        )
                    }
                    
                    DatePicker("", selection: $time, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(.wheel)
                    .frame(maxWidth: 275)
                }
            }
            
            VStack(alignment: .center, spacing: .spacingM) {
                Spacer()
                    .frame(height: 0)
                
                Button {
                    Popup.dismissLast()
                } label: {
                    Text("Done")
                        .bodyText()
                        .padding(.vertical, 12)
                        .padding(.horizontal, .spacingL)
                }
                .textColor()
                .background(ColorManager.accent)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .animatedButton(feedback: .selection)
            }
        }
    }
}
