
//

import Foundation
import GameplayKit

public let characterAnimationKey = "Sprite Animation"

public class PlayerState: GKState {
    unowned var playerNode: SKNode
    
    init(playerNode: SKNode) {
        self.playerNode = playerNode
        
        super.init()
    }
}

public class JumpingState: PlayerState {
    var hasFinishedJumping: Bool = false
    
    public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        
        if stateClass is StunnedState.Type {
            return true
        }
        
        if hasFinishedJumping && stateClass is LandingState.Type {
            return true
        }
        return false
    }
    
    let textures: Array<SKTexture> = (0..<2).map({ "jump/\($0)" }).map(SKTexture.init)
    lazy var action = {
        SKAction.animate(with: self.textures, timePerFrame: 0.1)
    }()
    
    public override func didEnter(from previousState: GKState?) {
        playerNode.removeAction(forKey: characterAnimationKey)
        playerNode.run(action, withKey: characterAnimationKey)
        
        hasFinishedJumping = false
        
        playerNode.run(.applyForce(CGVector(dx: 0, dy: 175), duration: 0.1))
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
            self.hasFinishedJumping = true
        }
    }
}

public class LandingState: PlayerState {
    public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is LandingState.Type, is JumpingState.Type:
            return false
        default:
            return true
        }
    }
    
    public override func didEnter(from previousState: GKState?) {
        stateMachine?.enter(IdleState.self)
    }
}

public class IdleState: PlayerState {
    public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is LandingState.Type, is IdleState.Type:
            return false
        default:
            return true
        }
    }
    
    let texture = SKTexture(imageNamed: "player/0")
    lazy var action = {
        SKAction.animate(with: [self.texture], timePerFrame: 0.1)
    }()
    
    public override func didEnter(from previousState: GKState?) {
        playerNode.removeAction(forKey: characterAnimationKey)
        playerNode.run(action, withKey: characterAnimationKey)
    }
}

public class WalkingState: PlayerState {
    public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass{
        case is LandingState.Type, is WalkingState.Type:
            return false
        default:
            return true
        }
    }
    
    let textures: Array<SKTexture> = (0..<6).map({ "player/\($0)" }).map(SKTexture.init)
    lazy var action = {
       SKAction.repeatForever(.animate(with: self.textures, timePerFrame: 0.1))
    }()
    
    public override func didEnter(from previousState: GKState?) {
        playerNode.removeAction(forKey: characterAnimationKey)
        playerNode.run(action, withKey: characterAnimationKey)
    }
}

public class StunnedState: PlayerState {
    var isStunned = false
    
    public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if isStunned {
            return false
        }
        
        switch stateClass {
        case is IdleState.Type:
            return true
        default:
            return false
        }
    }
    
    let action = SKAction.repeat(.sequence([
        .fadeAlpha(to: 0.5, duration: 0.01),
        .wait(forDuration: 0.25),
        .fadeAlpha(to: 1.0, duration: 0.01),
        .wait(forDuration: 0.25)]), count: 5)
    
    public override func didEnter(from previousState: GKState?) {
        isStunned = true
        
        playerNode.run(action)
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
            self.isStunned = false
            self.stateMachine?.enter(IdleState.self)
        }
    }
}
