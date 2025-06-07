//
//  AddMeasurementPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/4/25.
//

import SwiftUI
import SwiftData
import MijickPopups

struct AddMeasurementPopup: CenterPopup {
    @Environment(\.modelContext) private var context
    
    @EnvironmentObject private var settings: CloudSettings
    
    @Binding var measurementToAdd: Measurement?
    
    @State private var type: MeasurementType = .weight
    private var typeOptions: [String : MeasurementType] {
        var dict: [String: MeasurementType] = [:]
        
        for type in MeasurementType.displayOrder {
            var output = type.rawValue
            
            if type == .bodyFat {
                output += " (%)"
            } else if settings.units == "Metric" {
                if type == .weight {
                    output += " (kg)"
                } else if type != .other {
                    output += " (cm)"
                }
            } else if settings.units == "Imperial" {
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
    
    @FocusState var isTextFocused: Bool
    @FocusState var isHeightFeetFocused: Bool
    @FocusState var isHeightInchesFocused: Bool
    
    var units: String {
        if type == .bodyFat {
            return "%"
        } else if settings.units == "Metric" {
            if type == .weight {
                return "kg"
            } else {
                return "cm"
            }
        } else if settings.units == "Imperial" {
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
        VStack(alignment: .center, spacing: 20) {
            Button {
                Task {
                    await MeasurementMenuPopup(options: typeOptions, selection: $type).present()
                }
            } label: {
                var selection: String {
                    var output = type.rawValue
                    
                    if type == .bodyFat {
                        output += " (%)"
                    } else if settings.units == "Metric" {
                        if type == .weight {
                            output += " (kg)"
                        } else if type != .other {
                            output += " (cm)"
                        }
                    } else if settings.units == "Imperial" {
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
                        .bodyText(size: 16, weight: .bold)
                    
                    Image(systemName: "chevron.right")
                        .padding(.leading, -2)
                        .font(Font.system(size: 10, weight: .bold))
                }
            }
            .textColor()
            .padding(.bottom, 2)
            .onChange(of: type) {
                text = ""
                heightFeet = ""
                heightInches = ""
            }
            
            // Unit Selector
            if type != .bodyFat {
                Button {
                    Task {
                        await UnitMenuPopup(selection: $settings.units).present()
                    }
                } label: {
                    HStack(alignment: .center) {
                        Text(settings.units == "Imperial" ? "Imperial (mi, ft, in, lbs)" : "Metric (km, m, cm, kg)")
                            .bodyText(size: 16, weight: .bold)
                        
                        Image(systemName: "chevron.up.chevron.down")
                            .font(Font.system(size: 10, weight: .bold))
                    }
                }
                .textColor()
            }
            
            // Input
            VStack(alignment: .leading) {
                Text(type.rawValue)
                    .bodyText(size: 12)
                    .textColor()
                
                if type == .height && settings.units == "Imperial" {
                    HStack(alignment: .bottom) {
                        Input(title: "", text: $heightFeet, isFocused: _isHeightFeetFocused, unit: "ft", type: .numberPad)
                            .onChange(of: heightFeet) {
                                heightFeet = heightFeet.filteredNumericWithoutDecimalPoint()
                            }
                        
                        Input(title: "", text: $heightInches, isFocused: _isHeightInchesFocused, unit: "in", type: .numberPad)
                            .onChange(of: heightInches) {
                                heightInches = heightInches.filteredNumeric()
                            }
                    }
                } else {
                    Input(title: "", text: $text, isFocused: _isTextFocused, unit: units, type: .decimalPad)
                        .onChange(of: text) {
                            text = text.filteredNumeric()
                        }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
            
            Button {
                save()
            } label: {
                Text("Save")
                    .bodyText(size: 18, weight: .bold)
            }
            .foregroundStyle(isValid ? ColorManager.text : ColorManager.secondary)
            .disabled(!isValid)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 8)
        .toolbar {
            ToolbarItemGroup (placement: .keyboard) {
                Spacer()
                
                KeyboardDoneButton(focusStates: [_isTextFocused, _isHeightFeetFocused, _isHeightInchesFocused])
            }
        }
    }
    
    private func save() {
        if settings.units == "Imperial" && type == .height {
            text = "\(((Double(heightFeet) ?? 0) * 12) + (Double(heightInches) ?? 0))"
        }
        
        guard let value = Double(text) else {
            debugLog("Error saving measurement")
            return
        }
        
        var unit: String = "%"
        if type != .bodyFat {
            if settings.units == "Imperial" {
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
}
