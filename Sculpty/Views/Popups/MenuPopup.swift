//
//  MenuPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/11/25.
//

import SwiftUI

struct MenuPopup: View {
    private var title: String
    private var options: [String]
    
    @Binding var selection: String?
    
    @State private var height: CGFloat = 0
    
    init(title: String, options: [String], selection: Binding<String?>) {
        self.title = title
        self.options = options
        self._selection = selection
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            HStack(alignment: .center) {
                Spacer()
                
                Text(title)
                    .subheadingText()
                    .textColor()
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            
            ScrollView {
                LazyVStack(spacing: .listSpacing) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                selection = option
                            }
                            
                            Popup.dismissLast()
                        } label: {
                            HStack(alignment: .center, spacing: .spacingXS) {
                                Text(option)
                                    .bodyText(weight: selection == option ? .bold : .medium)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                if selection == option {
                                    Image(systemName: "checkmark")
                                        .bodyText()
                                }
                            }
                        }
                        .textColor()
                        .animatedButton(feedback: .selection)
                    }
                }
                .background(GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                height = geo.size.height
                            }
                        }
                        .onChange(of: geo.size.height) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                height = geo.size.height
                            }
                        }
                })
            }
            .frame(maxHeight: min(height, 300))
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
        }
    }
}
