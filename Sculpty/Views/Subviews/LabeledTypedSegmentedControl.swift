//
//  LabeledTypedSegmentedControl.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct LabeledTypeSegmentedControl<T: Hashable>: View {
    let label: String
    let size: CGFloat
    @Binding var selection: T
    let options: [T]
    let displayNames: [String]
    
    init(
        label: String,
        size: CGFloat,
        selection: Binding<T>,
        options: [T],
        displayNames: [String]
    ) {
        self.label = label
        self.size = size
        self._selection = selection
        self.options = options
        self.displayNames = displayNames
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .bodyText(size: size)
                .textColor()
            
            TypedSegmentedControl(
                selection: $selection,
                options: options,
                displayNames: displayNames
            )
        }
    }
}
