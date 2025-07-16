//
//  MeasurementMenuPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/4/25.
//

import SwiftUI

struct MeasurementMenuPopup: View {
    @Binding private var selection: MeasurementType
    
    private var options: [String: MeasurementType]
    
    init(options: [String: MeasurementType], selection: Binding<MeasurementType>) {
        self.options = options
        
        self._selection = selection
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            ForEach(options.sorted { MeasurementType.displayOrder.firstIndex(of: $0.value)! < MeasurementType.displayOrder.firstIndex(of: $1.value)! }, id: \.key) { str, type in // swiftlint:disable:this line_length force_unwrapping
                Button {
                    selection = type
                    
                    Popup.dismissLast()
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
                .animatedButton(scale: 0.98, feedback: .selection)
            }
        }
    }
}
