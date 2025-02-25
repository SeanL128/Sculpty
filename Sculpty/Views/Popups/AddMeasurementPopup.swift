//
//  AddMeasurementPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/23/25.
//

import SwiftUI
import SwiftData
import Neumorphic
import MijickPopups

struct AddMeasurementPopup: BottomPopup {
    @Environment(\.modelContext) private var context
    
    @State private var type: MeasurementType = .weight
    
    @State private var text: String = ""
    @State private var heightFeet: String = ""
    @State private var heightInches: String = ""
    
    @State private var selectedUnits: UnitOptions = UnitOptions(rawValue: UserDefaults.standard.object(forKey: UserKeys.units.rawValue) as? String ?? "Imperial") ?? .imperial
    @FocusState var isTextFocused: Bool
    @FocusState var isHeightFeetFocused: Bool
    @FocusState var isHeightInchesFocused: Bool
    
    var prompt: String {
        var output = type.rawValue
        
        if type == .bodyFat {
            output += " (%)"
        } else if selectedUnits == .metric {
            if type == .weight {
                output += " (kg)"
            } else if type != .other {
                output += " (cm)"
            }
        } else if selectedUnits == .imperial {
            if type == .weight {
                output += " (lbs)"
            } else if ![.other, .height].contains(type) {
                output += " (in)"
            }
        }
        
        return output
    }
    
    var isValid: Bool {
        return !text.isEmpty || (!heightFeet.isEmpty && !heightInches.isEmpty)
    }
    
    var body: some View {
        VStack {
            Picker("Measurement", selection: $type) {
                ForEach(MeasurementType.displayOrder) { type in
                    var option: String {
                        var output = type.rawValue
                        
                        if type == .bodyFat {
                            output += " (%)"
                        } else if selectedUnits == .metric {
                            if type == .weight {
                                output += " (kg)"
                            } else if type != .other {
                                output += " (cm)"
                            }
                        } else if selectedUnits == .imperial {
                            if type == .weight {
                                output += " (lbs)"
                            } else if ![.other, .height].contains(type) {
                                output += " (in)"
                            }
                        }
                        
                        return output
                    }
                    
                    Text(option)
                        .tag(type)
                }
            }
            .pickerStyle(.menu)
            .tint(ColorManager.text)
            
            VStack(spacing: 20) {
                HStack {
                    Toggle(isOn: Binding(
                        get: { selectedUnits == .imperial },
                        set: { if $0 { selectedUnits = .imperial } }
                    )) {
                        Text("Imperial")
                            .frame(width: 75)
                    }
                    .softToggleStyle(.capsule, mainColor: ColorManager.background, textColor: ColorManager.text, darkShadowColor: ColorManager.darkShadow, lightShadowColor: ColorManager.lightShadow)

                    Toggle(isOn: Binding(
                        get: { selectedUnits == .metric },
                        set: { if $0 { selectedUnits = .metric } }
                    )) {
                        Text("Metric")
                            .frame(width: 75)
                    }
                    .softToggleStyle(.capsule, mainColor: ColorManager.background, textColor: ColorManager.text, darkShadowColor: ColorManager.darkShadow, lightShadowColor: ColorManager.lightShadow)
                }
                
                if type == .height && selectedUnits == .imperial {
                    HStack {
                        TextField("", text: $heightFeet, prompt: Text("Height (ft)").foregroundColor(.secondary))
                            .keyboardType(.numberPad)
                            .focused($isHeightFeetFocused)
                            .padding(8)
                            .padding(.horizontal, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                    .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.25, radius: 2)
                            )
                            .onChange(of: heightFeet) {
                                heightFeet = heightFeet.filteredNumericWithoutDecimalPoint()
                            }

                        TextField("", text: $heightInches, prompt: Text("Height (in)").foregroundColor(.secondary))
                            .keyboardType(.numberPad)
                            .focused($isHeightInchesFocused)
                            .padding(8)
                            .padding(.horizontal, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                    .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.25, radius: 2)
                            )
                            .onChange(of: heightInches) {
                                heightInches = heightInches.filteredNumericWithoutDecimalPoint()
                            }
                    }
                } else {
                    TextField("", text: $text, prompt: Text(prompt).foregroundColor(.secondary))
                        .keyboardType(.decimalPad)
                        .focused($isTextFocused)
                        .padding(8)
                        .padding(.horizontal, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.25, radius: 2)
                        )
                        .onChange(of: text) {
                            text = text.filteredNumeric()
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            
            Button {
                unfocus()
                save()
            } label: {
                Text("Save")
            }
            .softButtonStyle(.capsule, mainColor: ColorManager.background, textColor: ColorManager.text, darkShadowColor: ColorManager.darkShadow, lightShadowColor: ColorManager.lightShadow)
            .disabled(!isValid)
        }
        .padding()
    }
    
    private func unfocus() {
        isTextFocused = false
        isHeightFeetFocused = false
        isHeightInchesFocused = false
    }
    
    private func save() {
        if selectedUnits == .imperial && type == .height {
            text = "\(((Double(heightFeet) ?? 0) * 12) + (Double(heightInches) ?? 0))"
        }
        
        guard var value = Double(text) else {
            print("Error saving measurement")
            return
        }
        
        if selectedUnits == .imperial {
            if type == .weight {
                value = WeightUnit.lbs.convert(value, to: WeightUnit.kg)
            } else if type != .bodyFat {
                value = ShortLengthUnit.inch.convert(value, to: ShortLengthUnit.cm)
            }
        }
        
        let measurement = Measurement(measurement: value, type: type)
        
        context.insert(measurement)
        try? context.save()
        
        text = ""
        heightFeet = ""
        heightInches = ""
        
        Task {
            await dismissLastPopup()
        }
    }
    
    
    func configurePopup(config: BottomPopupConfig) -> BottomPopupConfig {
        config
            .heightMode(.auto)
            .dragDetents([.fraction(1.2), .fraction(1.4), .large])
            .backgroundColor(ColorManager.background)
    }
}
