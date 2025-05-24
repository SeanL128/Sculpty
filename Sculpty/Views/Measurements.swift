//
//  Measurements.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/11/25.
//

import SwiftUI
import SwiftData
import SwiftUICharts

struct Measurements: View {
    @Query private var measurements: [Measurement]
    
    @State private var weightUnit: String = UnitsManager.weight
    
    @State private var heightUnit: String = UnitsManager.mediumLength
    
    @State private var neckUnit: String = UnitsManager.shortLength
    @State private var shouldersUnit: String = UnitsManager.shortLength
    @State private var chestUnit: String = UnitsManager.shortLength
    @State private var upperArmLeftUnit: String = UnitsManager.shortLength
    @State private var upperArmRightUnit: String = UnitsManager.shortLength
    @State private var forearmLeftUnit: String = UnitsManager.shortLength
    @State private var forearmRightUnit: String = UnitsManager.shortLength
    @State private var waistUnit: String = UnitsManager.shortLength
    @State private var hipsUnit: String = UnitsManager.shortLength
    @State private var thighLeftUnit: String = UnitsManager.shortLength
    @State private var thighRightUnit: String = UnitsManager.shortLength
    @State private var calfLeftUnit: String = UnitsManager.shortLength
    @State private var calfRightUnit: String = UnitsManager.shortLength
    
    var body: some View {
        ContainerView(title: "Measurements", spacing: 20) {
            let weightEmpty = measurements.filter { $0.type == .weight }.isEmpty
            NavigationLink(destination: MeasurementPage(title: "Weight", type: .weight, unit: $weightUnit)) {
                HStack(alignment: .center) {
                    Text("Weight")
                        .bodyText(size: 16)
                    
                    Image(systemName: "chevron.right")
                        .padding(.leading, -2)
                        .font(Font.system(size: 12))
                }
            }
            .foregroundStyle(weightEmpty ? ColorManager.secondary : ColorManager.text)
            .disabled(weightEmpty)
            
            let heightEmpty = measurements.filter { $0.type == .height }.isEmpty
            NavigationLink(destination: MeasurementPage(title: "Height", type: .height, unit: $heightUnit)) {
                HStack(alignment: .center) {
                    Text("Height")
                        .bodyText(size: 16)
                    
                    Image(systemName: "chevron.right")
                        .padding(.leading, -2)
                        .font(Font.system(size: 12))
                }
            }
            .foregroundStyle(heightEmpty ? ColorManager.secondary : ColorManager.text)
            .disabled(heightEmpty)

            let bodyFatEmpty = measurements.filter { $0.type == .bodyFat }.isEmpty
            NavigationLink(destination: MeasurementPage(title: "Body Fat Percentage", type: .bodyFat, unit: .constant("%"))) {
                HStack(alignment: .center) {
                    Text("Body Fat Percentage")
                        .bodyText(size: 16)
                    
                    Image(systemName: "chevron.right")
                        .padding(.leading, -2)
                        .font(Font.system(size: 12))
                }
            }
            .foregroundStyle(bodyFatEmpty ? ColorManager.secondary : ColorManager.text)
            .disabled(bodyFatEmpty)

            Spacer()
                .frame(height: 5)

            let neckEmpty = measurements.filter { $0.type == .neck }.isEmpty
            NavigationLink(destination: MeasurementPage(title: "Neck", type: .neck, unit: $neckUnit)) {
                HStack(alignment: .center) {
                    Text("Neck")
                        .bodyText(size: 16)
                    
                    Image(systemName: "chevron.right")
                        .padding(.leading, -2)
                        .font(Font.system(size: 12))
                }
            }
            .foregroundStyle(neckEmpty ? ColorManager.secondary : ColorManager.text)
            .disabled(neckEmpty)

            let shouldersEmpty = measurements.filter { $0.type == .shoulders }.isEmpty
            NavigationLink(destination: MeasurementPage(title: "Shoulders", type: .shoulders, unit: $shouldersUnit)) {
                HStack(alignment: .center) {
                    Text("Shoulders")
                        .bodyText(size: 16)
                    
                    Image(systemName: "chevron.right")
                        .padding(.leading, -2)
                        .font(Font.system(size: 12))
                }
            }
            .foregroundStyle(shouldersEmpty ? ColorManager.secondary : ColorManager.text)
            .disabled(shouldersEmpty)

            let chestEmpty = measurements.filter { $0.type == .chest }.isEmpty
            NavigationLink(destination: MeasurementPage(title: "Chest", type: .chest, unit: $chestUnit)) {
                HStack(alignment: .center) {
                    Text("Chest")
                        .bodyText(size: 16)
                    
                    Image(systemName: "chevron.right")
                        .padding(.leading, -2)
                        .font(Font.system(size: 12))
                }
            }
            .foregroundStyle(chestEmpty ? ColorManager.secondary : ColorManager.text)
            .disabled(chestEmpty)

            let upperArmLeftEmpty = measurements.filter { $0.type == .upperArmLeft }.isEmpty
            NavigationLink(destination: MeasurementPage(title: "Upper Arm (Left)", type: .upperArmLeft, unit: $upperArmLeftUnit)) {
                HStack(alignment: .center) {
                    Text("Upper Arm (Left)")
                        .bodyText(size: 16)
                    
                    Image(systemName: "chevron.right")
                        .padding(.leading, -2)
                        .font(Font.system(size: 12))
                }
            }
            .foregroundStyle(upperArmLeftEmpty ? ColorManager.secondary : ColorManager.text)
            .disabled(upperArmLeftEmpty)

            let upperArmRightEmpty = measurements.filter { $0.type == .upperArmRight }.isEmpty
            NavigationLink(destination: MeasurementPage(title: "Upper Arm (Right)", type: .upperArmRight, unit: $upperArmRightUnit)) {
                HStack(alignment: .center) {
                    Text("Upper Arm (Right)")
                        .bodyText(size: 16)
                    
                    Image(systemName: "chevron.right")
                        .padding(.leading, -2)
                        .font(Font.system(size: 12))
                }
            }
            .foregroundStyle(upperArmRightEmpty ? ColorManager.secondary : ColorManager.text)
            .disabled(upperArmRightEmpty)

            let forearmLeftEmpty = measurements.filter { $0.type == .forearmLeft }.isEmpty
            NavigationLink(destination: MeasurementPage(title: "Forearm (Left)", type: .forearmLeft, unit: $forearmLeftUnit)) {
                HStack(alignment: .center) {
                    Text("Forearm (Left)")
                        .bodyText(size: 16)
                    
                    Image(systemName: "chevron.right")
                        .padding(.leading, -2)
                        .font(Font.system(size: 12))
                }
            }
            .foregroundStyle(forearmLeftEmpty ? ColorManager.secondary : ColorManager.text)
            .disabled(forearmLeftEmpty)

            let forearmRightEmpty = measurements.filter { $0.type == .forearmRight }.isEmpty
            NavigationLink(destination: MeasurementPage(title: "Forearm (Right)", type: .forearmRight, unit: $forearmRightUnit)) {
                HStack(alignment: .center) {
                    Text("Forearm (Right)")
                        .bodyText(size: 16)
                    
                    Image(systemName: "chevron.right")
                        .padding(.leading, -2)
                        .font(Font.system(size: 12))
                }
            }
            .foregroundStyle(forearmRightEmpty ? ColorManager.secondary : ColorManager.text)
            .disabled(forearmRightEmpty)

            let waistEmpty = measurements.filter { $0.type == .waist }.isEmpty
            NavigationLink(destination: MeasurementPage(title: "Waist", type: .waist, unit: $waistUnit)) {
                HStack(alignment: .center) {
                    Text("Waist")
                        .bodyText(size: 16)
                    
                    Image(systemName: "chevron.right")
                        .padding(.leading, -2)
                        .font(Font.system(size: 12))
                }
            }
            .foregroundStyle(waistEmpty ? ColorManager.secondary : ColorManager.text)
            .disabled(waistEmpty)

            let hipsEmpty = measurements.filter { $0.type == .hips }.isEmpty
            NavigationLink(destination: MeasurementPage(title: "Hips", type: .hips, unit: $hipsUnit)) {
                HStack(alignment: .center) {
                    Text("Hips")
                        .bodyText(size: 16)
                    
                    Image(systemName: "chevron.right")
                        .padding(.leading, -2)
                        .font(Font.system(size: 12))
                }
            }
            .foregroundStyle(hipsEmpty ? ColorManager.secondary : ColorManager.text)
            .disabled(hipsEmpty)

            let thighLeftEmpty = measurements.filter { $0.type == .thighLeft }.isEmpty
            NavigationLink(destination: MeasurementPage(title: "Thigh (Left)", type: .thighLeft, unit: $thighLeftUnit)) {
                HStack(alignment: .center) {
                    Text("Thigh (Left)")
                        .bodyText(size: 16)
                    
                    Image(systemName: "chevron.right")
                        .padding(.leading, -2)
                        .font(Font.system(size: 12))
                }
            }
            .foregroundStyle(thighLeftEmpty ? ColorManager.secondary : ColorManager.text)
            .disabled(thighLeftEmpty)

            let thighRightEmpty = measurements.filter { $0.type == .thighRight }.isEmpty
            NavigationLink(destination: MeasurementPage(title: "Thigh (Right)", type: .thighRight, unit: $thighRightUnit)) {
                HStack(alignment: .center) {
                    Text("Thigh (Right)")
                        .bodyText(size: 16)
                    
                    Image(systemName: "chevron.right")
                        .padding(.leading, -2)
                        .font(Font.system(size: 12))
                }
            }
            .foregroundStyle(thighRightEmpty ? ColorManager.secondary : ColorManager.text)
            .disabled(thighRightEmpty)

            let calfLeftEmpty = measurements.filter { $0.type == .calfLeft }.isEmpty
            NavigationLink(destination: MeasurementPage(title: "Calf (Left)", type: .calfLeft, unit: $calfLeftUnit)) {
                HStack(alignment: .center) {
                    Text("Calf (Left)")
                        .bodyText(size: 16)
                    
                    Image(systemName: "chevron.right")
                        .padding(.leading, -2)
                        .font(Font.system(size: 12))
                }
            }
            .foregroundStyle(calfLeftEmpty ? ColorManager.secondary : ColorManager.text)
            .disabled(calfLeftEmpty)

            let calfRightEmpty = measurements.filter { $0.type == .calfRight }.isEmpty
            NavigationLink(destination: MeasurementPage(title: "Calf (Right)", type: .calfRight, unit: $calfRightUnit)) {
                HStack(alignment: .center) {
                    Text("Calf (Right)")
                        .bodyText(size: 16)
                    
                    Image(systemName: "chevron.right")
                        .padding(.leading, -2)
                        .font(Font.system(size: 12))
                }
            }
            .foregroundStyle(calfRightEmpty ? ColorManager.secondary : ColorManager.text)
            .disabled(calfRightEmpty)
        }
    }
}

#Preview {
    Measurements()
}
