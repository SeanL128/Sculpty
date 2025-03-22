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
    
    @State var data: [Measurement] = []
    
    @State var toDelete: Measurement? = nil
    
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
                    
                    if !data.isEmpty {
                        List {
                            ForEach(data, id: \.self) { measurement in
                                Text("\(formatDateWithTime(measurement.date)) - \(measurement.measurement.formatted())\(measurement.unit)")
                                    .swipeActions {
                                        Button("Delete") {
                                            toDelete = measurement
                                        }
                                        .tint(.red)
                                    }
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .confirmationDialog("Delete measurement?", isPresented: Binding(
                            get: { toDelete != nil },
                            set: { if !$0 { toDelete = nil } }
                        ), titleVisibility: .visible) {
                            Button("Delete", role: .destructive) {
                                if let measurement = toDelete {
                                    context.delete(measurement)
                                    try? context.save()
                                    
                                    setData()
                                    
                                    toDelete = nil
                                }
                            }
                        }
                    } else {
                        Text("No measurements yet.")
                    }
                    
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
        .onAppear() {
            setData()
        }
    }
    
    private func setData() {
        do {
            let fetched = try context.fetch(FetchDescriptor<Measurement>()).filter({ $0.type == type })
            
            data = fetched.isEmpty ? [] : fetched
        } catch {
            print(error.localizedDescription)
            
            data = []
        }
    }
}

#Preview {
    MeasurementPage(title: "Weight", type: .weight, text: .constant("100"), unit: .constant("lbs"))
}
