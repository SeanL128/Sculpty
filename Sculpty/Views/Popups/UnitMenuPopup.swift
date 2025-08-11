//
//  UnitMenuPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/25/25.
//

import SwiftUI

struct UnitMenuPopup: View {
    @Binding var selection: String
    
    init(selection: Binding<String>) {
        self._selection = selection
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            HStack {
                Spacer()
                
                Text("Units")
                    .subheadingText()
                    .textColor()
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: .spacingM) {
                // Imperial
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selection = "Imperial"
                    }
                    
                    Popup.dismissLast()
                } label: {
                    HStack(alignment: .center) {
                        Text("Imperial (mi, ft, in, lbs)")
                            .bodyText(weight: selection == "Imperial" ? .bold : .medium)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        if selection == "Imperial" {
                            Image(systemName: "checkmark")
                                .bodyText()
                        }
                    }
                }
                .textColor()
                .animatedButton(feedback: .selection)
                
                // Metric
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selection = "Metric"
                    }
                    
                    Popup.dismissLast()
                } label: {
                    HStack(alignment: .center) {
                        Text("Metric (km, m, cm, kg)")
                            .bodyText(weight: selection == "Metric" ? .bold : .medium)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        if selection == "Metric" {
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
