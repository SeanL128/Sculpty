//
//  BackupRestorePopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/6/25.
//

import SwiftUI
import SwiftData

struct BackupRestorePopup: View {
    @Environment(\.modelContext) private var context
    
    @EnvironmentObject private var settings: CloudSettings
    
    @ObservedObject var iCloudManager: iCloudBackupManager
    
    @State private var confirmRestore: Bool = false
    @State private var restoringFromLocalBackup: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: .listSpacing) {
            Button {
                if settings.onboarded {
                    Popup.show(content: {
                        ConfirmationPopup(
                            selection: $confirmRestore,
                            promptText: "Restore from Backup?",
                            resultText: "This will replace all current data with the backup you import",
                            confirmText: "Restore"
                        )
                    })
                } else {
                    restoringFromLocalBackup = true
                }
            } label: {
                HStack(alignment: .center, spacing: .spacingXS) {
                    Text("Restore from Local Backup")
                        .bodyText(weight: .regular)
                        .multilineTextAlignment(.leading)
                    
                    Image(systemName: "chevron.right")
                        .bodyImage(weight: .medium)
                }
            }
            .textColor()
            .animatedButton(feedback: .selection)
            .onChange(of: confirmRestore) {
                if confirmRestore {
                    restoringFromLocalBackup = true
                }
            }
            
            Button {
                Popup.show(content: {
                    iCloudBackupListPopup(iCloudManager: iCloudManager)
                })
            } label: {
                HStack(alignment: .center, spacing: .spacingXS) {
                    Text("Restore from iCloud Backup")
                        .bodyText(weight: .regular)
                        .multilineTextAlignment(.leading)
                    
                    Image(systemName: "chevron.right")
                        .bodyImage(weight: .medium)
                }
            }
            .textColor()
            .animatedButton(feedback: .selection)
        }
        .fileImporter(
            isPresented: $restoringFromLocalBackup,
            allowedContentTypes: [.sculptyData],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                
                guard url.startAccessingSecurityScopedResource() else {
                    Popup.show(content: {
                        InfoPopup(
                            title: "Error",
                            text: "There was an error when attempting to restore your data. Please make sure that you are uploading the correct file." // swiftlint:disable:this line_length
                        )
                    })
                    
                    return
                }
                
                guard let importedData = try? Data(contentsOf: url) else {
                    url.stopAccessingSecurityScopedResource()
                    
                    Popup.show(content: {
                        InfoPopup(
                            title: "Error",
                            text: "There was an error when attempting to restore your data. Please make sure that you are uploading the correct file." // swiftlint:disable:this line_length
                        )
                    })
                    
                    return
                }
                
                url.stopAccessingSecurityScopedResource()
                
                Task {
                    do {
                        try DataTransferManager.shared.importAllData(
                            from: importedData,
                            into: context,
                            importSettings: true
                        )
                        
                        await MainActor.run {
                            Toast.show("Data imported successfully", "square.and.arrow.down.badge.checkmark")
                            
                            if !settings.onboarded {
                                withAnimation {
                                    settings.onboarded = true
                                }
                            }
                            
                            Popup.dismissAll()
                        }
                    } catch {
                        debugLog("Failed to import data: \(error.localizedDescription)")
                        
                        await MainActor.run {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                Popup.show(content: {
                                    InfoPopup(
                                        title: "Error",
                                        text: "There was an error when attempting to restore your data. Please make sure that you are uploading the correct file." // swiftlint:disable:this line_length
                                    )
                                })
                            }
                        }
                    }
                }
                
                restoringFromLocalBackup = false
                
                if !settings.onboarded {
                    withAnimation {
                        settings.onboarded = true
                    }
                }
                
                Popup.dismissAll()
            case .failure(let error):
                debugLog(error.localizedDescription)
                
                Popup.show(content: {
                    InfoPopup(
                        title: "Error",
                        text: "There was an error when attempting to restore your data. Please make sure that you are uploading the correct file." // swiftlint:disable:this line_length
                    )
                })
            }
        }
    }
}
