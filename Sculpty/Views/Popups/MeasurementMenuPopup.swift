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
        VStack(alignment: .leading, spacing: .spacingM) {
            HStack(alignment: .center) {
                Spacer()
                
                Text("Measurement")
                    .subheadingText()
                    .textColor()
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: .listSpacing) {
                ForEach(options.sorted { MeasurementType.displayOrder.firstIndex(of: $0.value)! < MeasurementType.displayOrder.firstIndex(of: $1.value)! }, id: \.key) { str, type in // swiftlint:disable:this line_length force_unwrapping
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selection = type
                        }
                        
                        Popup.dismissLast()
                    } label: {
                        HStack(alignment: .center, spacing: .spacingXS) {
                            Text(str)
                                .bodyText(weight: selection == type ? .bold : .regular)
                                .multilineTextAlignment(.leading)
                            
                            Image(systemName: "chevron.right")
                                .bodyImage(weight: selection == type ? .bold : .medium)
                            
                            Spacer()
                            
                            if selection == type {
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
}
