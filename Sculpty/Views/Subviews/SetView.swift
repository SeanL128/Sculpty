//
//  SetView.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/8/25.
//

import SwiftUI

struct SetView: View {
    var set: ExerciseSet
    
    var body: some View {
        HStack {
            ZStack {
                switch (set.type) {
                case (.warmUp):
                    Image(systemName: "bolt.fill")
                case (.dropSet):
                    Image(systemName: "arrowtriangle.down.fill")
                case (.coolDown):
                    Image(systemName: "drop.fill")
                default:
                    Text("")
                }
            }
            .frame(width: 20, height: 40)
            
            Text("\(set.reps) \(set.measurement) \(String(format: "%0.2f", set.weight)) \(set.unit)")
            
            Spacer()
            
            if ![.warmUp, .coolDown].contains(set.type) {
                if set.rir == "Failure" {
                    Text(set.rir)
                } else {
                    Text("\(set.rir) RIR")
                }
            }
        }
        .frame(height: 37)
    }
}

#Preview {
    SetView(set: ExerciseSet())
}
