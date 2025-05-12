////
////  MacroBreakdownChart.swift
////  Sculpty
////
////  Created by Sean Lindsay on 2/9/25.
////
//
//import SwiftUI
//import SwiftUICharts
//
//struct MacroBreakdownChart: View {
//    @Binding var log: CaloriesLog
//    
//    var totalCalories: Double { log.getTotalCalories() }
//    var carbs: Double { log.getTotalCarbs() }
//    var protein: Double { log.getTotalProtein() }
//    var fat: Double { log.getTotalFat() }
//
//    var macroData: [(Double, String, Color)] {
//        [(carbs, "Carbs", .blue),
//         (protein, "Protein", .red),
//         (fat, "Fat", .orange)]
//    }
//    
//    var body: some View {
//        PieChartView(
//            data: macroData.map(\.0),
//            labels: macroData.map(\.1),
//            title: "Macro Breakdown",
//            form: ChartForm.large,
//            dropShadow: false,
//            segmentColors: macroData.map(\.2),
//            unit: "g"
//        )
//        
//        VStack {
//            Text("\(totalCalories.formatted()) cal")
//            Text("\(carbs.formatted())g Carbs")
//            Text("\(protein.formatted())g Protein")
//            Text("\(fat.formatted())g Fat")
//        }
//        .padding(.top)
//    }
//}
//
//#Preview {
//    MacroBreakdownChart(log: .constant(CaloriesLog()))
//}
