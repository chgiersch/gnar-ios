//
//  ScoreCelebrationView.swift
//  GNAR
//
//  Created by Chris Giersch on 4/4/25.
//
//  This view is responsible for displaying a celebration animation when a score is added.


import UIKit

class ScoreCelebrationView: UIView {
    // MARK: - Properties
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.alpha = 0  // Start invisible
        return label
    }()
    
    // MARK: - Initialization
    init(score: Int) {
        super.init(frame: .zero)
        setupView()
        scoreLabel.text = "+\(score)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        
        // Add and setup score label
        addSubview(scoreLabel)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scoreLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    // MARK: - Animation
    func startCelebration() {
        // Reset any existing animations
        scoreLabel.layer.removeAllAnimations()
        scoreLabel.transform = .identity
        scoreLabel.alpha = 0
        
        // Animate the score label
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseOut) {
            self.scoreLabel.alpha = 1
            self.scoreLabel.transform = CGAffineTransform(scaleX: 2.2, y: 2.2)
        } completion: { _ in
            // Scale back to normal size
            UIView.animate(withDuration: 0.3) {
                self.scoreLabel.transform = .identity
            } completion: { _ in
                // Fade out and remove
                UIView.animate(withDuration: 0.4, delay: 0.8) {
                    self.scoreLabel.alpha = 0
                } completion: { _ in
                    self.removeFromSuperview()
                }
            }
        }
    }
} 
