//
//  MeasurementMenuPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/4/25.
//

import SwiftUI
import MijickPopups

struct MeasurementMenuPopup: CenterPopup {
    @Binding private var selection: MeasurementType
    
    private var options: [String : MeasurementType]
    
    init(options: [String : MeasurementType], selection: Binding<MeasurementType>) {
        self.options = options
        
        self._selection = selection
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 12) {
                ForEach(options.sorted { MeasurementType.displayOrder.firstIndex(of: $0.value)! < MeasurementType.displayOrder.firstIndex(of: $1.value)! }, id: \.key) { str, type in
                    Button {
                        selection = type
                        
                        Task {
                            await dismissLastPopup()
                        }
                    } label: {
                        HStack(alignment: .center) {
                            Text(str)
                                .bodyText(size: 16, weight: selection == type ? .bold : .regular)
                            
                            Image(systemName: "chevron.right")
                                .padding(.leading, -2)
                                .font(Font.system(size: 10))
                        }
                    }
                    .textColor()
                }
            }
            .padding(.vertical, 20)
        }
        .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .padding(.horizontal, 8)
    }
    
    func configurePopup(config: CenterPopupConfig) -> CenterPopupConfig {
        config
            .backgroundColor(ColorManager.background)
            .popupHorizontalPadding(24)
    }
}
