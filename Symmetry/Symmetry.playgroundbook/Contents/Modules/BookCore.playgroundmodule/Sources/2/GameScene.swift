
//

import SpriteKit
import GameplayKit
import AVFoundation

public class GameScene: SKScene {
    
    // Nodes
    var player: SKNode?
    var joystick: SKNode?
    var joystickKnob: SKNode?
    var cameraNode: SKCameraNode?
    var mountains1: SKNode?
    var mountains2: SKNode?
    var mountains3: SKNode?
    var moon : SKNode?
    var stars : SKNode?
    var topBg : SKNode?

    // Boolean
    var isJoystickMovable = false
    var rewardIsNotTouched = true
    var isHit = false
    
    // Measure
    var knobRadius: CGFloat = 50.0
    
    // Score
    let scoreLabel = SKLabelNode()
    var score = 0
    
    // Hearts
    var heartsArray = [SKSpriteNode]()
    let heartContainer = SKSpriteNode()
    
    // Sprite Engine
    var previousTimeInterval: TimeInterval = 0
    var isPlayerFacingRight = true
    let playerSpeed = 4.0
    
    // Player State Machine
    var playerStateMachine: GKStateMachine!
    
    // didMove
    public override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self

        player = childNode(withName: "player")
        joystick = childNode(withName: "joystick")
        joystickKnob = joystick?.childNode(withName: "knob")
        cameraNode = childNode(withName: "cameraNode") as? SKCameraNode
        mountains1 = childNode(withName: "mountains1")
        mountains2 = childNode(withName: "mountains2")
        mountains3 = childNode(withName: "mountains3")
        moon = childNode(withName: "moon")
        stars = childNode(withName: "stars")
        topBg = childNode(withName: "topBg")
       
        
        playerStateMachine = GKStateMachine(states: [
            JumpingState(playerNode: player!),
            WalkingState(playerNode: player!),
            IdleState(playerNode: player!),
            LandingState(playerNode: player!),
            StunnedState(playerNode: player!)
        ])
        
        playerStateMachine.enter(IdleState.self)
        
        scene?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        // Hearts
        heartContainer.position = CGPoint(x: -400, y: 140)
        heartContainer.zPosition = 50
        cameraNode?.addChild(heartContainer)
        fillHearts(count: 3)
        
        scoreLabel.position = CGPoint(x: (cameraNode?.position.x)! + 400, y: 140)
        scoreLabel.fontColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        scoreLabel.fontSize = 30
        scoreLabel.zPosition = 50
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.text = String(score)
        cameraNode?.addChild(scoreLabel)
    }
}

// MARK: - Touches
extension GameScene {
    // Touch Began
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let joystickKnob = joystickKnob {
                let location = touch.location(in: joystick!)
                isJoystickMovable = joystickKnob.frame.contains(location)
            }
            
            let location = touch.location(in: self)
            if !(joystick!.contains(location)) {
                playerStateMachine.enter(JumpingState.self)
                
                Audio.sharedInstance.playSound(soundFileName: Sound.jump.fileName)
            }
        }
    }
    
    // Touch Moved
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let joystick = joystick else { return }
        guard let joystickKnob = joystickKnob else { return }
        
        if !isJoystickMovable { return }
        
        // Distance
        for touch in touches {
            let position = touch.location(in: joystick)
            let length = sqrt(pow(position.y, 2) + pow(position.x, 2))
            let angle = atan2(position.y, position.x)
            
            if knobRadius > length {
                joystickKnob.position = position
            } else {
                joystickKnob.position = CGPoint(x: cos(angle) * knobRadius, y: sin(angle) * knobRadius)
            }
        }
    }
    
    // Touch Ended
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let xJoystickjCoordinate = touch.location(in: joystick!).x
            let xLimit: CGFloat = 200.0
            if xJoystickjCoordinate > -xLimit && xJoystickjCoordinate < xLimit {
                resetKbobPosition()
            }
        }
    }
}

// MARK: - Action
extension GameScene {
    func resetKbobPosition() {
        let initialPoint = CGPoint(x: 0, y: 0)
        let moveBackAction = SKAction.move(to: initialPoint, duration: 0.1)
        moveBackAction.timingMode = .linear
        joystickKnob?.run(moveBackAction)
        isJoystickMovable = false
    }
    
    func rewardTouch() {
        score += 1
        scoreLabel.text = String(score)
    }
    
    func fillHearts(count: Int) {
        for index in 1...count {
            let heart = SKSpriteNode(imageNamed: "heart")
            let xPosition = heart.size.width * CGFloat(index - 1)
            heart.position = CGPoint(x: xPosition, y: 0)
            heartsArray.append(heart)
            heartContainer.addChild(heart)
        }
    }
    
    func loseHeart() {
        if isHit {
            let lastElementIndex = heartsArray.count - 1
            if heartsArray.indices.contains(lastElementIndex - 1) {
                let lastHeart = heartsArray[lastElementIndex]
                lastHeart.removeFromParent()
                heartsArray.remove(at: lastElementIndex)
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
                    self.isHit = false
                }
            } else {
                dying()
            }
            
            invincible()
        }
    }
    
    func invincible() {
        player?.physicsBody?.categoryBitMask = 0
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
            self.player?.physicsBody?.categoryBitMask = 2
        }
    }
    
    func dying() {
        let dieAction = SKAction.move(to: CGPoint(x: -300, y: 0), duration: 0.1)
        player?.run(dieAction)
        removeAllActions()
        fillHearts(count: 3)
    }
    
}

// MARK: - Game Loop
extension GameScene {
    public override func update(_ currentTime: TimeInterval) {
        let deltaTime = currentTime - previousTimeInterval
        previousTimeInterval = currentTime
        
        rewardIsNotTouched = true
        
        // Camera
        cameraNode?.position.x = player!.position.x
        joystick?.position.y = (cameraNode?.position.y)! - 240
        joystick?.position.x = (cameraNode?.position.x)! - 370
        
        // Player movement
        guard let joystickKnob = joystickKnob else { return }
        let xPosition = Double(joystickKnob.position.x)
        
        let positivePosition = xPosition < 0 ? -xPosition : xPosition
        
        if floor(positivePosition) != 0 {
            playerStateMachine.enter(WalkingState.self)
        } else {
            playerStateMachine.enter(IdleState.self)
        }
        
        let displacement = CGVector(dx: deltaTime * xPosition * playerSpeed, dy: 0)
        
        let moveAction = SKAction.move(by: displacement, duration: 0)
        let faceAction: SKAction!
        
        let isMovingRight = xPosition > 0
        let isMovingLeft = xPosition < 0
        
        if isMovingLeft && isPlayerFacingRight {
            isPlayerFacingRight = false
            let faceMovement = SKAction.scaleX(to: -1.5, duration: 0.0)
            faceAction = SKAction.sequence([moveAction, faceMovement])
        } else if isMovingRight && !isPlayerFacingRight {
            isPlayerFacingRight = true
            let faceMovement = SKAction.scaleX(to: 1.5, duration: 0.0)
            faceAction = SKAction.sequence([moveAction, faceMovement])
        } else {
            faceAction = moveAction
        }
        player?.run(faceAction)
        
        // Background Parallax
        
        let parallax1 = SKAction.moveTo(x: (player?.position.x)!/(-10), duration: 0)
        mountains1?.run(parallax1)
        
        let parallax2 = SKAction.moveTo(x: (player?.position.x)!/(-20), duration: 0)
        mountains2?.run(parallax2)
        
        let parallax3 = SKAction.moveTo(x: (player?.position.x)!/(-40), duration: 0)
        mountains3?.run(parallax3)
        
//        let parallax4 = SKAction.moveTo(x: (cameraNode?.position.x)!, duration: 0.0)
//        moon?.run(parallax4)
        
        let parallax5 = SKAction.moveTo(x: (cameraNode?.position.x)!, duration: 0.0)
        stars?.run(parallax5)
        
        let parallax6 = SKAction.moveTo(x: (cameraNode?.position.x)!, duration: 0.0)
        topBg?.run(parallax6)
        
    }
}

// MARK: - Collision
extension GameScene: SKPhysicsContactDelegate {
    struct Collision {
        enum Masks: Int {
            case killing, player, reward, ground
            
            var bitmask: UInt32 {
                return 1 << self.rawValue
            }
        }
        
        let masks: (first: UInt32, second: UInt32)
        
        func matches(_ first: Masks, _ second: Masks) -> Bool {
            return (first.bitmask == masks.first && second.bitmask == masks.second) || (first.bitmask == masks.second && second.bitmask == masks.first)
        }
    }
    
    public func didBegin(_ contact: SKPhysicsContact) {
        let collision = Collision(masks: (first: contact.bodyA.categoryBitMask, second: contact.bodyB.categoryBitMask))
        
        if collision.matches(.player, .killing) {
            loseHeart()
            isHit = true

            Audio.sharedInstance.playSound(soundFileName: Sound.hit.fileName)
            
            playerStateMachine.enter(StunnedState.self)
        }
        
        if collision.matches(.player, .ground) {
            playerStateMachine.enter(LandingState.self)
        }
        
        if collision.matches(.player, .reward) {
            if contact.bodyA.node?.name == "jewel" {
                contact.bodyA.node?.physicsBody?.categoryBitMask = 0
//                contact.bodyA.node?.removeFromParent()
            } else if contact.bodyB.node?.name == "jewel" {
                contact.bodyB.node?.physicsBody?.categoryBitMask = 0
//                contact.bodyB.node?.removeFromParent()
            }

            if rewardIsNotTouched {
                rewardTouch()
                rewardIsNotTouched = false
            }
            
            Audio.sharedInstance.playSound(soundFileName: Sound.reward.fileName)
            
        }
        
    }
}

