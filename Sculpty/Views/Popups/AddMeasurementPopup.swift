//
//  AddMeasurementPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/4/25.
//

import SwiftUI
import SwiftData

struct AddMeasurementPopup: View {
    @Environment(\.modelContext) private var context
    
    @EnvironmentObject private var settings: CloudSettings
    
    @Binding var measurementToAdd: Measurement?
    
    @State private var type: MeasurementType = .weight
    private var typeOptions: [String: MeasurementType] {
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
        VStack(alignment: .center, spacing: .spacingL) {
            VStack(alignment: .center, spacing: .spacingM) {
                Button {
                    Popup.show(content: {
                        MeasurementMenuPopup(options: typeOptions, selection: $type)
                    })
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
                    
                    HStack(alignment: .center, spacing: .spacingXS) {
                        Text(selection)
                            .bodyText(weight: .regular)
                        
                        Image(systemName: "chevron.up.chevron.down")
                            .bodyImage(weight: .medium)
                    }
                }
                .textColor()
                .onChange(of: type) {
                    text = ""
                    heightFeet = ""
                    heightInches = ""
                }
                .animatedButton()
                
                // Unit Selector
                if type != .bodyFat {
                    Button {
                        Popup.show(content: {
                            UnitMenuPopup(selection: $settings.units)
                        })
                    } label: {
                        HStack(alignment: .center, spacing: .spacingXS) {
                            Text(settings.units == "Imperial" ? "Imperial (mi, ft, in, lbs)" : "Metric (km, m, cm, kg)")
                                .bodyText(weight: .regular)
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .bodyImage(weight: .medium)
                        }
                    }
                    .textColor()
                    .animatedButton()
                }
                
                // Input
                if type == .height && settings.units == "Imperial" {
                    VStack(alignment: .leading, spacing: .spacingXS) {
                        Text(type.rawValue)
                            .captionText()
                            .textColor()
                        
                        HStack(alignment: .bottom, spacing: .spacingS) {
                            Input(
                                title: "",
                                text: $heightFeet,
                                isFocused: _isHeightFeetFocused,
                                unit: "ft",
                                type: .numberPad
                            )
                            .onChange(of: heightFeet) {
                                heightFeet = heightFeet.filteredNumericWithoutDecimalPoint()
                            }
                            
                            Input(
                                title: "",
                                text: $heightInches,
                                isFocused: _isHeightInchesFocused,
                                unit: "in",
                                type: .numberPad
                            )
                            .onChange(of: heightInches) {
                                heightInches = heightInches.filteredNumeric()
                            }
                        }
                    }
                } else {
                    Input(title: type.rawValue, text: $text, isFocused: _isTextFocused, unit: units, type: .decimalPad)
                        .onChange(of: text) {
                            text = text.filteredNumeric()
                        }
                }
            }
            
            SaveButton(save: save, isValid: isValid)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardDoneButton()
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
        
        Popup.dismissLast()
    }
}
