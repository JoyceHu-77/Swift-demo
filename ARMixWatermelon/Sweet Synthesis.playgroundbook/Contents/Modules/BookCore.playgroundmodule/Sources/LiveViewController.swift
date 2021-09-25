//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  A source file which is part of the auxiliary module named "BookCore".
//  Provides the implementation of the "always-on" live view.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation
import PlaygroundSupport

public var difficultyLevel = 7

@objc(BookCore_LiveViewController)
public class LiveViewController: UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer, SCNPhysicsContactDelegate, ARSCNViewDelegate {

//    @IBOutlet weak var nextModelImage: UIImageView!
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    var nextModelImage = UIImageView()
    
    var nowLevel = difficultyLevel
    var isStageLoaded = false
    var isRestart = false
    var isLoadHint = false
    var isEulerAnglesChange = false
    var isBegin = true
    var isWin = false
    var isWinMusicPlay = true
    var isLoadEndModel = false
    
    var startModelScene = SCNScene()
    var stageModelScene = SCNScene()
    var fruitModelScene = SCNScene()
    var moveArrowsModelScene = SCNScene()
    
    var stageModelNode = SCNNode()
    var startModelNode = SCNNode()
    var moveArrowsNode = SCNNode()
    
    var endModelNode = SCNNode()
    var mixHintNode = SCNNode()
    
    var fruitNowNode = SCNNode()
    var fruitNodeOffset = SCNVector3()
    var arrowsOffest = SCNVector3()
    
    var groundFruits: [SCNNode] = []
    var cameraOffset: [Float] = [0]
    
    var randomCnt = 1
    var moveOffsetCnt = 1
    var fruitNum = 0
    var nowYOffset = Float()
    var nowYOffset0 = Float()
    
    var afterMixModelAction = SCNAction()
    var mixingModelAction = SCNAction()
    var moveLeftAction = SCNAction()
    var moveRightAction = SCNAction()
    var stopArrowsAction = SCNAction()
    var loadModelAction = SCNAction()
    var loadStageAction = SCNAction()
    var moveArrowAction = SCNAction()
    
    var scoreNode = SKLabelNode()
    var score = 0
    
    var audioPlayer: AVAudioPlayer!
    

    
    var timer = Timer()
    var isWait = true
    
    var timer1 = Timer()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.initSceneView()
        self.initScene()
        self.initARSession()
        playMusic(name: "bg")
        
        sceneView.scene.physicsWorld.contactDelegate = self
        
        startModelScene = SCNScene(named: "fruitModel.scnassets/Start.scn")!
        
        stageModelScene = SCNScene(named: "fruitModel.scnassets/stageModel.scn")!
        stageModelScene.physicsWorld.contactDelegate = self
        
        //        fruitModelScene = SCNScene(named: "fruitModel.scnassets/model.scn")!
        fruitModelScene.physicsWorld.contactDelegate = self
        createNextModelImageView()
        loadStartModel()
        //        loadStageModel()
        addGestureRecognizer0()
        addGestureRecognizerLeft()
        addGestureRecognizerRight()
        addGestureRecognizer()
        
        
    }
    
    //MARK:-init
    func initSceneView() {
        sceneView.delegate = self
        sceneView.showsStatistics = false
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
    }
    
    func initScene() {
        let scene = SCNScene()
        scene.isPaused = false
        sceneView.scene = scene
        scene.lightingEnvironment.intensity = 2
    }
    
    func initARSession() {
        guard ARWorldTrackingConfiguration.isSupported else {
            print("*** ARConfig: AR World Tracking Not Supported")
            return
        }
        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravity
        config.providesAudioData = false
        sceneView.session.run(config)
    }
    
    
    //MARK:- Load Models
    
    func loadMoveArrowsModel(){
        moveArrowsModelScene = SCNScene(named: "fruitModel.scnassets/arrows.scn")!
        moveArrowsNode = moveArrowsModelScene.rootNode.childNode(withName: "arrows", recursively: false)!
        moveArrowsNode.position = SCNVector3(0, 0.3, -4)
        sceneView.scene.rootNode.addChildNode(moveArrowsNode)
    }
    
    func loadStartModel(){
        let startModelScene0 = SCNScene(named: "fruitModel.scnassets/Start.scn")!
        let startModelNode0  = startModelScene0.rootNode.childNode(withName: "start", recursively: false)!
        startModelNode0.position = SCNVector3(0, -0.15, -2)
        sceneView.scene.rootNode.addChildNode(startModelNode0)
        startModelNode = startModelNode0
        
    }
    
    func loadEndModel(){
        moveArrowsNode.removeFromParentNode()
        let model = SCNText(string: "score: \(score) swipe down restart", extrusionDepth: 1)
        model.font = UIFont(name: "Marker Felt Thin", size: 10)
        model.materials.first?.diffuse.contents = UIImage(named: "22")
        endModelNode = SCNNode(geometry: model)
        endModelNode.position = SCNVector3(-7, 1.7, -15)
        endModelNode.scale = SCNVector3(0.1, 0.1, 0.1)
        sceneView.scene.rootNode.addChildNode(endModelNode)
//        isRestart = true
    }
    
    func loadStageModel(){
        nowYOffset = 0
        isLoadEndModel = true
        let stageModelScene0 = SCNScene(named: "fruitModel.scnassets/stageModel.scn")!
        stageModelScene0.physicsWorld.contactDelegate = self
        let stageModelNode0 = stageModelScene0.rootNode.childNode(withName: "lanzi2", recursively: false)!
        stageModelNode0.position = SCNVector3(0, -1, -4)
        
        let audioSource = SCNAudioSource(named: "loadStage.mp3")!
        loadStageAction = SCNAction.playAudio(audioSource, waitForCompletion: false)
        stageModelNode0.runAction(loadStageAction)
        
        sceneView.scene.rootNode.addChildNode(stageModelNode0)
        stageModelNode = stageModelNode0
        isRestart = false
    }
    
    func loadModels(fruitNum: Int){
        let model = SCNCylinder(radius: CGFloat(fruitNum - 1) * 0.04 + 0.05, height: 0.1)
        model.materials.first?.diffuse.contents = UIImage(named: "\(fruitNum)")
        let modelNewNode = SCNNode(geometry: model)
        modelNewNode.eulerAngles = SCNVector3(90, 0, 0)
        modelNewNode.name = "model\(randomCnt).\(fruitNum)"
        
        fruitNodeOffset = SCNVector3(nowYOffset, 0.3, -4)
        
        modelNewNode.position = fruitNodeOffset
        
        let modelPhysicsShap = SCNPhysicsShape(geometry: model, options: nil)
        modelNewNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: modelPhysicsShap)
        
        modelNewNode.physicsBody?.categoryBitMask = -1
        modelNewNode.physicsBody?.collisionBitMask = -1
        modelNewNode.physicsBody?.contactTestBitMask = fruitNum
        
        let force = SCNVector3(x: 0, y: -0.00000000001 , z: 0)
        let position = SCNVector3(x: 0, y: 0, z: 0)
        modelNewNode.physicsBody?.applyForce(force,
                                             at: position, asImpulse: true)
        
        modelNewNode.physicsBody?.friction = 2
        
        let audioSource = SCNAudioSource(named: "falldown2.mp3")!
        loadModelAction = SCNAction.playAudio(audioSource, waitForCompletion: false)
        modelNewNode.runAction(loadModelAction)
        
        sceneView.scene.rootNode.addChildNode(modelNewNode)
        
        groundFruits.append(modelNewNode)
        fruitNowNode = modelNewNode
        
        randomFruit()
    }
    
    
    func randomFruit(){
        randomCnt += 1
        switch randomCnt {
        case 1...3:
            fruitNum = 1
        case 4:
            fruitNum = 2
        case 5:
            fruitNum = 3
        default:
            fruitNum = Int(arc4random() % 3) + 1
        }
        print(fruitNum)
        if fruitNum == 1 {
            nextModelImage.image = UIImage(named: "11")
        } else {
            nextModelImage.image = UIImage(named: "\(fruitNum)")
        }
    }
    
    //MARK:-Move Model position
    func moveArrowsLeft(){
        
        if moveArrowsNode.presentation.position.x < -0.65 {
            stopArrowsAction = SCNAction.sequence([SCNAction.fadeOut(duration: 0.5), SCNAction.fadeIn(duration: 0.5)])
            moveArrowsNode.runAction(stopArrowsAction)
        } else{
            moveLeftAction = SCNAction.moveBy(x: -0.1, y: 0, z: 0, duration: 1)
            moveArrowsNode.runAction(moveLeftAction)
            let audioSource = SCNAudioSource(named: "move.mp3")!
            moveArrowAction = SCNAction.playAudio(audioSource, waitForCompletion: false)
            moveArrowsNode.runAction(moveArrowAction)
            nowYOffset = moveArrowsNode.presentation.position.x - 0.1
            print("arrowoffset:\(nowYOffset)")
        }
    }
    func moveArrowsRight(){
        if moveArrowsNode.presentation.position.x > 0.65 {
            stopArrowsAction = SCNAction.sequence([SCNAction.fadeOut(duration: 0.5), SCNAction.fadeIn(duration: 0.5)])
            moveArrowsNode.runAction(stopArrowsAction)
        } else{
            moveRightAction = SCNAction.moveBy(x: 0.1, y: 0, z: 0, duration: 1)
            moveArrowsNode.runAction(moveRightAction)
            let audioSource = SCNAudioSource(named: "move.mp3")!
            moveArrowAction = SCNAction.playAudio(audioSource, waitForCompletion: false)
            moveArrowsNode.runAction(moveArrowAction)
            nowYOffset = moveArrowsNode.presentation.position.x + 0.1
        }
    }
    
    //MARK:-Place The Model
    func addGestureRecognizer() {
        let downSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(downSwipeFunc))
        downSwipeGestureRecognizer.direction = .down
        view.addGestureRecognizer(downSwipeGestureRecognizer)
    }
    
    @objc func downSwipeFunc(recognizer: UISwipeGestureRecognizer){
        
        if isRestart == false && isLoadEndModel == true{
            if randomCnt == 1 {
                loadModels(fruitNum: 1)
            } else{
                loadModels(fruitNum: fruitNum)
            }
        } else if isRestart == true{
            restartGame()
        }
    }
    
    func addGestureRecognizerLeft() {
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipeFunc))
        leftSwipeGestureRecognizer.direction = .left
        view.addGestureRecognizer(leftSwipeGestureRecognizer)
    }
    
    @objc func leftSwipeFunc(recognizer: UISwipeGestureRecognizer){
        moveArrowsLeft()
    }
    
    func addGestureRecognizerRight() {
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipeFunc))
        rightSwipeGestureRecognizer.direction = .right
        view.addGestureRecognizer(rightSwipeGestureRecognizer)
    }
    
    @objc func rightSwipeFunc(recognizer: UISwipeGestureRecognizer){
        moveArrowsRight()
    }
    
    func addGestureRecognizer0() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapFunc))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapFunc(recognizer: UITapGestureRecognizer){
        if isStageLoaded == false {
            startModelNode.removeFromParentNode()
            loadStageModel()
            loadMoveArrowsModel()
            isStageLoaded = true
        }
    }
    
    
    //MARK:-Restart
    func restartGame(){
        isWin = false
        isWinMusicPlay = true
        endModelNode.removeFromParentNode()
        stageModelNode.removeFromParentNode()
//        moveArrowsNode.removeFromParentNode()
        score = 0
        loadStartModel()
        isStageLoaded = false
        randomCnt = 1
        fruitNum = 0
        nextModelImage.image = UIImage(named: "11")
    }
    
    
    
    //MARK:-Mix Fruits
    func mixFruit(fruitNum: Int, position: SCNVector3) -> SCNNode? {
        if fruitNum == nowLevel && isWin == false{
            
            createWin()
            loadEndModel()
            return nil
        }
        let model = SCNCylinder(radius: CGFloat(fruitNum) * 0.04 + 0.05, height: 0.1)
        model.materials.first?.diffuse.contents = UIImage(named: "\(fruitNum + 1)")
        let fruitAfterMixNode = SCNNode(geometry: model)
        fruitAfterMixNode.eulerAngles = SCNVector3(90, 0, 0)
        fruitAfterMixNode.position = position
        
        let modelPhysicsShap = SCNPhysicsShape(geometry: model, options: nil)
        fruitAfterMixNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: modelPhysicsShap)
        
        fruitAfterMixNode.physicsBody?.categoryBitMask = -1
        fruitAfterMixNode.physicsBody?.collisionBitMask = -1
        if fruitNum == 7 {
            fruitAfterMixNode.physicsBody?.contactTestBitMask = -1
        }else{
            fruitAfterMixNode.physicsBody?.contactTestBitMask = fruitNum + 1
        }
        
        fruitAfterMixNode.physicsBody?.friction = 2
        
        fruitAfterMixNode.name = "modelMix\(fruitNum + 1)"
        
        //        createMixingAction(mixNode: fruitAfterMixNode)
        var audioSource = SCNAudioSource()
        if isWin == false{
            audioSource = SCNAudioSource(named: "bomb2.mp3")!
            mixingModelAction = SCNAction.playAudio(audioSource, waitForCompletion: false)
        }
        
        
        fruitAfterMixNode.runAction(mixingModelAction)
        
        sceneView.scene.rootNode.addChildNode(fruitAfterMixNode)
        
        return fruitAfterMixNode
    }
    
    func generateNewFruitFromPosition(fruitName: String, position: SCNVector3) {
        let fruitNum = Int(fruitName.suffix(1))! //提取字符串后几位
        // add new Fruit
        guard let mixFruit = mixFruit(fruitNum: fruitNum, position: position) else { return }
        groundFruits.append(mixFruit)
    }
    
    
    //MARK:-Collisions
    public func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        
        if nodeB.physicsBody?.contactTestBitMask == 1 && nodeA.physicsBody?.contactTestBitMask == 1 && isWait == true{
            let newFruitPosition = SCNVector3(
                x: (nodeA.presentation.position.x + nodeB.presentation.position.x) / 2,
                y: (nodeA.presentation.position.y + nodeB.presentation.position.y) / 2 + 0.1,
                z: -4)
            
            let trailEmitter = SCNParticleSystem(named: "Explode.scnp", inDirectory: nil)!
            trailEmitter.emitterShape = nodeA.geometry
            nodeA.addParticleSystem(trailEmitter)
            
            nodeB.removeFromParentNode()
            //            createMixModelAction(node: nodeA)
            //            createMixModelAction(node: nodeB)
            nodeA.removeFromParentNode()
            
            
            
            print("合成新节点2")
            generateNewFruitFromPosition(fruitName: nodeA.name!, position: newFruitPosition)
            score += 2
            mixHintNode.removeFromParentNode()
            createMixHint()
            //            playMusic(name: "bomb")
            isWait = false
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(processTimer), userInfo: nil, repeats: false)
            
        }
        
        
        if nodeB.physicsBody?.contactTestBitMask == 2 && nodeA.physicsBody?.contactTestBitMask == 2 && isWait == true {
            print("碰撞nodeA的位置\(nodeB.worldFront)")
            let newFruitPosition = SCNVector3(
                x: (nodeA.presentation.position.x + nodeB.presentation.position.x) / 2,
                y: (nodeA.presentation.position.y + nodeB.presentation.position.y) / 2 + 0.1,
                z: -4)
            nodeA.removeFromParentNode()
            nodeB.removeFromParentNode()
            //            createMixModelAction(node: nodeA)
            //            createMixModelAction(node: nodeB)
            print("合成新节点3")
            generateNewFruitFromPosition(fruitName: nodeA.name!, position: newFruitPosition)
            score += 4
            //            scoreLable.text = "\(score)"
            if isLoadHint == true{
                mixHintNode.removeFromParentNode()
            }
            createMixHint()
            //            playMusic(name: "bomb")
            isWait = false
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(processTimer), userInfo: nil, repeats: false)
        }
        
        if nodeB.physicsBody?.contactTestBitMask == 3 && nodeA.physicsBody?.contactTestBitMask == 3 && isWait == true {
            let newFruitPosition = SCNVector3(
                x: (nodeA.presentation.position.x + nodeB.presentation.position.x) / 2,
                y: (nodeA.presentation.position.y + nodeB.presentation.position.y) / 2,
                z: -4)
            nodeA.removeFromParentNode()
            nodeB.removeFromParentNode()
            //            createMixModelAction(node: nodeA)
            //            createMixModelAction(node: nodeB)
            print("合成新节点4")
            generateNewFruitFromPosition(fruitName: nodeA.name!, position: newFruitPosition)
            score += 8
            //            scoreLable.text = "\(score)"
            if isLoadHint == true{
                mixHintNode.removeFromParentNode()
            }
//            createMixHint()
            //            playMusic(name: "bomb")
            isWait = false
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(processTimer), userInfo: nil, repeats: false)
        }
        
        if nodeB.physicsBody?.contactTestBitMask == 4 && nodeA.physicsBody?.contactTestBitMask == 4 && isWait == true {
            let newFruitPosition = SCNVector3(
                x: (nodeA.presentation.position.x + nodeB.presentation.position.x) / 2,
                y: (nodeA.presentation.position.y + nodeB.presentation.position.y) / 2,
                z: -4)
            nodeA.removeFromParentNode()
            nodeB.removeFromParentNode()
            //            createMixModelAction(node: nodeA)
            //            createMixModelAction(node: nodeB)
            print("合成新节点5")
            generateNewFruitFromPosition(fruitName: nodeA.name!, position: newFruitPosition)
            score += 16
            //            scoreLable.text = "\(score)"
            if isLoadHint == true{
                mixHintNode.removeFromParentNode()
            }
            createMixHint()
            //            playMusic(name: "bomb")
            isWait = false
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(processTimer), userInfo: nil, repeats: false)
        }
        
        if nodeB.physicsBody?.contactTestBitMask == 5 && nodeA.physicsBody?.contactTestBitMask == 5 && isWait == true {
            let newFruitPosition = SCNVector3(
                x: (nodeA.presentation.position.x + nodeB.presentation.position.x) / 2,
                y: (nodeA.presentation.position.y + nodeB.presentation.position.y) / 2,
                z: -4)
            nodeA.removeFromParentNode()
            nodeB.removeFromParentNode()
            //            createMixModelAction(node: nodeA)
            //            createMixModelAction(node: nodeB)
            print("合成新节点6")
            generateNewFruitFromPosition(fruitName: nodeA.name!, position: newFruitPosition)
            score += 32
            //            scoreLable.text = "\(score)"
            mixHintNode.removeFromParentNode()
            createMixHint()
            //            playMusic(name: "bomb")
            isWait = false
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(processTimer), userInfo: nil, repeats: false)
        }
        
        if nodeB.physicsBody?.contactTestBitMask == 6 && nodeA.physicsBody?.contactTestBitMask == 6 && isWait == true {
            let newFruitPosition = SCNVector3(
                x: (nodeA.presentation.position.x + nodeB.presentation.position.x) / 2,
                y: (nodeA.presentation.position.y + nodeB.presentation.position.y) / 2,
                z: -4)
            nodeA.removeFromParentNode()
            nodeB.removeFromParentNode()
            //            createMixModelAction(node: nodeA)
            //            createMixModelAction(node: nodeB)
            print("合成新节点7")
            generateNewFruitFromPosition(fruitName: nodeA.name!, position: newFruitPosition)
            score += 64
            //            scoreLable.text = "\(score)"
            mixHintNode.removeFromParentNode()
            createMixHint()
            //            playMusic(name: "bomb")
            isWait = false
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(processTimer), userInfo: nil, repeats: false)
        }
        
        if nodeB.physicsBody?.contactTestBitMask == 7 && nodeA.physicsBody?.contactTestBitMask == 7 && isWait == true {
            let newFruitPosition = SCNVector3(
                x: (nodeA.presentation.position.x + nodeB.presentation.position.x) / 2,
                y: (nodeA.presentation.position.y + nodeB.presentation.position.y) / 2,
                z: -4)
            nodeA.removeFromParentNode()
            nodeB.removeFromParentNode()
            //            createMixModelAction(node: nodeA)
            //            createMixModelAction(node: nodeB)
            print("合成新节点8")
            generateNewFruitFromPosition(fruitName: nodeA.name!, position: newFruitPosition)
            score += 128
            //            scoreLable.text = "\(score)"
            mixHintNode.removeFromParentNode()
//            createMixHint()
            //            playMusic(name: "win")
            isWait = false
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(processTimer), userInfo: nil, repeats: false)
        }
        
    }
    
    
    //MARK:-After Collisions
    func createMixHint(){
        isLoadHint = true
        let stringArray: [String] = ["Great", "Good", "Excellent", "Perfect"]
        let ranNum = Int(arc4random() % 4) + 1
        let model = SCNText(string: "\(stringArray[ranNum - 1])", extrusionDepth: 1)
        model.materials.first?.diffuse.contents = UIImage(named: "\(ranNum + 1)\(ranNum + 1)")
        model.font = UIFont(name: "Marker Felt Thin", size: 12)
        mixHintNode = SCNNode(geometry: model)
        mixHintNode.position = SCNVector3(-5, 0.6, -12)
        mixHintNode.scale = SCNVector3(0.08, 0.08, 0.08)
        sceneView.scene.rootNode.addChildNode(mixHintNode)
        //        afterMixModelAction = SCNAction.fadeOut(duration: 2.5)
        afterMixModelAction = SCNAction.sequence([SCNAction.wait(duration: 1.5),SCNAction.group([SCNAction.moveBy(x: 0, y: 1, z: 0, duration: 1),SCNAction.fadeOut(duration: 1)])])
        mixHintNode.runAction(afterMixModelAction)
    }
    
    //MARK:-Win
    func createWin(){
        isWin = true
        isLoadEndModel = false
        let model = SCNCylinder(radius: 14 * 0.04 + 0.05, height: 0.1)
        model.materials.first?.diffuse.contents = UIImage(named: "8")
        let fruitAfterMixNode = SCNNode(geometry: model)
        fruitAfterMixNode.eulerAngles = SCNVector3(90, 0, 0)
        fruitAfterMixNode.position = SCNVector3(0, -0.2, -3)
        
        var audioSource = SCNAudioSource()
        if isWinMusicPlay == true {
            audioSource = SCNAudioSource(named: "win2.mp3")!
            mixingModelAction = SCNAction.playAudio(audioSource, waitForCompletion: false)
        }
        fruitAfterMixNode.runAction(mixingModelAction)
        isWinMusicPlay = false
        
        let trail = SCNParticleSystem(named: "Explode.scnp", inDirectory: nil)!
        fruitAfterMixNode.addParticleSystem(trail)
        
        let winAction = SCNAction.sequence([SCNAction.wait(duration: 3), SCNAction.removeFromParentNode()])
        
        fruitAfterMixNode.runAction(winAction)
        
        sceneView.scene.rootNode.addChildNode(fruitAfterMixNode)
        
        timer = Timer.scheduledTimer(timeInterval: 3.5, target: self, selector: #selector(processTimer1), userInfo: nil, repeats: false)
        
    }
    
    
    //MARK:-Play Music
    func playMusic(name:String){
        let musicUrl = NSURL(fileURLWithPath: Bundle.main.path(forResource: name, ofType: "mp3")!)
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: musicUrl as URL)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            audioPlayer.numberOfLoops = -1
            audioPlayer.volume = 1
        } catch {
            print("播放错误")
        }
    }
    
    
    //MARK:-Update
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    }
    
    
    //MARK:-Timer
    @objc func processTimer(){
        isWait = true
    }
    @objc func processTimer1(){
        isRestart = true
    }
    
    
    //MARK:-UI
    func createNextModelImageView(){
        nextModelImage.frame = CGRect(x: 1037, y: 33, width: 60, height: 70)
        nextModelImage.image = UIImage(named: "11")
        nextModelImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextModelImage)
        
        nextModelImage.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 33.0).isActive = true  //顶部约束
        nextModelImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 1037.0).isActive = true  //左端约束
        nextModelImage.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -56.0).isActive = true  //右端约束
        nextModelImage.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -700.0).isActive = true  //底部约束
        
    }
    
    
    
    
}
