//
//  DurationSelectionPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 6/7/25.
//

import SwiftUI

struct DurationSelectionPopup: View {
    private var title: String

    @Binding private var hours: Int
    private var showHours: Bool

    @Binding private var minutes: Int
    private var showMinutes: Bool

    @Binding private var seconds: Int
    private var showSeconds: Bool
    
    init(
        title: String,
        hours: Binding<Int>? = nil,
        minutes: Binding<Int>? = nil,
        seconds: Binding<Int>? = nil
    ) {
        self.title = title

        _hours = hours ?? .constant(0)
        showHours = hours != nil

        _minutes = minutes ?? .constant(0)
        showMinutes = minutes != nil

        _seconds = seconds ?? .constant(0)
        showSeconds = seconds != nil
    }

    var body: some View {
        VStack(alignment: .center, spacing: .spacingL) {
            VStack(alignment: .center, spacing: .spacingM) {
                Text(title)
                    .subheadingText()
                    .textColor()

                HStack(spacing: .spacingM) {
                    if showHours {
                        Picker("Hours", selection: $hours) {
                            ForEach(0..<24, id: \.self) { Text("\($0) hr").tag($0) }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: 160)
                        .clipped()
                    }

                    if showMinutes {
                        Picker("Minutes", selection: $minutes) {
                            ForEach(0..<60, id: \.self) { Text("\($0) min").tag($0) }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: 160)
                        .clipped()
                    }

                    if showSeconds {
                        Picker("Seconds", selection: $seconds) {
                            ForEach(0..<60, id: \.self) { Text("\($0) sec").tag($0) }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: 160)
                        .clipped()
                    }
                }
                .padding(.spacingXS)
                .frame(maxHeight: 200)
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
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .animatedButton()
            }
        }
    }
}
