//
//  TempoPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 3/9/25.
//

import SwiftUI

struct TempoPopup: View {
    private var arr: [String]
    private var zeroPresent: Bool
    
    init (tempo: String = "0000") {
        arr = tempo.map { String($0) }
        zeroPresent = tempo.contains(where: { $0 == "0" })
    }
    
    var body: some View {
        VStack {
            Text("\(arr[0]): Eccentric (Lowering/Lenthening)")
                .bodyText(size: 16)
                .padding(1)
            
            Text("\(arr[1]): Lengthened Pause (Fully Stretched)")
                .bodyText(size: 16)
                .padding(1)
            
            Text("\(arr[2]): Concentric (Lifting/Shortening)")
                .bodyText(size: 16)
                .padding(1)
            
            Text("\(arr[3]): Shortened Pause (Fully Shortened)")
                .bodyText(size: 16)
                .padding(1)
        }
        .textColor()
    }
}
