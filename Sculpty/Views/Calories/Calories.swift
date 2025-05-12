//
//  Calories.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/4/25.
//

import SwiftUI
import SwiftData
import SwiftUICharts
import Neumorphic

struct Calories: View {
    @Environment(\.modelContext) private var context
    
    @Query(sort: \CaloriesLog.date) private var caloriesLogs: [CaloriesLog]
    
    @StateObject private var viewModel: CaloriesViewModel = CaloriesViewModel()
    
    @Binding var selectedTab: Int
    let tabTag: Int
    
    @FocusState private var isNameFocused: Bool
    @FocusState private var isCaloriesFocused: Bool
    @FocusState private var isCarbsFocused: Bool
    @FocusState private var isProteinFocused: Bool
    @FocusState private var isFatFocused: Bool
    
    @State private var selectedRange: TimeRange = .month
    @State private var rangeStart: Date?
    @State private var rangeEnd: Date?
    
    @State private var loaded: Bool = false
    
    var filteredLogs: [CaloriesLog] {
        let calendar = Calendar.current
        
        switch selectedRange {
        case .week:
            guard let filterDate = calendar.date(byAdding: .day, value: -7, to: Date()) else { return [] }
            
            return caloriesLogs.filter { $0.date >= filterDate }
            
        case .month:
            guard let filterDate = calendar.date(byAdding: .day, value: -30, to: Date()) else { return [] }
            
            return caloriesLogs.filter { $0.date >= filterDate }
            
        case .custom:
            guard let start = rangeStart, let end = rangeEnd else { return [] }
            
            return caloriesLogs.filter { $0.date >= start && $0.date <= end }
            
        case .all:
            return caloriesLogs
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    HStack {
                        Text("Calories")
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                        
                        NavigationLink(destination: CaloriesHistory()) {
                            Image(systemName: "list.bullet.clipboard")
                        }
                        .padding(.horizontal, 10)
                    }
                    .padding()
                    .padding(.bottom)
                    
                    ScrollView {
//                        MacroBreakdownChart(log: $viewModel.log)
//                            .padding(.top)
                        
                        List {
                            ForEach(viewModel.log.entries.sorted { $0.calories > $1.calories }, id: \.id) { entry in
                                Text("\(entry.name) - \(entry.calories.formatted())cal (\(entry.carbs.formatted())g Carbs, \(entry.protein.formatted())g Protein, \(entry.fat.formatted())g Fat)")
                                    .swipeActions {
                                        Button("Delete") {
                                            if let index = viewModel.log.entries.firstIndex(where: { $0.id == entry.id }) {
                                                viewModel.log.entries.remove(at: index)
                                            }
                                        }
                                        .tint(.red)
                                    }
                            }
                        }
                        .frame(height: CGFloat((viewModel.log.entries.count * 66) + (viewModel.log.entries.count < 5 ? (viewModel.log.entries.count < 4 ? (viewModel.log.entries.count < 3 ? (viewModel.log.entries.count < 2 ? 50 : 40) : 30) : 20) : 0)), alignment: .top)
                        .scrollDisabled(true)
                        .scrollContentBackground(.hidden)
                        .padding(.vertical)
                        
                        if caloriesLogs.count > 1 {
                            Picker("Time Range", selection: $selectedRange) {
                                ForEach(TimeRange.allCases, id: \.self) { range in
                                    Text(range.rawValue).tag(range)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding()
                            
                            if selectedRange == .custom {
                                DatePicker(
                                    "Pick a start date",
                                    selection: Binding(
                                        get: { rangeStart ?? Date() },
                                        set: { rangeStart = $0 }
                                    ),
                                    in: caloriesLogs.first!.date...Date(),
                                    displayedComponents: [.date]
                                )
                                .padding()

                                if let start = rangeStart {
                                    DatePicker(
                                        "Pick an end date",
                                        selection: Binding(
                                            get: { rangeEnd ?? start },
                                            set: { rangeEnd = $0 }
                                        ),
                                        in: start...Date(),
                                        displayedComponents: [.date]
                                    )
                                    .padding()
                                }
                            }
                            
                            BarChartView(
                                data: ChartData(values: filteredLogs.map {
                                    (formatDate($0.date), $0.getTotalCalories())
                                }),
                                title: "Calories Over Time",
                                legend: "Calories (kcal)",
                                style: Styles.barChartStyleOrangeLight,
                                form: CGSize(width: 350, height: 250),
                                dropShadow: false
                            )
                        } else {
                            Text("Not enough data to display a chart. There must be at least 2 days of data to view a chart.")
                        }
                    }
                    .padding()
                }
                .toolbar(.hidden, for: .navigationBar)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        
                        Button {
                            unfocus()
                        } label: {
                            Text("Done")
                        }
                        .disabled(!(isNameFocused || isCaloriesFocused || isCarbsFocused || isProteinFocused || isFatFocused))
                    }
                }
            }
        }
        .onChange(of: selectedTab) {
            if selectedTab == tabTag {
                loadTodaysLog()
                
                if !loaded {
                    selectedRange = .week
                    
                    loaded = true
                }
            }
        }
    }
    
    private func loadTodaysLog() {
        var log = caloriesLogs.first { log in
            Calendar.current.isDate(log.date, inSameDayAs: Date())
        }
        
        if log == nil {
            log = CaloriesLog()
            context.insert(log!)
            try? context.save()
        }
        
        viewModel.changeLog(log: log!)
    }
    
    private func unfocus() {
        isNameFocused = false
        isCaloriesFocused = false
        isCarbsFocused = false
        isProteinFocused = false
        isFatFocused = false
    }
    
    private func addEntry() {
        let newEntry = FoodEntry(name: viewModel.nameInput, calories: Double(viewModel.caloriesInput) ?? 0, carbs: Double(viewModel.carbsInput) ?? 0, protein: Double(viewModel.proteinInput) ?? 0, fat: Double(viewModel.fatInput) ?? 0)
        viewModel.log.entries.append(newEntry)
        
        viewModel.nameInput = ""
        viewModel.caloriesInput = ""
        viewModel.carbsInput = ""
        viewModel.proteinInput = ""
        viewModel.fatInput = ""
        
        try? context.save()
    }
}

#Preview {
    Calories(selectedTab: .constant(2), tabTag: 2)
}
