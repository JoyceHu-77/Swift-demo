
import SpriteKit
import GameplayKit

@objc(ShowTheKnowledge1)
public class ShowTheKnowledge1: SKScene {
    
    // Nodes
    var player : SKNode?
    var joystick : SKNode?
    var joystickKnob : SKNode?
    var cameraNode: SKCameraNode?
    
    // Boolean
    var joystickAction = false
    
    // Measure
    var knobRadius : CGFloat = 50.0
    
    // Sprite Engine
    var previousTimeInterval : TimeInterval = 0
    var playerIsFacingRight = true
    let playerSpeed = 4.0
    
    // didmove
    public override func didMove(to view: SKView) {
        
        player = childNode(withName: "player")
        joystick = childNode(withName: "joystick")
        joystickKnob = joystick?.childNode(withName: "knob")
        cameraNode = childNode(withName: "cameraNode") as? SKCameraNode
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
           for touch in touches {
               if let joystickKnob = joystickKnob {
                   let location = touch.location(in: joystick!)
                   joystickAction = joystickKnob.frame.contains(location)
               }
           }
       }
       
       // Touch Moved
       public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
           guard let joystick = joystick else { return }
           guard let joystickKnob = joystickKnob else { return }
           
           if !joystickAction { return }
           
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
       
       // Touch End
       public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
           for touch in touches {
               let xJoystickCoordinate = touch.location(in: joystick!).x
               let xLimit: CGFloat = 200.0
               if xJoystickCoordinate > -xLimit && xJoystickCoordinate < xLimit {
                   resetKnobPosition()
               }
           }
       }


       func resetKnobPosition() {
           let initialPoint = CGPoint(x: 0, y: 0)
           let moveBack = SKAction.move(to: initialPoint, duration: 0.1)
           moveBack.timingMode = .linear
           joystickKnob?.run(moveBack)
           joystickAction = false
       }

       public override func update(_ currentTime: TimeInterval) {
           let deltaTime = currentTime - previousTimeInterval
           previousTimeInterval = currentTime
        
        cameraNode?.position.x = player!.position.x
               joystick?.position.y = (cameraNode?.position.y)! - 250
               joystick?.position.x = (cameraNode?.position.x)! - 360
           
           // Player movement
           guard let joystickKnob = joystickKnob else { return }
           let xPosition = Double(joystickKnob.position.x)
           let displacement = CGVector(dx: deltaTime * xPosition * playerSpeed, dy: 0)
           let move = SKAction.move(by: displacement, duration: 0)
           let faceAction : SKAction!
           let movingRight = xPosition > 0
           let movingLeft = xPosition < 0
           if movingLeft && playerIsFacingRight {
               playerIsFacingRight = false
            let faceMovement = SKAction.scaleX(to: -0.2, duration: 0.0)
               faceAction = SKAction.sequence([move, faceMovement])
           }
           else if movingRight && !playerIsFacingRight {
               playerIsFacingRight = true
            let faceMovement = SKAction.scaleX(to: 0.2, duration: 0.0)
               faceAction = SKAction.sequence([move, faceMovement])
           } else {
               faceAction = move
           }
           player?.run(faceAction)
       }
}


   
