//
//  ViewExtensions.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/25/25.
//

import SwiftUI

extension View {
    // Colors
    func textColor() -> some View {
        self.foregroundStyle(ColorManager.text)
    }
    
    func secondaryColor() -> some View {
        self.foregroundStyle(ColorManager.secondary)
    }
    
    func backgroundColor() -> some View {
        self.background(ColorManager.background)
    }
    
    // Fonts
    func pageTitleText(weight: Font.Weight = .bold) -> some View {
        self
            .font(.system(size: 32, weight: weight))
    }
    
    func headingText(weight: Font.Weight = .bold) -> some View {
        self.font(.system(size: 24, weight: weight))
    }
    
    func subheadingText(weight: Font.Weight = .bold) -> some View {
        self.font(.system(size: 18, weight: weight))
    }
    
    func bodyText(weight: Font.Weight = .medium) -> some View {
        self.font(.system(size: 16, weight: weight))
    }
    
    func secondaryText(weight: Font.Weight = .regular) -> some View {
        self.font(.system(size: 14, weight: weight))
    }
    
    func captionText(weight: Font.Weight = .regular) -> some View {
        self.font(.system(size: 12, weight: weight))
    }
    
    func pageTitleImage(weight: Font.Weight = .medium) -> some View {
        self.font(.system(size: 22, weight: weight))
    }
    
    func headingImage(weight: Font.Weight = .medium) -> some View {
        self.font(.system(size: 16, weight: weight))
    }
    
    func subheadingImage(weight: Font.Weight = .medium) -> some View {
        self.font(.system(size: 10, weight: weight))
    }
    
    func bodyImage(weight: Font.Weight = .medium) -> some View {
        self.font(.system(size: 8, weight: weight))
    }
    
    func secondaryImage(weight: Font.Weight = .regular) -> some View {
        self.font(.system(size: 8, weight: weight))
    }
    
    func captionImage(weight: Font.Weight = .regular) -> some View {
        self.font(.system(size: 6, weight: weight))
    }
}
