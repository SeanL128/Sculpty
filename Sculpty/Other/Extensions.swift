//
//  Extensions.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/15/25.
//

import SwiftUI

// MARK: View
extension View {
    // Edge Swipe
    func disableEdgeSwipe() -> some View {
        self
            .onAppear {
                EdgeSwipeManager.shared.disable()
            }
            .onDisappear {
                EdgeSwipeManager.shared.enable()
            }
    }
    
    func disableEdgeSwipe(_ disabled: Bool) -> some View {
        self
            .onAppear {
                if disabled {
                    EdgeSwipeManager.shared.disable()
                } else {
                    EdgeSwipeManager.shared.enable()
                }
            }
            .onDisappear {
                EdgeSwipeManager.shared.enable()
            }
            .onChange(of: disabled) {
                if disabled {
                    EdgeSwipeManager.shared.disable()
                } else {
                    EdgeSwipeManager.shared.enable()
                }
            }
    }
    
    // Button Styles
    func animatedButton(
        scale: Double = 0.95,
        feedback: SensoryFeedback? = nil,
        isValid: Bool = true
    ) -> some View {
        self.buttonStyle(AnimatedButtonStyle(scale: scale, feedback: feedback, isValid: isValid))
    }
    
    func borderedToFilledButton(
        scale: Double = 0.97,
        feedback: SensoryFeedback? = nil,
        isValid: Bool = true
    ) -> some View {
        self.buttonStyle(BorderedToFilledButtonStyle(scale: scale, feedback: feedback, isValid: isValid))
    }
    
    func filledToBorderedButton(
        color: Color = ColorManager.text,
        scale: Double = 0.97,
        feedback: SensoryFeedback? = nil,
        isValid: Bool = true
    ) -> some View {
        self.buttonStyle(FilledToBorderedButtonStyle(color: color, scale: scale, feedback: feedback, isValid: isValid))
    }
    
    // Limit Text
    func limitText(_ text: Binding<String>, to characterLimit: Int) -> some View {
        self
            .onChange(of: text.wrappedValue) {
                text.wrappedValue = String(text.wrappedValue.prefix(characterLimit))
            }
    }
    
    // Colors
    func textColor() -> some View {
        self.foregroundStyle(ColorManager.text)
    }
    
    func lightModeTextColor() -> some View {
        self.foregroundStyle(ColorManager.text.light)
    }
    
    func darkModeTextColor() -> some View {
        self.foregroundStyle(ColorManager.text.dark)
    }
    
    func secondaryColor() -> some View {
        self.foregroundStyle(ColorManager.secondary)
    }
    
    // Fonts
    
    // Heading: 32
    // Subheading: 24
    // Subheading 2: 18
    func headingText(size: CGFloat) -> some View {
        self.font(.custom("Oswald-Bold", size: size))
    }
    
    // Large: 18
    // Body: 16
    // Subbody: 14
    func bodyText(size: CGFloat, weight: FontWeight = .regular) -> some View {
        self.font(.custom("PublicSans-\(weight.rawValue)", size: size))
    }
    
    // Stats: 16
    // Substats: 14
    func statsText(size: CGFloat) -> some View {
        self.font(.custom("IBMPlexMono-Regular", size: size))
    }
}

// MARK: String
extension String {
    func filteredNumeric() -> String {
        let filtered = self.filter { "0123456789.".contains($0) }
        let components = filtered.split(separator: ".")
        let string = components.count > 2 ? "\(components[0]).\(components[1])" : filtered
        return string.count > 1 ? string.replacing(/^([+-])?0+/, with: {$0.output.1 ?? ""}) : string
    }
    
    func filteredNumericWithoutDecimalPoint() -> String {
        let filtered = self.filter { "0123456789".contains($0) }
        return filtered.count > 1 ? filtered.replacing(/^([+-])?0+/, with: {$0.output.1 ?? ""}) : filtered
    }
    
    func sanitize(_ replacements: [(String, String)]) -> String {
        var sanitized: String = self
        
        for (search, replace) in replacements {
            sanitized = sanitized.replacingOccurrences(of: search, with: replace)
        }
        
        return sanitized
    }
}

// MARK: Array
extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict: [Element: Bool] = [:]

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

// MARK: Color
extension Color {
    var light: Self {
        var environment = EnvironmentValues()
        environment.colorScheme = .light
        return Color(resolve(in: environment))
    }

    var dark: Self {
        var environment = EnvironmentValues()
        environment.colorScheme = .dark
        return Color(resolve(in: environment))
    }
    
    init(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized.replacingOccurrences(of: "#", with: "")).scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

// MARK: UINavigationController
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        guard viewControllers.count > 1 else { return false }

        if presentedViewController != nil {
            return false
        }
        
        if EdgeSwipeManager.shared.isDisabled {
            return false
        }

        return true
    }

    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        viewControllers.count > 1
    }

    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        viewControllers.count > 1
    }
}

// MARK: Notification.Name
extension Notification.Name {
    static let dismissPopup = Notification.Name("dismissPopup")
}
