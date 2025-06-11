//
//  SnowflakeView.swift
//  GNAR
//
//  Animated snowflake effect using CoreAnimation

import UIKit

/// UIView that displays animated snowflakes falling down the screen
class SnowflakeView: UIView {
    
    // MARK: - Properties
    
    private let useEmitterLayer = true
    
    // Individual layers properties (fallback)
    private var snowflakeLayers: [CALayer] = []
    private let numberOfSnowflakes = 15
    private let minSize: CGFloat = 8
    private let maxSize: CGFloat = 16
    private let minDuration: TimeInterval = 4.0
    private let maxDuration: TimeInterval = 8.0
    
    // Emitter layer properties
    private var emitterLayer: CAEmitterLayer?
    private var currentProgressTier: Int = -1
    
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
        
        guard bounds.width > 0 && bounds.height > 0 else { return }
        
        if useEmitterLayer {
            if emitterLayer == nil {
                createEmitterSnowfall()
            }
        } else {
            if snowflakeLayers.isEmpty {
                createMultipleSnowflakes()
            }
        }
    }
    
    // MARK: - Setup
    
    private func setupView() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    // MARK: - Emitter Layer Implementation
    
    /// Creates a particle emitter system for snowflakes
    private func createEmitterSnowfall() {
        cleanupEmitter()
        
        let emitter = CAEmitterLayer()
        
        emitter.emitterPosition = CGPoint(x: bounds.width / 2, y: -50)
        emitter.emitterSize = CGSize(width: bounds.width, height: 1)
        emitter.emitterShape = .line
        
        let snowflakeCell = createSnowflakeEmitterCell()
        emitter.emitterCells = [snowflakeCell]
        
        layer.addSublayer(emitter)
        emitterLayer = emitter
    }
    
    /// Recreates the emitter with new settings for immediate visual impact
    private func recreateEmitterWithProgress(_ progress: CGFloat) {
        cleanupEmitter()
        
        let emitter = CAEmitterLayer()
        
        // Adjust emitter position and size for wind compensation
        let windOffset: CGFloat = progress >= 0.6 ? -bounds.width * 0.4 : 0
        let emitterWidth = progress >= 0.6 ? bounds.width * 2.0 : bounds.width
        
        emitter.emitterPosition = CGPoint(x: bounds.width / 2 + windOffset, y: -50)
        emitter.emitterSize = CGSize(width: emitterWidth, height: 1)
        emitter.emitterShape = .line
        
        let cell = createSnowflakeEmitterCellWithProgress(progress)
        emitter.emitterCells = [cell]
        
        layer.addSublayer(emitter)
        emitterLayer = emitter
    }
    
    /// Creates a CAEmitterCell that defines how individual snowflake particles behave
    private func createSnowflakeEmitterCell() -> CAEmitterCell {
        return createSnowflakeEmitterCellWithProgress(0.0)  // Default to gentle settings
    }
    
    /// Creates a CAEmitterCell with specific progress settings
    private func createSnowflakeEmitterCellWithProgress(_ progress: CGFloat) -> CAEmitterCell {
        let cell = CAEmitterCell()
        
        // Calculate values based on progress
        let baseBirthRate: Float = 5
        let maxBirthRate: Float = 150
        let birthRate = baseBirthRate + (maxBirthRate - baseBirthRate) * Float(progress)
        
        let baseVelocity: CGFloat = 25
        let maxVelocity: CGFloat = 120
        let velocity = baseVelocity + (maxVelocity - baseVelocity) * progress
        
        let baseVelocityRange: CGFloat = 10
        let maxVelocityRange: CGFloat = 60
        let velocityRange = baseVelocityRange + (maxVelocityRange - baseVelocityRange) * progress
        
        cell.birthRate = birthRate
        cell.lifetime = 12.0
        cell.velocity = velocity
        cell.velocityRange = velocityRange
        
        // Emission angle
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi / 8
        
        // Visual properties
        let baseScale: CGFloat = 0.08
        let maxScale: CGFloat = 0.6
        let scale = baseScale + (maxScale - baseScale) * progress
        
        cell.scale = scale
        cell.scaleRange = 0.0
        cell.alphaRange = 0.3 + (0.4 * Float(progress))
        cell.alphaSpeed = -0.03
        
        // Physics simulation with wind
        if progress >= 0.6 {
            let windStrength = (progress - 0.6) * 2.5 * 60
            cell.xAcceleration = windStrength
        } else {
            cell.xAcceleration = 0
        }
        cell.yAcceleration = 10 + (20 * progress)
        
        // Rotation
        cell.spin = 1.0
        cell.spinRange = 2.0
        
        cell.contents = createParticleSnowflakeImage()?.cgImage
        
        return cell
    }
    
    /// Creates a simple snowflake image for particle systems
    private func createParticleSnowflakeImage() -> UIImage? {
        let size = CGSize(width: 8, height: 8)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
    }
    
    /// Adjusts storm intensity based on scroll position (0.0 = top, 1.0 = bottom)
    func adjustStormIntensity(scrollProgress: CGFloat) {
        guard let emitter = emitterLayer,
              let cell = emitter.emitterCells?.first else { return }
        
        let progress = max(0.0, min(1.0, scrollProgress))
        
        // For major changes (every 20% scroll), recreate emitter for immediate effect
        let progressTier = Int(progress * 5)
        if progressTier != currentProgressTier {
            currentProgressTier = progressTier
            recreateEmitterWithProgress(progress)
            return
        }
        
        // Intensity increases from gentle to storm
        let baseBirthRate: Float = 5
        let maxBirthRate: Float = 150
        let newBirthRate = baseBirthRate + (maxBirthRate - baseBirthRate) * Float(progress)
        
        let baseVelocity: CGFloat = 25
        let maxVelocity: CGFloat = 120
        let newVelocity = baseVelocity + (maxVelocity - baseVelocity) * progress
        
        let baseVelocityRange: CGFloat = 10
        let maxVelocityRange: CGFloat = 60
        let newVelocityRange = baseVelocityRange + (maxVelocityRange - baseVelocityRange) * progress
        
        cell.birthRate = newBirthRate
        cell.velocity = newVelocity
        cell.velocityRange = newVelocityRange
        
        // Scale changes
        let baseScale: CGFloat = 0.08
        let maxScale: CGFloat = 0.6
        let newScale = baseScale + (maxScale - baseScale) * progress
        cell.scale = newScale
        cell.scaleRange = 0.0
        
        // Wind effect starting at 60% scroll
        if progress >= 0.6 {
            let windStrength = (progress - 0.6) * 2.5 * 60
            cell.xAcceleration = windStrength
        } else {
            cell.xAcceleration = 0
        }
    }
    
    /// Adds wind effect to the emitter
    func addWindEffect(strength: CGFloat = 15) {
        guard let emitter = emitterLayer,
              let cell = emitter.emitterCells?.first else { return }
        
        cell.xAcceleration = strength
    }
    
    /// Removes wind effect
    func removeWindEffect() {
        guard let emitter = emitterLayer,
              let cell = emitter.emitterCells?.first else { return }
        
        cell.xAcceleration = 0
    }
    
    // MARK: - Individual Layers Implementation (Fallback)
    
    /// Creates multiple snowflakes with randomized properties
    private func createMultipleSnowflakes() {
        cleanupSnowflakes()
        
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
    
    private func createRandomSnowflake(index: Int) -> CALayer {
        let snowflake = CALayer()
        let size = CGFloat.random(in: minSize...maxSize)
        let startX = CGFloat.random(in: 0...bounds.width)
        let startY = CGFloat.random(in: -50...(-20))
        
        snowflake.contents = createSnowflakeImage(size: CGSize(width: size, height: size))?.cgImage
        snowflake.frame = CGRect(x: startX, y: startY, width: size, height: size)
        snowflake.opacity = Float.random(in: 0.3...0.8)
        
        return snowflake
    }
    
    private func createSnowflakeImage(size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2
            
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.setStrokeColor(UIColor.white.cgColor)
            context.cgContext.setLineWidth(1.0)
            
            let centerRect = CGRect(x: center.x - 2, y: center.y - 2, width: 4, height: 4)
            context.cgContext.fillEllipse(in: centerRect)
            
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
    
    private func animateSnowflake(_ snowflake: CALayer) {
        let fallDuration = TimeInterval.random(in: minDuration...maxDuration)
        let horizontalDrift = CGFloat.random(in: -30...30)
        let finalX = snowflake.position.x + horizontalDrift
        
        let fallAnimation = CABasicAnimation(keyPath: "position")
        fallAnimation.fromValue = snowflake.position
        fallAnimation.toValue = CGPoint(x: finalX, y: bounds.height + 50)
        fallAnimation.duration = fallDuration
        fallAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        let rotationDuration = TimeInterval.random(in: 2.0...6.0)
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateAnimation.fromValue = 0
        rotateAnimation.toValue = Double.pi * 2
        rotateAnimation.duration = rotationDuration
        rotateAnimation.repeatCount = .infinity
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = snowflake.opacity
        opacityAnimation.toValue = snowflake.opacity * 0.5
        opacityAnimation.duration = TimeInterval.random(in: 1.0...3.0)
        opacityAnimation.autoreverses = true
        opacityAnimation.repeatCount = .infinity
        
        snowflake.add(fallAnimation, forKey: "falling")
        snowflake.add(rotateAnimation, forKey: "spinning")
        snowflake.add(opacityAnimation, forKey: "fading")
        snowflake.position = CGPoint(x: finalX, y: bounds.height + 50)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + fallDuration + 1.0) {
            self.recycleSnowflake(snowflake)
        }
    }
    
    private func recycleSnowflake(_ snowflake: CALayer) {
        snowflake.removeAllAnimations()
        
        let newX = CGFloat.random(in: 0...bounds.width)
        let newY = CGFloat.random(in: -50...(-20))
        let newSize = CGFloat.random(in: minSize...maxSize)
        
        snowflake.frame = CGRect(x: newX, y: newY, width: newSize, height: newSize)
        snowflake.contents = createSnowflakeImage(size: CGSize(width: newSize, height: newSize))?.cgImage
        snowflake.opacity = Float.random(in: 0.3...0.8)
        
        animateSnowflake(snowflake)
    }
    
    // MARK: - Cleanup
    
    private func cleanupEmitter() {
        emitterLayer?.removeFromSuperlayer()
        emitterLayer = nil
    }
    
    private func cleanupSnowflakes() {
        for snowflake in snowflakeLayers {
            snowflake.removeAllAnimations()
            snowflake.removeFromSuperlayer()
        }
        snowflakeLayers.removeAll()
    }
    
    deinit {
        cleanupEmitter()
        cleanupSnowflakes()
    }
} 
