//
//  AddMeasurementPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/4/25.
//

import SwiftUI
import SwiftData
import MijickPopups
import BRHSegmentedControl

struct AddMeasurementPopup: CenterPopup {
    @Environment(\.modelContext) private var context
    
    @Binding var measurementToAdd: Measurement?
    
    @State private var type: MeasurementType = .weight
    private var typeOptions: [String : MeasurementType] {
        var dict: [String: MeasurementType] = [:]
        
        for type in MeasurementType.displayOrder {
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
                } else if type == .height {
                    output += " (ft, in)"
                } else if type != .other {
                    output += " (in)"
                }
            }
            
            dict[output] = type
        }
        
        return dict
    }
    
    @State private var text: String = ""
    @State private var heightFeet: String = ""
    @State private var heightInches: String = ""
    
    @State private var selectedUnitsIndex: Int = UserDefaults.standard.object(forKey: UserKeys.units.rawValue) as? String == "Metric" ? 1 : 0
    private let unitOptionsMap: [Int: UnitOptions] = [
        0: .imperial,
        1: .metric
    ]
    private var selectedUnits: UnitOptions {
        get { unitOptionsMap[selectedUnitsIndex] ?? .imperial }
        set {
            if newValue == .metric {
                selectedUnitsIndex = 1
            } else {
                selectedUnitsIndex = 0
            }
        }
    }
    
    @FocusState var isTextFocused: Bool
    @FocusState var isHeightFeetFocused: Bool
    @FocusState var isHeightInchesFocused: Bool
    
    var units: String {
        if type == .bodyFat {
            return "%"
        } else if selectedUnits == .metric {
            if type == .weight {
                return "kg"
            } else {
                return "cm"
            }
        } else if selectedUnits == .imperial {
            if type == .weight {
                return "lbs"
            } else {
                return "in"
            }
        }
        
        return ""
    }
    
    var isValid: Bool {
        return !text.isEmpty || (!heightFeet.isEmpty && !heightInches.isEmpty)
    }
    
    init(measurementToAdd: Binding<Measurement?>) {
        self._measurementToAdd = measurementToAdd
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Button {
                Task {
                    await MeasurementMenuPopup(options: typeOptions, selection: $type).present()
                }
            } label: {
                var selection: String {
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
                        } else if type == .height {
                            output += " (ft, in)"
                        } else if type != .other {
                            output += " (in)"
                        }
                    }
                    
                    return output
                }
                
                HStack(alignment: .center) {
                    Text(selection)
                        .bodyText()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .padding(.leading, -2)
                }
                .textColor()
            }
            .padding(.bottom, 2)
            .onChange(of: type) {
                text = ""
                heightFeet = ""
                heightInches = ""
            }
            
            // Unit Selector
            if type != .bodyFat {
                BRHSegmentedControl(
                    selectedIndex: $selectedUnitsIndex,
                    labels: ["Imperial", "Metric"],
                    builder: { _, label in
                        Text(label)
                            .bodyText(size: 16)
                    },
                    styler: { state in
                        switch state {
                        case .none:
                            return ColorManager.secondary
                        case .touched:
                            return ColorManager.secondary.opacity(0.7)
                        case .selected:
                            return ColorManager.text
                        }
                    }
                )
                .onChange(of: selectedUnitsIndex) {
                    let unitOption = unitOptionsMap[selectedUnitsIndex] ?? .imperial
                    UserDefaults.standard.set(unitOption.rawValue, forKey: UserKeys.units.rawValue)
                }
            }
            
            // Input
            VStack(alignment: .leading) {
                Text(type.rawValue)
                    .bodyText(size: 12)
                    .textColor()
                
                if type == .height && selectedUnits == .imperial {
                    HStack(alignment: .bottom) {
                        TextField("", text: $heightFeet)
                            .keyboardType(.numberPad)
                            .focused($isHeightFeetFocused)
                            .textFieldStyle(UnderlinedTextFieldStyle(isFocused: Binding<Bool>(get: { isHeightFeetFocused }, set: { isHeightFeetFocused = $0 })))
                            .onChange(of: heightFeet) {
                                heightFeet = heightFeet.filteredNumericWithoutDecimalPoint()
                            }
                        
                        Text("ft")
                            .bodyText(size: 16)
                            .textColor()
                        
                        TextField("", text: $heightInches)
                            .keyboardType(.numberPad)
                            .focused($isHeightInchesFocused)
                            .textFieldStyle(UnderlinedTextFieldStyle(isFocused: Binding<Bool>(get: { isHeightInchesFocused }, set: { isHeightInchesFocused = $0 })))
                            .onChange(of: heightInches) {
                                heightInches = heightInches.filteredNumeric()
                            }
                        
                        Text("in")
                            .bodyText(size: 16)
                            .textColor()
                    }
                } else {
                    HStack(alignment: .bottom) {
                        TextField("", text: $text)
                            .keyboardType(.decimalPad)
                            .focused($isTextFocused)
                            .textFieldStyle(UnderlinedTextFieldStyle(isFocused: Binding<Bool>(get: { isTextFocused }, set: { isTextFocused = $0 })))
                            .onChange(of: text) {
                                text = text.filteredNumeric()
                            }
                        
                        Text(units)
                            .bodyText(size: 16)
                            .textColor()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
            
            Button {
                unfocus()
                save()
            } label: {
                Text("Save")
                    .bodyText(size: 18)
            }
            .disabled(!isValid)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 8)
        .toolbar {
            ToolbarItemGroup (placement: .keyboard) {
                Spacer()
                
                Button {
                    unfocus()
                } label: {
                    Text("Done")
                }
                .disabled(!(isTextFocused || isHeightFeetFocused || isHeightInchesFocused))
            }
        }
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
        
        guard let value = Double(text) else {
            print("Error saving measurement")
            return
        }
        
        var unit: String = "%"
        if type != .bodyFat {
            if selectedUnits == .imperial {
                if type == .weight {
                    unit = "lbs"
                } else {
                    unit = "in"
                }
            } else {
                if type == .weight {
                    unit = "kg"
                } else {
                    unit = "cm"
                }
            }
        }
        
        measurementToAdd = Measurement(date: Date(), measurement: value, unit: unit, type: type)
        
        text = ""
        heightFeet = ""
        heightInches = ""
        
        Task {
            await dismissLastPopup()
        }
    }
    
    func configurePopup(config: CenterPopupConfig) -> CenterPopupConfig {
        config
            .backgroundColor(ColorManager.background)
            .popupHorizontalPadding(24)
    }
}
