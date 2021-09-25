//
//  ShowTheKnowledge.swift
//  WhereIsMyMon
//
//  Created by Blacour on 2020/5/9.
//  Copyright © 2020 Blacour. All rights reserved.
//

import Foundation
import SpriteKit

@objc(ShowTheKnowledge)
public class ShowTheKnowledge : SKScene {
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
           guard let joystickKnob = joystickKnob else { return } //打开可选择节点，确认存在joystickknob节点
           let xPosition = Double(joystickKnob.position.x) //赋予按钮的x坐标
           let yPosition = Double(joystickKnob.position.y) //赋予按钮的y坐标
           //        let displacement = CGVector(dx: deltaTime * xPosition * playerSpeed, dy: 0)
           let displacement = CGVector(dx: deltaTime * xPosition * playerSpeed, dy: deltaTime * yPosition * playerSpeed) //持续时间乘坐标乘移动速度得到距离
           let move = SKAction.move(by: displacement, duration: 0) //设置移动动画
           let faceAction : SKAction!
           let movingRight = xPosition > 0 //xP大于0时为向右移动
           let movingLeft = xPosition < 0 //xP小于0时为向左移动
           if movingLeft && playerIsFacingRight {
               playerIsFacingRight = false //将bool设为false
               let faceMovement = SKAction.scaleX(to: -0.2, duration: 0.0) //设置翻转动画
               faceAction = SKAction.sequence([move, faceMovement]) //设置移动和翻转的组动画
           } //当向左移动同时bool为true时
           else if movingRight && !playerIsFacingRight {
               playerIsFacingRight = true
               let faceMovement = SKAction.scaleX(to: 0.2, duration: 0.0)
               faceAction = SKAction.sequence([move, faceMovement])
           } //当向右移动同时bool为false时
           else {
               faceAction = move
           } //当向右移动同时bool为true时
           player?.run(faceAction) //为player添加组动画
        
    }
}
