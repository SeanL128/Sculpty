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
    
    @StateObject private var iCloudManager: iCloudBackupManager = iCloudBackupManager()
    
    @State private var sectionsVisible: Bool = false
    
    var body: some View {
        ZStack {
            ColorManager.background
                .ignoresSafeArea(edges: .all)
            
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#2563EB"), Color(hex: "#7C3AED")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 350, height: 350)
                .opacity(0.9)
                .blur(radius: 400)
            
            VStack(alignment: .leading, spacing: .spacingM) {
                HStack {
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "#2563EB"), Color(hex: "#7C3AED")]),
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
                                gradient: Gradient(colors: [Color(hex: "#2563EB"), Color(hex: "#7C3AED")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 200, height: 200)
                            .opacity(0.475)
                            .blur(radius: 30)
                            .rotationEffect(.degrees(sectionsVisible ? -180 : 0))
                            .animation(.linear(duration: 15).repeatForever(autoreverses: false), value: sectionsVisible)
                        
                        Text("SCULPTY")
                            .font(.system(size: 44, weight: .bold))
                            .textColor()
                            .scaleEffect(sectionsVisible ? 1.0 : 0.8)
                            .opacity(sectionsVisible ? 1.0 : 0.7)
                    }
                    .frame(height: 190)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: .spacingS) {
                    Text("YOUR FITNESS JOURNAL")
                        .headingText()
                        .textColor()
                    
                    Text("Simple. Powerful. Yours.")
                        .bodyText()
                        .secondaryColor()
                }
                
                OnboardingSection(
                    title: "Workouts",
                    description: "Log your workouts. See your progress."
                )
                .opacity(sectionsVisible ? 1.0 : 0.0)
                .offset(x: sectionsVisible ? 0 : -20)
                .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.1), value: sectionsVisible)

                OnboardingSection(
                    title: "Calories",
                    description: "Monitor your daily intake and macros."
                )
                .opacity(sectionsVisible ? 1.0 : 0.0)
                .offset(x: sectionsVisible ? 0 : -20)
                .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.2), value: sectionsVisible)

                OnboardingSection(
                    title: "Measurements",
                    description: "Record body measurements. Visualize your progress."
                )
                .opacity(sectionsVisible ? 1.0 : 0.0)
                .offset(x: sectionsVisible ? 0 : -20)
                .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.3), value: sectionsVisible)

                OnboardingSection(
                    title: "Stats",
                    description: "View trends and insights based on your recorded data."
                )
                .opacity(sectionsVisible ? 1.0 : 0.0)
                .offset(x: sectionsVisible ? 0 : -20)
                .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.4), value: sectionsVisible)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: .spacingS) {
                    Text("Your data stays private. No recommendations. No ads. Just tools.")
                        .secondaryText()
                        .secondaryColor()
                        .fixedSize(horizontal: false, vertical: true)
                        .opacity(sectionsVisible ? 1.0 : 0.0)
                        .offset(y: sectionsVisible ? 0 : 10)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.5), value: sectionsVisible)
                    
                    Button {
                        if let existingExercises = try? context.fetch(FetchDescriptor<Exercise>()),
                           existingExercises.isEmpty {
                            for exercise in defaultExercises {
                                context.insert(exercise)
                            }
                            
                            do {
                                try context.save()
                            } catch {
                                debugLog("Error preloading data: \(error.localizedDescription)")
                            }
                        }
                        
                        withAnimation {
                            settings.onboarded = true
                        }
                    } label: {
                        Text("GET STARTED")
                            .bodyText()
                            .frame(maxWidth: .infinity)
                    }
                    .filledToBorderedButton()
                    
                    Button {
                        Popup.show(content: {
                            BackupRestorePopup(iCloudManager: iCloudManager)
                        })
                    } label: {
                        Text("RESTORE FROM BACKUP")
                            .bodyText()
                            .frame(maxWidth: .infinity)
                    }
                    .borderedToFilledButton()
                }
                .opacity(sectionsVisible ? 1.0 : 0.0)
                .offset(y: sectionsVisible ? 0 : 20)
                .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.6), value: sectionsVisible)
            }
            .padding(.top, .spacingM)
            .padding(.bottom, .spacingXS)
            .padding(.horizontal, .spacingL)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.3)) {
                sectionsVisible = true
            }
        }
    }
}
