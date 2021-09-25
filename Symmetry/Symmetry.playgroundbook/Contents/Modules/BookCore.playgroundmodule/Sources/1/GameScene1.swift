//
//  GameScene.swift
//  WhereIsMyMon
//
//  Created by Blacour on 2020/5/2.
//  Copyright © 2020 Blacour. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

@objc(GameScene1)
public class GameScene1: SKScene {
    
    //Nodes
    var background = SKSpriteNode(imageNamed: "background4")
    var player : SKNode? //设置玩家节点
    var joystick : SKNode? //设置操纵杆节点
    var joystickKnob : SKNode? //设置操纵杆按钮节点
    var cameraNode : SKCameraNode?
    
    
    //boolean
    var joystickAction = false //设置初始操纵杆动画为false
    var rewardIsNotTouched = true //防止多次触碰，分数不属实，成倍增加
    var isHit = true //判断是否撞击
    
    //measure
    var knobRadius : CGFloat = 50.0 //设置操纵杆按钮半径
    
    //score
    let scoreLabel = SKLabelNode() //设置积分标签
    var score = 0 //设置初始分数为0
    
    //heart
    var heartsArray = [SKSpriteNode]()
    let heartContainer = SKSpriteNode()
    
    //sprite engine
    var previousTimeInterval : TimeInterval = 0 //设置初始之前时间为0
    var playerIsFacingRight = true //设置bool值玩家初始朝向为右
    let playerSpeed = 4.0 //设置移动速度为4
    
    //didmove
    public override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self //设置物理效果范围
        
        player = childNode(withName: "player") //将player图片放入玩家节点
        joystick = childNode(withName: "joystick") //将joystick图片放入操纵杆节点
        joystickKnob = joystick?.childNode(withName: "knob") //将knob图片放入操纵杆按钮节点
        cameraNode = childNode(withName: "cameraNode") as? SKCameraNode
        background.zPosition = -1
        addChild(background)
        //hearts
        heartContainer.position = CGPoint(x: -380, y: 200)
        heartContainer.zPosition = 50
//        addChild(heartContainer)
         cameraNode?.addChild(heartContainer)
        fillHearts(count: 3)
        
        //sand timer
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true){(timer) in
            self.spawnSand()
        } //添加计时器0.3秒生成一个沙子
        
        scoreLabel.position = CGPoint(x: 380, y: 200) //设置标签位置
        scoreLabel.fontColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1) //标签颜色
        scoreLabel.fontSize = 35 //b字体大小
        scoreLabel.zPosition = 50
        scoreLabel.fontName = "AvenirNext-Bold" //字体样式
        scoreLabel.horizontalAlignmentMode = .right //字体向右对齐
        scoreLabel.text = String(score) //标签内容
//        addChild(scoreLabel) //添加标签
         cameraNode?.addChild(scoreLabel)
    }
}

//MARK:-Touches
extension GameScene1 {
    //touch began
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let joystickKnob = joystickKnob {
                let location = touch.location(in: joystick!) //将在操纵杆范围内触碰的位置，储存为当前位置节点
                joystickAction = joystickKnob.frame.contains(location) //坐标点落在knob范围内或边界上返回true
            } //打开可选择节点，确认存在joystickknob节点
        }
    } //刚触碰时的函数
    
    //touch move
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let joystick = joystick else { return } //打开可选择节点，确认存在joystick节点
        guard let joystickKnob = joystickKnob else { return } //打开可选择节点，确认存在joystickknob节点
        
        if !joystickAction { return } //操纵杆无动画时返回
        
        //distance
        for touch in touches{
            let position = touch.location(in: joystick) //将在操纵杆范围内触碰的位置，储存为当前位置节点
            
            let length = sqrt(pow(position.y, 2) + pow(position.x, 2)) //触碰位置与knob中心位置的长度（勾股定理）
            let angle = atan2(position.y, position.x) //触碰位置与knob中心位置的角度
            
            if knobRadius > length {
                joystickKnob.position = position //当操纵杆按钮半径大于长度时，将当前位置节点赋给按钮的位置节点
            } else {
                joystickKnob.position = CGPoint(x: cos(angle) * knobRadius, y: sin(angle) * knobRadius)
            } //当长度大于按钮半径时，求出移动后的位置节点
        } //在触碰范围内的触碰循环
    }
    
    //touch end
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let xJoystickCoordinate = touch.location(in: joystick!).x //将在操纵杆范围内触碰的位置x，储存为当前位置节点
            let xLimit: CGFloat = 200.0 //设置限制位置x
            if xJoystickCoordinate > -xLimit && xJoystickCoordinate < xLimit {
                resetKnobPosition() //实现重制按钮初始位置动画
            }
        }
    }
}

//MARK:-action
extension GameScene1 {
    func resetKnobPosition() {
        let initialPoint = CGPoint(x: 0, y: 0) //设置按钮初始位置为（0，0）
        let moveBack = SKAction.move(to: initialPoint, duration: 0.1) //设置移动动画
        moveBack.timingMode = .linear //控制动画速度曲线（线性均匀移动）
        joystickKnob?.run(moveBack) //运行动画
        joystickAction = false //将动画状态调至否
    }
    
    func rewardTouch() {
        score += 1 //触碰奖励时分数加一
        scoreLabel.text = String(score) //更新标签内容
    }
    
    func fillHearts(count: Int) {
        for index in 1...count {
            let heart = SKSpriteNode(imageNamed: "heart")
            let xPosition = heart.size.width * CGFloat(index - 1)
            heart.position = CGPoint(x: xPosition, y: 0)
            heartsArray.append(heart) //在数组中添加心心
            heartContainer.addChild(heart) //将心心添加到容器中
        }
    }
    
    func loseHeart() {
        if isHit == true {
            let lastElementIndex = heartsArray.count - 1
            if heartsArray.indices.contains(lastElementIndex - 1) { //indices按升序对集合下标有效的索引,contains返回一个布尔值，指示给定元素是否包含在范围表达式中。
                //如果后面还有心，生命没用完的话
                let lastHeart = heartsArray[lastElementIndex]
                lastHeart.removeFromParent() //将最后一颗心的节点在画面中移除
                heartsArray.remove(at: lastElementIndex) //在数组中移除最后一颗心
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) {(timer) in
                    self.isHit = false
                }
            } else {
                dying()
//                showDieScene()
            }
            invincuble()
        }
    }
    
    func invincuble() { //设置一秒的无敌状态
        player?.physicsBody?.categoryBitMask = 0 //让player的categoryBitMask为0无法碰撞
        let action = SKAction.repeat(.sequence([
            .fadeAlpha(to: 0.5, duration: 0.01),
            .wait(forDuration: 0.15),
            .fadeAlpha(to: 1.0, duration: 0.01),
            .wait(forDuration: 0.15)
        ]), count: 4)
        player?.run(action) //添加闪烁动画
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
            self.player?.physicsBody?.categoryBitMask = 2 //1秒后恢复
        }
    }
    
    func dying() {
        let dieAction = SKAction.move(to: CGPoint(x: -300, y: 0), duration: 0.1)
        player?.run(dieAction)
        self.removeAllActions()
        fillHearts(count: 3)
    }
    
    func showDieScene() {
        let gameOverScene = GameScene1(fileNamed: "GameOver")
        gameOverScene?.scaleMode = .aspectFill
        self.view?.presentScene(gameOverScene)
    }
}

//MARK:-game loop
extension GameScene1 {
    public override func update(_ currentTime: TimeInterval) {
        
        let deltaTime = currentTime - previousTimeInterval //拖动持续时间（当前时间减去之前时间）
        previousTimeInterval = currentTime //更新，将现在时间赋予之前时间
        
        rewardIsNotTouched = true //游戏初始设置
        
        // Camera
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
            let faceMovement = SKAction.scaleX(to: -0.4, duration: 0.0) //设置翻转动画
            faceAction = SKAction.sequence([move, faceMovement]) //设置移动和翻转的组动画
        } //当向左移动同时bool为true时
        else if movingRight && !playerIsFacingRight {
            playerIsFacingRight = true
            let faceMovement = SKAction.scaleX(to: 0.4, duration: 0.0)
            faceAction = SKAction.sequence([move, faceMovement])
        } //当向右移动同时bool为false时
        else {
            faceAction = move
        } //当向右移动同时bool为true时
        player?.run(faceAction) //为player添加组动
        
        //通关后转场
        if score >= 4 {
            let nextScene = GameScene1(fileNamed: "ShowTheKnowledge")
            nextScene?.scaleMode = .aspectFill
            self.view?.presentScene(nextScene)
            removeAllActions()
        }
    }
}

//MARK:-collision
extension GameScene1 : SKPhysicsContactDelegate {
    
    struct Collision {
        enum Masks : Int {
            case killing, player, reward, ground // 0, 1, 2, 4
            var bitmask: UInt32 { return 1 << self.rawValue } // 1, 2, 4, 8
        }
        let masks: (first : UInt32, second : UInt32)
        
        func matches (_ first : Masks, _ second:Masks) -> Bool {
            return ( first.bitmask == masks.first && second.bitmask == masks.second) || (second.bitmask == masks.first && first.bitmask == masks.second )
        } //设置让a触碰b等于b触碰a
    }
    
    public func didBegin(_ contact: SKPhysicsContact) {
        
        let collistion = Collision(masks: (first: contact.bodyA.categoryBitMask, second: contact.bodyB.categoryBitMask))
        
        if collistion.matches(.player, .killing) { //主体和障碍物碰撞
            loseHeart()
            isHit = true
        }
        
        if collistion.matches(.player, .reward) { //主体和奖励的碰撞
            if contact.bodyA.node?.name == "jewel" {
                contact.bodyA.node?.physicsBody?.categoryBitMask = 0
                                contact.bodyA.node?.removeFromParent()
            } //如果a是奖励，让它的categoryBitMask为0，避免再次触碰
            else if contact.bodyB.node?.name == "jewel" {
                contact.bodyB.node?.physicsBody?.categoryBitMask = 0
                contact.bodyB.node?.removeFromParent() //b是奖励时，在触碰后将奖励移除
            } //如果b是奖励，让它的categoryBitMask为0，避免再次触碰
            
            if rewardIsNotTouched { //未触碰时
                rewardTouch() //运行分数加一函数
                rewardIsNotTouched = false //并调整bool
            }
        }
    }
}

//MARK:- sand
extension GameScene1 {
    
    func spawnSand() {
        let node = SKSpriteNode(imageNamed: "sand4")
        node.name = "Sand"
        let randomXPosition = Int.random(in: 0...1024)//Int(arc4random_uniform(UInt32(self.size.width))) //设置沙子随机位置
        
        node.position = CGPoint(x: randomXPosition, y: 270) //安置随机位置
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5) //设置锚点
        node.zPosition = 10 //置顶
        
        let physicsBody = SKPhysicsBody(circleOfRadius:node.size.width/2) //添加盒子
        node.physicsBody = physicsBody
        
        physicsBody.categoryBitMask = Collision.Masks.killing.bitmask //设置沙子的categoryBitMask为killing
        physicsBody.collisionBitMask = Collision.Masks.player.bitmask //设置沙子的collisionBitMask撞击对象为player
        physicsBody.contactTestBitMask = Collision.Masks.player.bitmask //...
        physicsBody.fieldBitMask = Collision.Masks.player.bitmask //...
        
        physicsBody.affectedByGravity = true //受重力影响
        physicsBody.allowsRotation = false //不允许角度变化
        physicsBody.friction = 10 //增加碰撞时的摩擦力
        physicsBody.restitution = 1.0 //弹性
        physicsBody.density = 0.01 //密度
        
        addChild(node) //添加节点
    }
}











