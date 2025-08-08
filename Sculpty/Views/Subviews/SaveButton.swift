//
//  SaveButton.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct SaveButton: View {
    let save: () async -> Void
    let isValid: Bool
    
    @State private var isSaving: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: .spacingM) {
            Spacer()
                .frame(height: 0)
            
            Button {
                if isValid && !isSaving {
                    performSave()
                }
            } label: {
                HStack(alignment: .center, spacing: .spacingS) {
                    if isSaving {
                        ProgressView()
                            .scaleEffect(0.8)
                            .frame(width: 20, height: 20)
                            .tint(isValid && !isSaving ? ColorManager.text : ColorManager.secondary)
                    }
                    
                    Text("Save")
                        .bodyText()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, isSaving ? .spacingM : .spacingL)
            }
            .foregroundStyle(isValid && !isSaving ? ColorManager.text : ColorManager.secondary)
            .background(isValid && !isSaving ? Color.accentColor : ColorManager.secondary.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(!isValid || isSaving)
            .animatedButton(feedback: .success, isValid: isValid && !isSaving)
            .animation(.easeInOut(duration: 0.2), value: isValid)
            .animation(.easeInOut(duration: 0.2), value: isSaving)
        }
    }
    
    private func performSave() {
        isSaving = true
        
        Task { @MainActor in
            await save()
            
            isSaving = false
        }
    }
}
