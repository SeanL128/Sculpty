//
//  TempoPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 3/9/25.
//

import SwiftUI
import MijickPopups

struct TempoPopup: CenterPopup {
    private var arr: [String]
    private var xPresent: Bool
    
    init (tempo: String = "XXXX") {
        arr = tempo.map { String($0) }
        xPresent = tempo.contains(where: { $0 == "X" })
    }
    
    var body: some View {
        VStack {
            Text("\(arr[0]): Eccentric (Lowering/Lenthening)")
                .bodyText()
                .padding(1)
            Text("\(arr[1]): Lengthened Pause (Fully Stretched)")
                .bodyText()
                .padding(1)
            Text("\(arr[2]): Concentric (Lifting/Shortening)")
                .bodyText()
                .padding(1)
            Text("\(arr[3]): Shortened Pause (Fully Shortened)")
                .bodyText()
                .padding(1)
            
            if xPresent {
                Text("X = Instant")
                    .subbodyText()
                    .secondaryColor()
                    .padding(.top, 6)
            }
        }
        .textColor()
        .padding(.top, 20)
        .padding(.bottom, 18)
    }
    
    func configurePopup(config: CenterPopupConfig) -> CenterPopupConfig {
        config
            .backgroundColor(ColorManager.background)
            .popupHorizontalPadding(24)
    }
}
