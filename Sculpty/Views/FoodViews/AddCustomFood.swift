//
//  AddCustomFood.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/5/25.
//

import SwiftUI
import SwiftData

struct AddCustomFood: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var storeManager: StoreKitManager = StoreKitManager.shared
    
    @State private var food: CustomFood?
    
    @Binding private var foodToAdd: CustomFood?
    
    @State private var name: String
    @State private var servingOptions: [CustomServing]
    
    @State private var confirmDelete: Bool = false
    @State private var stayOnPage: Bool = true
    
    @FocusState private var isNameFocused: Bool
    
    @State private var hasUnsavedChanges: Bool = false
    
    @State private var dismissTrigger: Int = 0
    
    private var isValid: Bool {
        storeManager.hasPremiumAccess &&
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        servingOptions.contains(where: { !$0.desc.trimmingCharacters(in: .whitespaces).isEmpty })
    }
    
    init(foodToAdd: Binding<CustomFood?> = .constant(nil)) {
        name = ""
        servingOptions = []
        
        self._foodToAdd = foodToAdd
    }
    
    init(food: CustomFood, foodToAdd: Binding<CustomFood?> = .constant(nil)) {
        self.food = food
        
        name = food.name
        servingOptions = food.servingOptions
        
        self._foodToAdd = foodToAdd
    }
    
    var body: some View {
        CustomActionContainerView(
            title: "\(food == nil ? "Add" : "Edit") Food",
            spacing: .spacingXXL,
            onDismiss: {
                if hasUnsavedChanges {
                    dismissTrigger += 1
                    
                    Popup.show(content: {
                        ConfirmationPopup(
                            selection: $stayOnPage,
                            promptText: "Unsaved Changes",
                            resultText: "Are you sure you want to leave without saving?",
                            cancelText: "Discard Changes",
                            cancelColor: ColorManager.destructive,
                            cancelFeedback: .impact(weight: .medium),
                            confirmText: "Stay on Page",
                            confirmColor: ColorManager.text,
                            confirmFeedback: .selection
                        )
                    })
                } else {
                    dismiss()
                }
            }, trailingItems: {
                if let food = food {
                    Button {
                        Popup.show(content: {
                            ConfirmationPopup(
                                selection: $confirmDelete,
                                promptText: "Delete \(name)?",
                                resultText: "This cannot be undone.",
                                cancelText: "Cancel",
                                confirmText: "Delete"
                            )
                        })
                    } label: {
                        Image(systemName: "trash")
                            .pageTitleImage()
                    }
                    .textColor()
                    .animatedButton(feedback: .warning)
                    .onChange(of: confirmDelete) {
                        if confirmDelete {
                            do {
                                food.hide()
                                
                                try context.save()
                                
                                Toast.show("\(food.name) deleted", "trash")
                                
                                hasUnsavedChanges = false
                                
                                dismiss()
                            } catch {
                                debugLog("Error: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
        ) {
            VStack(alignment: .leading, spacing: .spacingXL) {
                Input(
                    title: "Name",
                    text: $name,
                    isFocused: _isNameFocused,
                    autoCapitalization: .words
                )
                
                if !servingOptions.isEmpty {
                    VStack(alignment: .leading, spacing: .listSpacing) {
                        ForEach(Array(servingOptions.enumerated()).sorted { $0.element.index < $1.element.index }, id: \.element.id) { index, serving in // swiftlint:disable:this line_length
                            HStack(alignment: .center) {
                                Button {
                                    Popup.show(content: {
                                        EditServingPopup(serving: $servingOptions[index])
                                    })
                                } label: {
                                    HStack(alignment: .center, spacing: .spacingXS) {
                                        Text(serving.desc.isEmpty ? "Serving" : serving.desc)
                                            .bodyText()
                                        
                                        Image(systemName: "chevron.up.chevron.down")
                                            .captionText(weight: .medium)
                                    }
                                }
                                .textColor()
                                .animatedButton(feedback: .selection)
                                
                                Spacer()
                                
                                Button {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        var updatedServings = servingOptions
                                        updatedServings.remove(at: index)
                                        servingOptions = updatedServings
                                    }
                                } label: {
                                    Image(systemName: "xmark")
                                        .bodyText(weight: .regular)
                                }
                                .textColor()
                                .animatedButton(feedback: .impact(weight: .medium))
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .leading)),
                            removal: .opacity.combined(with: .move(edge: .trailing))
                        ))
                    }
                }
                
                Button {
                    let nextIndex = (servingOptions.map { $0.index }.max() ?? -1) + 1
                    let newServing = CustomServing(index: nextIndex)
                    
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        servingOptions.append(newServing)
                    }
                    
                    hasUnsavedChanges = true
                } label: {
                    HStack(alignment: .center, spacing: .spacingXS) {
                        Image(systemName: "plus")
                            .secondaryImage(weight: .bold)
                        
                        Text("Add Serving Option")
                            .secondaryText()
                    }
                }
                .textColor()
                .animatedButton()
            }
            
            HStack(alignment: .center) {
                Spacer()
                
                SaveButton(save: save, isValid: isValid)
                
                Spacer()
            }
        }
        .onAppear {
            if servingOptions.isEmpty {
                servingOptions.append(CustomServing(index: 0))
            }
        }
        .onChange(of: name) { hasUnsavedChanges = true }
        .onChange(of: stayOnPage) {
            if !stayOnPage {
                dismiss()
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardDoneButton()
            }
        }
        .hapticFeedback(.warning, trigger: dismissTrigger)
        .disableEdgeSwipe(hasUnsavedChanges)
    }
    
    private func save() async {
        guard storeManager.hasPremiumAccess else { return }
        
        let servings = servingOptions.filter { !$0.desc.trimmingCharacters(in: .whitespaces).isEmpty }
        
        if let food = food {
            food.name = name
            food.servingOptions = servings
            
            self.food = food
        } else {
            let food = CustomFood(name: name, servingOptions: servings)
            
            context.insert(food)
            
            self.food = food
        }

        do {
            try context.save()
            
            Toast.show("Custom food saved", "checkmark")
        } catch {
            debugLog("Error: \(error.localizedDescription)")
        }
        
        foodToAdd = self.food
        
        hasUnsavedChanges = false
        
        dismiss()
    }
}
