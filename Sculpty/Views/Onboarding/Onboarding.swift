//
//  Onboarding.swift
//  Sculpty
//
//  Created by Sean Lindsay on 4/12/25.
//

import SwiftUI
import SwiftData

struct Onboarding: View {
    @Environment(\.modelContext) private var context
    
    @EnvironmentObject private var settings: CloudSettings
    
    @State private var restoring: Bool = false
    
    @State private var sectionsVisible: Bool = false
    
    var body: some View {
        ZStack {
            ColorManager.background
                .ignoresSafeArea(edges: .all)
            
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 350, height: 350)
                .opacity(0.9)
                .blur(radius: 400)
            
            VStack {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 250, height: 250)
                        .opacity(0.35)
                        .blur(radius: 100)
                        .rotationEffect(.degrees(sectionsVisible ? 360 : 0))
                        .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: sectionsVisible)

                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 200, height: 200)
                        .opacity(0.475)
                        .blur(radius: 30)
                        .rotationEffect(.degrees(sectionsVisible ? -180 : 0))
                        .animation(.linear(duration: 15).repeatForever(autoreverses: false), value: sectionsVisible)
                    
                    Text("SCULPTY")
                        .headingText(size: 44)
                        .textColor()
                        .scaleEffect(sectionsVisible ? 1.0 : 0.8)
                        .opacity(sectionsVisible ? 1.0 : 0.7)
                }
                .padding(.top, 5)
                .padding(.bottom, -10)
                .frame(height: 190)
                
                HStack {
                    VStack(alignment: .leading, spacing: 17) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("YOUR FITNESS JOURNAL")
                                .headingText(size: 24)
                                .textColor()
                            
                            Text("Simple. Powerful. Yours.")
                                .bodyText(size: 16)
                                .secondaryColor()
                        }
                        
                        OnboardingSection(
                            title: "Workouts",
                            description: "Log your workouts. See your progress."
                        )
                        .opacity(sectionsVisible ? 1.0 : 0.0)
                        .offset(x: sectionsVisible ? 0 : -20)
                        .animation(.easeInOut(duration: 0.4).delay(0.1), value: sectionsVisible)

                        OnboardingSection(
                            title: "Calories",
                            description: "Monitor your daily intake and macros."
                        )
                        .opacity(sectionsVisible ? 1.0 : 0.0)
                        .offset(x: sectionsVisible ? 0 : -20)
                        .animation(.easeInOut(duration: 0.4).delay(0.2), value: sectionsVisible)

                        OnboardingSection(
                            title: "Measurements",
                            description: "Record body measurements. Visualize your progress."
                        )
                        .opacity(sectionsVisible ? 1.0 : 0.0)
                        .offset(x: sectionsVisible ? 0 : -20)
                        .animation(.easeInOut(duration: 0.4).delay(0.3), value: sectionsVisible)

                        OnboardingSection(
                            title: "Stats",
                            description: "View trends and insights based on your recorded data."
                        )
                        .opacity(sectionsVisible ? 1.0 : 0.0)
                        .offset(x: sectionsVisible ? 0 : -20)
                        .animation(.easeInOut(duration: 0.4).delay(0.4), value: sectionsVisible)
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your data stays private. No recommendations. No ads. Just tools.")
                                .bodyText(size: 14)
                                .secondaryColor()
                                .fixedSize(horizontal: false, vertical: true)
                                .opacity(sectionsVisible ? 1.0 : 0.0)
                                .offset(y: sectionsVisible ? 0 : 10)
                                .animation(.easeInOut(duration: 0.4).delay(0.5), value: sectionsVisible)
                            
                            Button {
                                preloadData()
                                
                                withAnimation {
                                    settings.onboarded = true
                                }
                            } label: {
                                Text("GET STARTED")
                                    .bodyText(size: 16)
                                    .frame(maxWidth: .infinity)
                            }
                            .filledToBorderedButton(feedback: .selection)
                            
                            Button {
                                restoring = true
                            } label: {
                                Text("RESTORE FROM BACKUP")
                                    .bodyText(size: 16)
                                    .frame(maxWidth: .infinity)
                            }
                            .borderedToFilledButton(feedback: .selection)
                        }
                        .opacity(sectionsVisible ? 1.0 : 0.0)
                        .offset(y: sectionsVisible ? 0 : 20)
                        .animation(.easeInOut(duration: 0.5).delay(0.6), value: sectionsVisible)
                    }
                    
                    Spacer()
                }
                .padding(.top, 25)
                .padding(.bottom)
                .padding(.horizontal)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.6).delay(0.3)) {
                        sectionsVisible = true
                    }
                }
                .fileImporter(
                    isPresented: $restoring,
                    allowedContentTypes: [.sculptyData],
                    allowsMultipleSelection: false
                ) { result in
                    switch result {
                    case .success(let urls):
                        guard let url = urls.first else { return }
                        
                        guard url.startAccessingSecurityScopedResource() else {
                            restoreFailAlert()
                            
                            return
                        }
                        
                        guard let importedData = try? Data(contentsOf: url) else {
                            url.stopAccessingSecurityScopedResource()
                            restoreFailAlert()
                            
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
                                    withAnimation {
                                        settings.onboarded = true
                                    }
                                }
                            } catch {
                                debugLog("Failed to import data: \(error.localizedDescription)")
                                
                                await MainActor.run {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        restoreFailAlert()
                                    }
                                }
                            }
                        }
                        
                        restoring = false
                        
                        withAnimation {
                            settings.onboarded = true
                        }
                    case .failure(let error):
                        debugLog(error.localizedDescription)
                        
                        restoreFailAlert()
                    }
                }
            }
        }
    }
    
    private func restoreFailAlert() {
        Popup.show(content: {
            InfoPopup(
                title: "Error",
                text: "There was an error when attempting to restore your data. Please make sure that you are uploading the correct file." // swiftlint:disable:this line_length
            )
        })
    }
    
    private func preloadData() {
        if let existingExercises = try? context.fetch(FetchDescriptor<Exercise>()), existingExercises.isEmpty {
            for exercise in defaultExercises {
                context.insert(exercise)
            }
            
            do {
                try context.save()
            } catch {
                debugLog("Error preloading data: \(error.localizedDescription)")
            }
        }
    }
}
