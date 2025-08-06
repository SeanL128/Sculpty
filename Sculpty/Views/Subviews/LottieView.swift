//
//  LottieView.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/2/25.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let animationName: String
    let onAnimationComplete: (() -> Void)?
    
    init(animationName: String, onAnimationComplete: (() -> Void)? = nil) {
        self.animationName = animationName
        
        self.onAnimationComplete = onAnimationComplete
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        let animationView = LottieAnimationView(name: animationName)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        
        if let completion = onAnimationComplete {
            animationView.play { finished in
                if finished {
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
        }
        
        view.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) { }
}
