//
//  PopupConfig.swift
//  Sculpty
//
//  Created by Sean Lindsay on 6/19/25.
//

import SwiftUI

struct PopupConfig {
    var position: PopupPosition = .center
    var backgroundColor: Color = Color.black.opacity(0.3)
    var popupBackgroundColor: Color = ColorManager.background
    var cornerRadius: CGFloat = 16
    var horizontalPadding: CGFloat = 16
    var verticalPadding: CGFloat = 20
    var tapOutsideToDismiss: Bool = true
    var dragToDismiss: Bool = false
    var animation: Animation = .spring(response: 0.5, dampingFraction: 0.75, blendDuration: 0.2)
    var autoDismissAfter: TimeInterval? = nil
}
