//
//  UnitMenuPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/25/25.
//

import SwiftUI
import MijickPopups

struct UnitMenuPopup: CenterPopup {
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
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Imperial
                    Button {
                        selection = "Imperial"
                        
                        Task {
                            await dismissLastPopup()
                        }
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
                    
                    // Metric
                    Button {
                        selection = "Metric"
                        
                        Task {
                            await dismissLastPopup()
                        }
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
                }
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .padding(.horizontal, 5)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 8)
    }
    
    func configurePopup(config: CenterPopupConfig) -> CenterPopupConfig {
        config
            .backgroundColor(ColorManager.background)
            .popupHorizontalPadding(24)
    }
}
