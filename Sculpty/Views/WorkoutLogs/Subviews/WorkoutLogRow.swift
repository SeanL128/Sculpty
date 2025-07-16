//
//  WorkoutLogRow.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI
import SwiftData

struct WorkoutLogRow: View {
    @Environment(\.modelContext) private var context
    
    let log: WorkoutLog
    
    @State private var confirmDelete: Bool = false
    @State private var logToDelete: WorkoutLog?
    
    var body: some View {
        HStack(alignment: .center) {
            NavigationLink {
                WorkoutLogView(log: log)
            } label: {
                HStack(alignment: .center) {
                    Text(formatDateWithTime(log.start))
                        .bodyText(size: 16)
                        .multilineTextAlignment(.leading)
                    
                    Image(systemName: "chevron.right")
                        .padding(.leading, -2)
                        .font(Font.system(size: 10))
                }
            }
            .textColor()
            .animatedButton(scale: 0.98)
            
            Spacer()
            
            Button {
                logToDelete = log
                
                Popup.show(content: {
                    ConfirmationPopup(
                        selection: $confirmDelete,
                        promptText: "Delete log from \(formatDateWithTime(log.start)))?",
                        resultText: "This cannot be undone.",
                        cancelText: "Cancel",
                        confirmText: "Delete"
                    )
                })
            } label: {
                Image(systemName: "xmark")
                    .padding(.horizontal, 8)
                    .font(Font.system(size: 16))
            }
            .textColor()
            .animatedButton(feedback: .warning)
            .onChange(of: confirmDelete) {
                if confirmDelete,
                   let log = logToDelete {
                    context.delete(log)
                    
                    do {
                        try context.save()
                    } catch {
                        debugLog("Error: \(error.localizedDescription)")
                    }
                    
                    confirmDelete = false
                    logToDelete = nil
                }
            }
        }
        .padding(.trailing, 1)
    }
}
