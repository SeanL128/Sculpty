//
//  LabeledTypedSegmentedControl.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct LabeledTypedSegmentedControl<T: Hashable>: View {
    let label: String
    @Binding var selection: T
    let options: [T]
    let displayNames: [String]
    
    init(
        label: String,
        selection: Binding<T>,
        options: [T],
        displayNames: [String]
    ) {
        self.label = label
        self._selection = selection
        self.options = options
        self.displayNames = displayNames
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingXS) {
            Text(label)
                .captionText()
                .textColor()
            
            TypedSegmentedControl(
                selection: $selection,
                options: options,
                displayNames: displayNames
            )
        }
    }
}
