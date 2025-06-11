//
//  SnowflakeView.swift
//  GNAR
//
//  Animated snowflake effect using CoreAnimation

import UIKit

/// UIView that displays multiple animated snowflakes falling down the screen
/// Uses CALayer and CABasicAnimation for GPU-accelerated performance
class SnowflakeView: UIView {
    
    // MARK: - Properties
    
    /// Array to manage all snowflake layers
    private var snowflakeLayers: [CALayer] = []
    
    /// Configuration constants
    private let numberOfSnowflakes = 15
    private let minSize: CGFloat = 8
    private let maxSize: CGFloat = 16
    private let minDuration: TimeInterval = 4.0
    private let maxDuration: TimeInterval = 8.0
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Create snowflakes when we have actual bounds
        if snowflakeLayers.isEmpty && bounds.width > 0 && bounds.height > 0 {
            createMultipleSnowflakes()
        }
    }
    
    // MARK: - Setup
    
    private func setupView() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    // MARK: - Snowflake Management
    
    /// Creates multiple snowflakes with randomized properties
    private func createMultipleSnowflakes() {
        // Clean up any existing snowflakes
        cleanupSnowflakes()
        
        // Create snowflakes with staggered start times for natural effect
        for i in 0..<numberOfSnowflakes {
            let snowflake = createRandomSnowflake(index: i)
            snowflakeLayers.append(snowflake)
            layer.addSublayer(snowflake)
            
            let delay = Double.random(in: 0...2.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.animateSnowflake(snowflake)
            }
        }
    }
    
    /// Creates a single snowflake with randomized properties
    private func createRandomSnowflake(index: Int) -> CALayer {
        let snowflake = CALayer()
        
        // Random size and position
        let size = CGFloat.random(in: minSize...maxSize)
        let startX = CGFloat.random(in: 0...bounds.width)
        let startY = CGFloat.random(in: -50...(-20))
        
        // Configure layer
        snowflake.contents = createSnowflakeImage(size: CGSize(width: size, height: size))?.cgImage
        snowflake.frame = CGRect(x: startX, y: startY, width: size, height: size)
        snowflake.opacity = Float.random(in: 0.3...0.8)
        
        return snowflake
    }
    
    /// Creates snowflake image with simple 6-armed design
    private func createSnowflakeImage(size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2
            
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.setStrokeColor(UIColor.white.cgColor)
            context.cgContext.setLineWidth(1.0)
            
            // Center circle
            let centerRect = CGRect(x: center.x - 2, y: center.y - 2, width: 4, height: 4)
            context.cgContext.fillEllipse(in: centerRect)
            
            // Six arms
            for i in 0..<6 {
                let angle = Double(i) * Double.pi / 3.0
                let endX = center.x + cos(angle) * radius * 0.8
                let endY = center.y + sin(angle) * radius * 0.8
                
                context.cgContext.move(to: center)
                context.cgContext.addLine(to: CGPoint(x: endX, y: endY))
                context.cgContext.strokePath()
            }
        }
    }
    
    // MARK: - Animation
    
    /// Animates snowflake with falling, rotation, and opacity effects
    private func animateSnowflake(_ snowflake: CALayer) {
        let fallDuration = TimeInterval.random(in: minDuration...maxDuration)
        let horizontalDrift = CGFloat.random(in: -30...30)
        let finalX = snowflake.position.x + horizontalDrift
        
        // Falling animation with horizontal drift
        let fallAnimation = CABasicAnimation(keyPath: "position")
        fallAnimation.fromValue = snowflake.position
        fallAnimation.toValue = CGPoint(x: finalX, y: bounds.height + 50)
        fallAnimation.duration = fallDuration
        fallAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        // Rotation animation
        let rotationDuration = TimeInterval.random(in: 2.0...6.0)
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateAnimation.fromValue = 0
        rotateAnimation.toValue = Double.pi * 2
        rotateAnimation.duration = rotationDuration
        rotateAnimation.repeatCount = .infinity
        
        // Opacity fluctuation
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = snowflake.opacity
        opacityAnimation.toValue = snowflake.opacity * 0.5
        opacityAnimation.duration = TimeInterval.random(in: 1.0...3.0)
        opacityAnimation.autoreverses = true
        opacityAnimation.repeatCount = .infinity
        
        // Apply animations
        snowflake.add(fallAnimation, forKey: "falling")
        snowflake.add(rotateAnimation, forKey: "spinning")
        snowflake.add(opacityAnimation, forKey: "fading")
        
        // Update model layer to match final position
        snowflake.position = CGPoint(x: finalX, y: bounds.height + 50)
        
        // Recycle snowflake when animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + fallDuration + 1.0) {
            self.recycleSnowflake(snowflake)
        }
    }
    
    /// Recycles a finished snowflake by resetting its properties and restarting animation
    private func recycleSnowflake(_ snowflake: CALayer) {
        snowflake.removeAllAnimations()
        
        // Reset with new random properties
        let newX = CGFloat.random(in: 0...bounds.width)
        let newY = CGFloat.random(in: -50...(-20))
        let newSize = CGFloat.random(in: minSize...maxSize)
        
        snowflake.frame = CGRect(x: newX, y: newY, width: newSize, height: newSize)
        snowflake.contents = createSnowflakeImage(size: CGSize(width: newSize, height: newSize))?.cgImage
        snowflake.opacity = Float.random(in: 0.3...0.8)
        
        animateSnowflake(snowflake)
    }
    
    // MARK: - Cleanup
    
    /// Removes all snowflake layers and animations
    private func cleanupSnowflakes() {
        for snowflake in snowflakeLayers {
            snowflake.removeAllAnimations()
            snowflake.removeFromSuperlayer()
        }
        snowflakeLayers.removeAll()
    }
    
    deinit {
        cleanupSnowflakes()
    }
} 