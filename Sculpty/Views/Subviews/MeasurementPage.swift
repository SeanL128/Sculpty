//
//  MeasurementPage.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/15/25.
//

import SwiftUI
import SwiftData
import SwiftUICharts
import Neumorphic

struct MeasurementPage: View {
    @Environment(\.modelContext) var context
    
    var title: String
    var type: MeasurementType
    
    @Binding var text: String
    @Binding var unit: String
    @FocusState var isFocused: Bool
    
    var data: [Double] {
        do {
            let data = try context.fetch(FetchDescriptor<Measurement>()).map { $0.measurement }
            
            return data.count > 0 ? data : [0]
        } catch {
            print(error.localizedDescription)
            
            return [0]
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .edgesIgnoringSafeArea(.all)
                
                
                VStack {
                    HStack(alignment: .center) {
                        Text(title)
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                    }
                    .padding()
                    
                    VStack {
                        HStack {
                            TextField(title, text: $text)
                                .keyboardType(.decimalPad)
                                .focused($isFocused)
                                .onChange(of: text) {
                                    text = text.filteredNumeric()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                                .background(
                                    RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                        .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.05, radius: 2)
                                )
                            
                            if type == .bodyFat {
                                Text("%")
                                    .frame(width: 25, height: 125)
                                    .padding(.leading, 5)
                            } else {
                                Picker("Unit", selection: $unit) {
                                    if type == .weight {
                                        Text("lbs").tag("lbs")
                                        
                                        Text("kg").tag("kg")
                                    } else {
                                        Text("in").tag("in")
                                        
                                        Text("cm").tag("cm")
                                    }
                                }
                                .pickerStyle(.wheel)
                                .clipped()
                                .frame(width: 75, height: 125)
                                .padding(.leading, 5)
                            }
                        }
                        
                        Button {
                            guard var value = Double(text) else {
                                print("Error saving measurement")
                                return
                            }
                            
                            if type == .weight {
                                value = WeightUnit(rawValue: unit)!.convert(value, to: WeightUnit.kg)
                            } else if ![.bodyFat, .height].contains(type) {
                                value = ShortLengthUnit(rawValue: unit)!.convert(value, to: ShortLengthUnit.cm)
                            }
                            
                            let measurement = Measurement(measurement: value, type: type)
                            
                            context.insert(measurement)
                            try? context.save()
                            
                            text = ""
                        } label: {
                            Text("Save")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(text.isEmpty)
                        .padding(.top, -25)
                    }
                    .padding(.top, -50)
                    
                    Spacer()
                }
                .padding()
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    
                    Button {
                        isFocused = false
                    } label: {
                        Text("Done")
                    }
                    .disabled(!isFocused)
                }
            }
        }
    }
}

#Preview {
    MeasurementPage(title: "Weight", type: .weight, text: .constant("100"), unit: .constant("lbs"))
}
