//
//  ToastConfig.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/4/25.
//

import SwiftUI

struct ToastConfig {
    var toastBackgroundColor: Color = ColorManager.surface
    var toastBorderColor: Color = ColorManager.border
    var horizontalPadding: CGFloat = .spacingM
    var verticalPadding: CGFloat = .spacingM
    var tapToDismiss: Bool = true
    var animation: Animation = .spring(response: 0.6, dampingFraction: 0.8)
    var autoDismissAfter: TimeInterval = 3.0
}
