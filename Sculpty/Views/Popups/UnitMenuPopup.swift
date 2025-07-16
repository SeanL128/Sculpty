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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Spacer()
                
                Text("Units")
                    .bodyText(size: 18, weight: .bold)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                // Imperial
                Button {
                    selection = "Imperial"
                    
                    Popup.dismissLast()
                } label: {
                    HStack(alignment: .center) {
                        Text("Imperial (mi, ft, in, lbs)")
                            .bodyText(size: 16, weight: selection == "Imperial" ? .bold : .regular)
                            .textColor()
                            .multilineTextAlignment(.leading)
                        
                        if selection == "Imperial" {
                            Spacer()
                            
                            Image(systemName: "checkmark")
                                .padding(.horizontal, 8)
                                .font(Font.system(size: 16))
                        }
                    }
                }
                .textColor()
                .animatedButton(scale: 0.98, feedback: .selection)
                
                // Metric
                Button {
                    selection = "Metric"
                    
                    Popup.dismissLast()
                } label: {
                    HStack(alignment: .center) {
                        Text("Metric (km, m, cm, kg)")
                            .bodyText(size: 16, weight: selection == "Metric" ? .bold : .regular)
                            .textColor()
                            .multilineTextAlignment(.leading)
                        
                        if selection == "Metric" {
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
    }
}
