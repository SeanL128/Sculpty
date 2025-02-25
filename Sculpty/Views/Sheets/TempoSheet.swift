//
//  TempoSheet.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/18/25.
//

import SwiftUI

struct TempoSheet: View {
    private var arr: [String]
    private var xPresent: Bool
    
    init (tempo: String = "XXXX") {
        arr = tempo.map { String($0) }
        xPresent = arr[0] == "X" || arr[1] == "X" || arr[2] == "X" || arr[3] == "X"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    Text("\(arr[0]): Eccentric (Lowering/Lenthening)")
                        .padding(1)
                    Text("\(arr[1]): Lengthened Pause (Fully Stretched)")
                        .padding(1)
                    Text("\(arr[2]): Concentric (Lifting/Shortening)")
                        .padding(1)
                    Text("\(arr[3]): Shortened Pause (Fully Shortened)")
                        .padding(1)
                    
                    if xPresent {
                        Text("X = Instant")
                            .padding(1)
                            .italic(true)
                            .font(.subheadline)
                    }
                    
                    Spacer()
                }
                .padding(.top, 25)
            }
        }
    }
}

#Preview {
    TempoSheet()
}
