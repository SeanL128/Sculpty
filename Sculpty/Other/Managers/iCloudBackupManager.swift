//
//  iCloudBackupManager.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/6/25.
//

import SwiftUI
import SwiftData

@MainActor
class iCloudBackupManager: ObservableObject {
    @Published var isBackingUp = false
    @Published var isLoadingBackups = false
    @Published var availableBackups: [iCloudBackup] = []
    
    private let backupFolder = "SculptyBackups"
    
    private var iCloudContainer: URL? {
        FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.app.sculpty.SculptyApp")
    }
    
    private var backupDirectoryURL: URL? {
        guard let container = iCloudContainer else { return nil }
        
        return container.appendingPathComponent("Documents").appendingPathComponent(backupFolder)
    }
    
    var isICloudAvailable: Bool {
        iCloudContainer != nil
    }
    
    func backupToiCloud(context: ModelContext) async {
        guard let backupDirectory = backupDirectoryURL else {
            Popup.show(content: {
                InfoPopup(title: "Error", text: "iCloud not available")
            })
            
            return
        }
        
        isBackingUp = true
        
        do {
            try FileManager.default.createDirectory(at: backupDirectory, withIntermediateDirectories: true)
            
            let backupData = await createBackupData(context: context)
            
            guard let data = backupData else {
                Popup.show(content: {
                    InfoPopup(title: "Error", text: "Failed to create backup data. Please try again later.")
                })
                
                isBackingUp = false
                
                return
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
            let timestamp = formatter.string(from: Date())
            let filename = "Sculpty_Backup_\(timestamp).sculptydata"
            
            let backupURL = backupDirectory.appendingPathComponent(filename)
            
            try data.write(to: backupURL)
            
            isBackingUp = false
        } catch {
            Popup.show(content: {
                InfoPopup(title: "Error", text: "Backup failed: \(error.localizedDescription)")
            })
            
            isBackingUp = false
        }
    }
    
    func loadAvailableBackups() async {
        guard let backupDirectory = backupDirectoryURL else {
            Popup.show(content: {
                InfoPopup(title: "Error", text: "iCloud not available")
            })
            
            return
        }
        
        isLoadingBackups = true
        
        do {
            try FileManager.default.createDirectory(at: backupDirectory, withIntermediateDirectories: true)
            
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: backupDirectory,
                includingPropertiesForKeys: [.creationDateKey, .fileSizeKey],
                options: [.skipsHiddenFiles]
            )
            
            let backups = fileURLs
                .filter { $0.pathExtension == "sculptydata" }
                .map { iCloudBackup(url: $0) }
                .sorted()
            
            availableBackups = backups
            isLoadingBackups = false
        } catch {
            Popup.show(content: {
                InfoPopup(title: "Error", text: "Failed to load backups: \(error.localizedDescription)")
            })
            
            isLoadingBackups = false
        }
    }
    
    func restoreFromiCloudBackup(_ backup: iCloudBackup, context: ModelContext) async -> Bool {
        do {
            let data = try Data(contentsOf: backup.url)
            
            try DataTransferManager.shared.importAllData(
                from: data,
                into: context,
                importSettings: true
            )
            
            return true
        } catch {
            Popup.show(content: {
                InfoPopup(title: "Error", text: "Restore failed: \(error.localizedDescription)")
            })
            
            return false
        }
    }
    
    func deleteBackup(_ backup: iCloudBackup) async {
        do {
            try FileManager.default.removeItem(at: backup.url)
            
            await loadAvailableBackups()
        } catch {
            Popup.show(content: {
                InfoPopup(title: "Error", text: "Failed to delete backup: \(error.localizedDescription)")
            })
        }
    }
    
    private var modelContainer: ModelContainer?
    
    func setupAutoBackup(with container: ModelContainer) {
        guard StoreKitManager.shared.hasPremiumAccess else { return }
        
        self.modelContainer = container
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.performAutoBackupIfNeeded()
            }
        }
    }
    
    private func performAutoBackupIfNeeded() async {
        guard StoreKitManager.shared.hasPremiumAccess,
              CloudSettings.shared.enableAutoBackup,
              let container = modelContainer else { return }
        
        let lastBackupTime = UserDefaults.standard.double(forKey: "LAST_AUTO_BACKUP_TIME")
        let now = Date().timeIntervalSince1970
        let hoursSinceLastBackup = (now - lastBackupTime) / 3600
        
        guard hoursSinceLastBackup >= 24 else { return }
        
        let context = ModelContext(container)
        
        await backupToiCloud(context: context)
        
        UserDefaults.standard.set(now, forKey: "LAST_AUTO_BACKUP_TIME")
    }
    
    private func createBackupData(context: ModelContext) async -> Data? {
        return await withCheckedContinuation { continuation in
            Task.detached {
                do {
                    let backgroundContext = ModelContext(context.container)
                    
                    let fetchedExercises = try backgroundContext.fetch(FetchDescriptor<Exercise>())
                    let workouts = try backgroundContext.fetch(FetchDescriptor<Workout>())
                    let workoutLogs = try backgroundContext.fetch(FetchDescriptor<WorkoutLog>())
                    let measurements = try backgroundContext.fetch(FetchDescriptor<Measurement>())
                    let customFoods = try backgroundContext.fetch(FetchDescriptor<CustomFood>())
                    let caloriesLogs = try backgroundContext.fetch(FetchDescriptor<CaloriesLog>())

                    let defaultExerciseIDs = Set(defaultExercises.map { $0.id })
                    let filteredExercises = fetchedExercises.filter { !defaultExerciseIDs.contains($0.id) }
                    
                    let data = AppDataDTO.export(
                        exercises: filteredExercises,
                        workouts: workouts,
                        workoutLogs: workoutLogs,
                        measurements: measurements,
                        customFoods: customFoods,
                        caloriesLogs: caloriesLogs,
                        includeSettings: true
                    )
                    
                    continuation.resume(returning: data)
                } catch {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
