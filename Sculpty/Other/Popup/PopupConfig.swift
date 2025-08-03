//
//  PopupConfig.swift
//  Sculpty
//
//  Created by Sean Lindsay on 6/19/25.
//

import SwiftUI

struct PopupConfig {
    var position: PopupPosition = .center
    var backgroundColor: Color = Color.black.opacity(0.5)
    var popupBackgroundColor: Color = ColorManager.surface
    var popupBorderColor: Color = ColorManager.border
    var cornerRadius: CGFloat = 12
    var horizontalPadding: CGFloat = .spacingL
    var verticalPadding: CGFloat = .spacingL
    var tapOutsideToDismiss: Bool = true
    var dragToDismiss: Bool = false
    var animation: Animation = .spring(response: 0.5, dampingFraction: 0.75, blendDuration: 0.2)
    var autoDismissAfter: TimeInterval?
}
