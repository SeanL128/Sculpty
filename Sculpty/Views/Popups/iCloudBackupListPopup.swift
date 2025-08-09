//
//  iCloudBackupListPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/6/25.
//

import SwiftUI
import SwiftData

struct iCloudBackupListPopup: View {
    @Environment(\.modelContext) private var context
    
    @EnvironmentObject private var settings: CloudSettings
    
    @ObservedObject var iCloudManager: iCloudBackupManager
    
    @State private var confirmRestore: Bool = false
    @State private var selectedBackup: iCloudBackup?
    
    @State private var height: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            HStack {
                Spacer()
                
                Text("Restore from iCloud")
                    .subheadingText()
                    .textColor()
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: .listSpacing) {
                    if iCloudManager.isLoadingBackups {
                        HStack {
                            Spacer()
                            
                            Text("Loading...")
                                .bodyText()
                                .textColor()
                            
                            Spacer()
                        }
                    } else if iCloudManager.availableBackups.isEmpty {
                        HStack {
                            Spacer()
                            
                            EmptyState(
                                image: "tray",
                                text: "No iCloud Backups Found",
                                subtext: "Create your first backup from Options > Data Management",
                                topPadding: 0
                            )
                            
                            Spacer()
                        }
                    } else {
                        ForEach(iCloudManager.availableBackups) { backup in
                            Button {
                                if settings.onboarded {
                                    selectedBackup = backup
                                    
                                    Popup.show(content: {
                                        ConfirmationPopup(
                                            selection: $confirmRestore,
                                            promptText: "Restore from Backup?",
                                            resultText: "This will replace all current data with the backup from \(formatDate(backup.date))", // swiftlint:disable:this line_length
                                            confirmText: "Restore"
                                        )
                                    })
                                } else {
                                    Task {
                                        if await iCloudManager.restoreFromiCloudBackup(backup, context: context) {
                                            Toast.show(
                                                "Data restored successfully",
                                                "square.and.arrow.down.badge.checkmark"
                                            )
                                        }
                                        
                                        selectedBackup = nil
                                        
                                        Popup.dismissAll()
                                    }
                                }
                            } label: {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(formatDateWithTime(backup.date))
                                        .bodyText(weight: .regular)
                                    
                                    Text("\(backup.size) - \(timeAgo(from: backup.date))")
                                        .captionText()
                                        .foregroundStyle(ColorManager.secondary)
                                }
                            }
                            .textColor()
                            .animatedButton(feedback: .selection)
                        }
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
        .task {
            await iCloudManager.loadAvailableBackups()
        }
        .onChange(of: confirmRestore) {
            if confirmRestore,
               let backup = selectedBackup {
                Task {
                    if await iCloudManager.restoreFromiCloudBackup(backup, context: context) {
                        Toast.show("Data restored successfully", "square.and.arrow.down.badge.checkmark")
                    }
                    
                    selectedBackup = nil
                    
                    Popup.dismissAll()
                }
            }
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
