//
//  Toast.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/4/25.
//

import SwiftUI

struct Toast {
    @MainActor
    static func show(_ message: String, _ image: String, duration: TimeInterval = 3.0) {
        var config = ToastConfig()
        config.autoDismissAfter = duration
        
        ToastManager.shared.dismissAll()
        
        if CloudSettings.shared.enableToasts {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                ToastManager.shared.show(content: {
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: image)
                            .bodyText()
                        
                        Text(message)
                            .bodyText()
                            .multilineTextAlignment(.center)
                    }
                    .textColor()
                }, config: config)
            }
        }
    }
}
