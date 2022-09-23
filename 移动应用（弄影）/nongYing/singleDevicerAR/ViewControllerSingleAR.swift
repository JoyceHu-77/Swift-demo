//
//  ViewController.swift
//  ARModelTest
//
//  Created by Blacour on 2020/11/5.
//

import UIKit
import SceneKit
import ARKit
import RealityKit
import AVFoundation

class ViewControllerSingleAR: UIViewController, ARSCNViewDelegate {
    
    var modelNode: SCNNode!
    var modelOffset: SCNVector3 = SCNVector3(0.8,0.1,-1.65)
    var modelCopyNode: SCNNode!
    var modelCopyOffset: SCNVector3 = SCNVector3(0.8,0.1,-1.4)
    
    var stageNode: SCNNode!
    var stagePosition = SCNVector3(-0.5,-0.4,-1.5)
    
    var leftMoveAction:SCNAction!
    var leftLowerHalfMoveAction:SCNAction!
    var leftRightHandMoveAction:SCNAction!
    
    var rightMoveAction:SCNAction!
    var rightLowerHalfMoveAction:SCNAction!
    var rightRightHandMoveAction:SCNAction!
    
    var rightHandAction:SCNAction!
    var demonAction:SCNAction!
    var demonReturnAction:SCNAction!
    var demonAppearAction:SCNAction!
    
    var sunWuKongStickAction: SCNAction!
    var moveSWKAction: SCNAction!
    var moveSWKLowerHalfAction:SCNAction!
    
    var moveSWKJumpAction: SCNAction!
    var moveSWKLowerHalfJumpAction: SCNAction!
    var moveSWKStickJumpAction: SCNAction!
    
    var moveDownAction:SCNAction!
    var moveDownRightHandAction:SCNAction!
    
    var moveUpAction:SCNAction!
    var moveUpRightHandAction:SCNAction!
    
    //    var hitSWKStickAction:SCNAction!
    
    var moveToRightBtn = UIButton()
    var moveToLeftBtn = UIButton()
    var sWKJumpBtn = UIButton()
    var sWKStickAttactBtn = UIButton()
    var sWKDownBtn = UIButton()
    var demonFallDownBtn = UIButton()
    
   
    
    var textlabel = UILabel()
    var timer = Timer()
    var timer2 = Timer()
    var timer3 = Timer()
    var timer4 = Timer()
    var timer5 = Timer()
    

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var textViewOne: UIView!
    @IBOutlet weak var textViewTwo: UIView!
    @IBOutlet weak var textViewThree: UIView!
    @IBOutlet weak var textViewFour: UIView!
    
    
    @IBAction func triggerAction(_ sender: UIButton) {
        resetAction()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initSceneView()
        self.initScene()
        self.initARSession()
        self.loadModels()
        
        
       
        self.setUpRightHandAction()
        self.setUpDemonAction()
        self.setUpSWKAttactAction()
        self.setUpSWKJumpAction()
        self.setUpRightMoveAction()
        self.setUpLeftMoveAction()
        self.setUpDownAction()
        self.setUpUpAction()
        

        timer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(processTimer), userInfo: nil, repeats: true)
        
    }
    
    //MARK：音乐的暂停播放
    
    
    //MARK:-init
    func initSceneView() {
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
    }
    
    func initScene() {
        let scene = SCNScene()
        scene.isPaused = false
        sceneView.scene = scene
        scene.lightingEnvironment.contents = "PokerDice.scnassets/Textures/Environment_CUBE.jpg"
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
    
    // MARK: - Load Models
    func loadModels() {
        let stageModelScene = SCNScene(named: "art2.scnassets/Stage.scn")!
        stageNode = stageModelScene.rootNode.childNode(withName: "Stage", recursively: false)!
        //        let stagePosition = SCNVector3(0.0,-0.3,-0.3)
        stageNode.position = stagePosition
        
        sceneView.scene.rootNode.addChildNode(stageNode)
        
        let modelSWKScene = SCNScene(named: "art2.scnassets/SunWuKong.scn")!
        modelNode = modelSWKScene.rootNode.childNode(withName: "SunWuKong", recursively: false)!
        let position = modelOffset
        modelNode.position = position
        //        modelNode.eulerAngles = SCNVector3(0,180,0)
        
        sceneView.scene.rootNode.addChildNode(modelNode)
        
        let modelCopySWKScene = SCNScene(named: "art2.scnassets/SunWuKong.scn")!
        modelCopyNode = modelCopySWKScene.rootNode.childNode(withName: "SunWuKong", recursively: false)
        modelCopyNode.position = modelCopyOffset
        
        sceneView.scene.rootNode.addChildNode(modelCopyNode)
    }
    
    //MARK:-set up animation
    func setUpLeftMoveAction(){
        let rotateToLeftAction = SCNAction.rotateTo(x: 0, y: 160, z: 0, duration: 0.2, usesShortestUnitArc: true)
        let moveToLeftAction = SCNAction.moveBy(x: -0.035, y: 0, z: 0, duration: 0.3)
        leftMoveAction = SCNAction.sequence([rotateToLeftAction,moveToLeftAction])
        
        let rotateLowerHalfOneAction = SCNAction.rotateTo(x: 0, y: 0, z: 50, duration: 0.15, usesShortestUnitArc: true)
        let rotateLowerHalfTwoAction = SCNAction.rotateTo(x: 0, y: 0, z: -50, duration: 0.15, usesShortestUnitArc: true)
        let rotateLowerHalfBackAction = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.13, usesShortestUnitArc: true)
        leftLowerHalfMoveAction = SCNAction.sequence([rotateLowerHalfOneAction,rotateLowerHalfTwoAction,rotateLowerHalfBackAction])
        
        let rotateRightHandAction = SCNAction.rotateTo(x: 0, y: 0, z: 50, duration: 0.15, usesShortestUnitArc: true)
        let rotateRightHandBackAction = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.13, usesShortestUnitArc: true)
        leftRightHandMoveAction = SCNAction.sequence([rotateRightHandAction,rotateRightHandBackAction])
    }
    
    func setUpRightMoveAction(){
        let rotateToRightAction = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.2, usesShortestUnitArc: true)
        let moveToRightAction = SCNAction.moveBy(x: 0.035, y: 0, z: 0, duration: 0.3)
        rightMoveAction = SCNAction.sequence([rotateToRightAction,moveToRightAction])
        
        let rotateLowerHalfOneAction = SCNAction.rotateTo(x: 0, y: 0, z: 50, duration: 0.15, usesShortestUnitArc: true)
        let rotateLowerHalfTwoAction = SCNAction.rotateTo(x: 0, y: 0, z: -50, duration: 0.15, usesShortestUnitArc: true)
        let rotateLowerHalfBackAction = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.13, usesShortestUnitArc: true)
        rightLowerHalfMoveAction = SCNAction.sequence([rotateLowerHalfOneAction,rotateLowerHalfTwoAction,rotateLowerHalfBackAction])
        
        let rotateRightHandAction = SCNAction.rotateTo(x: 0, y: 0, z: 50, duration: 0.15, usesShortestUnitArc: true)
        let rotateRightHandBackAction = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.13, usesShortestUnitArc: true)
        rightRightHandMoveAction = SCNAction.sequence([rotateRightHandAction,rotateRightHandBackAction])
    }
    
    func setUpRightHandAction(){
        let duration = 1.5
        let rotateDownRightHandAction = SCNAction.rotateTo(x: 0, y:0 ,z: 0, duration:duration, usesShortestUnitArc: true)
        let rotateUpRightHandAction = SCNAction.rotateTo(x: 0, y: 0, z: -20, duration: duration, usesShortestUnitArc: true)
        
        let rotateRightHandAction = SCNAction.sequence([rotateUpRightHandAction,rotateDownRightHandAction])
        
        rightHandAction = rotateRightHandAction
        
    }
    
    func setUpSWKAttactAction(){
        
        let rotateStickAction = SCNAction.rotateTo(x: 0, y: 0, z: 310, duration: 1.8 )
        //        let rotateStickAction = SCNAction.rotateTo(x: 0, y: 0, z: 310, duration: duration, usesShortestUnitArc: true)
        let moveStickAction = SCNAction.moveBy(x: 0.23, y: -0.035, z: 0, duration: 1.5)
        let keepMoveStickAction = SCNAction.rotateTo(x: 0, y: 0, z: 60, duration: 1, usesShortestUnitArc: true)
        let sunWuKongStickStartAction = SCNAction.group([rotateStickAction,keepMoveStickAction,moveStickAction])
        
        
        let stickMoveBackAction = moveStickAction.reversed()
        let stickRotateBackAction = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 1, usesShortestUnitArc: true)
        let sunWuKongStickBackAction = SCNAction.group([stickMoveBackAction,stickRotateBackAction])
        sunWuKongStickAction = SCNAction.sequence([sunWuKongStickStartAction,sunWuKongStickBackAction])
        
        
        let moveSWKLowerHalfUpAction = SCNAction.rotateTo(x: 0, y: 0, z: 120, duration: 0.9, usesShortestUnitArc: true)
        let moveSWKLowerHalfDownAction = SCNAction.rotateTo(x: 0, y: 0, z: -120, duration: 0.9, usesShortestUnitArc: true)
        let moveSWKLowerHalfEndDownAction = SCNAction.rotateTo(x: 0, y: 0, z: 100, duration: 1.0, usesShortestUnitArc: true)
        moveSWKLowerHalfAction = SCNAction.sequence([moveSWKLowerHalfUpAction,moveSWKLowerHalfDownAction,moveSWKLowerHalfEndDownAction])
        
        let moveSWKUpAction = SCNAction.moveBy(x: 0.04, y: 0.35, z: 0, duration: 0.8)
        let moveSWKDownMoveAction = SCNAction.moveBy(x: 0.07, y: -0.35, z: 0, duration: 1.2)
        let moveSWKRotateAction = SCNAction.rotateTo(x: 0, y: 0, z: 200, duration: 1, usesShortestUnitArc: true)
        let moveSWKDownAction = SCNAction.group([moveSWKDownMoveAction,moveSWKRotateAction])
        
        let moveBackAction = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 1, usesShortestUnitArc: true)
        let sunWuKongBackAction = SCNAction.group([moveBackAction])
        
        moveSWKAction = SCNAction.sequence([moveSWKUpAction,moveSWKDownAction,sunWuKongBackAction])
        
    }
    
    func setUpSWKJumpAction(){
        //        modelNode.eulerAngles = SCNVector3(0,160,0)
        let sWKJumpUpMoveAction = SCNAction.moveBy(x: -0.03, y: 0.35, z: 0, duration: 0.9)
        let sWKJumpUpRotateAction = SCNAction.rotateTo(x: 0, y: 160, z: 114, duration: 1.0, usesShortestUnitArc: true)
        let moveSWKJumpUpAction = SCNAction.group([sWKJumpUpMoveAction,sWKJumpUpRotateAction])
        let moveSWKJumpKeepAction = SCNAction.moveBy(x: -0.06, y: 0, z: 0, duration: 0.8)
        let sWKJumpDownMoveAction = SCNAction.moveBy(x: 0, y: -0.35, z: 0, duration: 0.6)
        let sWKJumpDownRotateAction = SCNAction.rotateTo(x: 0, y: 160, z: 0, duration: 0.5, usesShortestUnitArc: true)
        let moveSWKJumpDownAction = SCNAction.group([sWKJumpDownMoveAction,sWKJumpDownRotateAction])
        moveSWKJumpAction = SCNAction.sequence([moveSWKJumpUpAction,moveSWKJumpKeepAction,moveSWKJumpDownAction])
        
        let sWKLowerHalfJumpUpOneAction = SCNAction.rotateTo(x: 0, y: 0, z: 140, duration: 0.5, usesShortestUnitArc: true)
        let sWKLowerHalfJumpUpAction = SCNAction.rotateTo(x: 0, y: 0, z: 90, duration: 0.9, usesShortestUnitArc: true)
        let sWKLowerHalfJumpDownAction = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.5, usesShortestUnitArc: true)
        moveSWKLowerHalfJumpAction = SCNAction.sequence([sWKLowerHalfJumpUpOneAction,sWKLowerHalfJumpUpAction,sWKLowerHalfJumpDownAction])
        
        let sWKStickJumpUpAction = SCNAction.rotateTo(x: 0, y: 0, z: 100, duration: 1.0, usesShortestUnitArc: true)
        let sWKStickJumpDownAction = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.8, usesShortestUnitArc: true)
        moveSWKStickJumpAction = SCNAction.sequence([sWKStickJumpUpAction,sWKStickJumpDownAction])
    }
    
    func setUpDownAction(){
        let rotateRightHandAction = SCNAction.rotateTo(x: 0, y: 0, z: 50, duration: 0.15, usesShortestUnitArc: true)
        let rotateRightHandBackAction = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.13, usesShortestUnitArc: true)
        moveDownRightHandAction = SCNAction.sequence([rotateRightHandAction,rotateRightHandBackAction])
        
        moveDownAction = .moveBy(x: 0, y: -0.25, z: 0, duration: 0.3)
    }
    
    func setUpUpAction(){
        let rotateRightHandAction = SCNAction.rotateTo(x: 0, y: 0, z: 50, duration: 0.15, usesShortestUnitArc: true)
        let rotateRightHandBackAction = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.13, usesShortestUnitArc: true)
        moveUpRightHandAction = SCNAction.sequence([rotateRightHandAction,rotateRightHandBackAction])
        
        moveUpAction = .moveBy(x: 0, y: 0.25, z: 0, duration: 0.3)
    }
    
    func resetAction(){
        modelNode.position = modelOffset
        modelCopyNode.position = modelCopyOffset
        modelNode.eulerAngles = SCNVector3(0,0,0)
        modelCopyNode.eulerAngles = SCNVector3(0,0,0)
        stageNode.childNode(withName: "oldMan", recursively: false)?.opacity = 0
        stageNode.childNode(withName: "oldWoman", recursively: false)?.opacity = 0
        stageNode.childNode(withName: "oldManCopy", recursively: false)?.opacity = 0
        stageNode.childNode(withName: "oldWomanCopy", recursively: false)?.opacity = 0
        stageNode.childNode(withName: "oldMan", recursively: false)?.eulerAngles = SCNVector3(0,0,0)
        stageNode.childNode(withName: "oldManCopy", recursively: false)?.eulerAngles = SCNVector3(0,0,0)
        stageNode.childNode(withName: "oldWoman", recursively: false)?.eulerAngles = SCNVector3(0,0,0)
        stageNode.childNode(withName: "oldWomanCopy", recursively: false)?.eulerAngles = SCNVector3(0,0,0)
        
        stageNode.childNode(withName: "SketchUp", recursively: false)?.opacity = 1
        stageNode.childNode(withName: "SketchUp", recursively: false)?.eulerAngles = SCNVector3(0,0,0)
        stageNode.childNode(withName: "SketchUpCopy", recursively: false)?.opacity = 1
        stageNode.childNode(withName: "SketchUpCopy", recursively: false)?.eulerAngles = SCNVector3(0,0,0)
    }
    
    func setUpDemonAction(){
        
        let rotateDownAction = SCNAction.rotateTo(x: 0, y: 0.05, z: 80, duration: 1.8, usesShortestUnitArc: true)
        let fadeDemonAction = SCNAction.fadeOut(duration: 2)
        let demonDownAction = SCNAction.group([rotateDownAction,fadeDemonAction])

        let rotateReturnAction = SCNAction.rotateTo(x: 0, y: 0.05, z: 0, duration: 0.8)
        demonAction = .sequence([demonDownAction,rotateReturnAction])
        
        demonAppearAction = SCNAction.fadeIn(duration: 6)
        
    }
    
    
    //MARK:- add action
    
    func addLeftMoveAction(){
        modelNode.runAction(leftMoveAction)
        modelNode.childNode(withName: "lowerHalf", recursively: false)?.runAction(leftLowerHalfMoveAction)
        modelNode.childNode(withName: "rightHand", recursively: false)?.runAction(leftRightHandMoveAction)
        
        modelCopyNode.runAction(leftMoveAction)
        modelCopyNode.childNode(withName: "lowerHalf", recursively: false)?.runAction(leftLowerHalfMoveAction)
        modelCopyNode.childNode(withName: "rightHand", recursively: false)?.runAction(leftRightHandMoveAction)
    }
    
    func addRightMoveAction(){
        modelNode.runAction(rightMoveAction)
        modelNode.childNode(withName: "lowerHalf", recursively: false)?.runAction(rightLowerHalfMoveAction)
        modelNode.childNode(withName: "rightHand", recursively: false)?.runAction(rightRightHandMoveAction)
        
        modelCopyNode.runAction(rightMoveAction)
        modelCopyNode.childNode(withName: "lowerHalf", recursively: false)?.runAction(rightLowerHalfMoveAction)
        modelCopyNode.childNode(withName: "rightHand", recursively: false)?.runAction(rightRightHandMoveAction)
    }
    
    func addRightHandAction(){
        //        modelNode.runAction(moveRightHandAction)
        modelNode.childNode(withName: "rightHand", recursively: false)?.runAction(rightHandAction)
        
        modelCopyNode.childNode(withName: "rightHand", recursively: false)?.runAction(rightHandAction)
    }
    
    func addSWKStickAction(){
        modelNode.childNode(withName: "stick", recursively: false)?.runAction(sunWuKongStickAction)
        modelNode.childNode(withName: "lowerHalf", recursively: false)?.runAction(moveSWKLowerHalfAction)
        modelNode.runAction(moveSWKAction)
        
        modelCopyNode.childNode(withName: "stick", recursively: false)?.runAction(sunWuKongStickAction)
        modelCopyNode.childNode(withName: "lowerHalf", recursively: false)?.runAction(moveSWKLowerHalfAction)
        modelCopyNode.runAction(moveSWKAction)
    }
    
    func addSWKJumpAction(){
        modelNode.runAction(moveSWKJumpAction)
        modelNode.childNode(withName: "lowerHalf", recursively: false)?.runAction(moveSWKLowerHalfJumpAction)
        modelNode.childNode(withName: "stick", recursively: false)?.runAction(moveSWKStickJumpAction)
        
        modelCopyNode.runAction(moveSWKJumpAction)
        modelCopyNode.childNode(withName: "lowerHalf", recursively: false)?.runAction(moveSWKLowerHalfJumpAction)
        modelCopyNode.childNode(withName: "stick", recursively: false)?.runAction(moveSWKStickJumpAction)
    }
    
    func addDownAction(){
        modelNode.childNode(withName: "rightHand", recursively: false)?.runAction(moveDownRightHandAction)
        modelNode.runAction(moveDownAction)
        modelCopyNode.childNode(withName: "rightHand", recursively: false)?.runAction(moveDownRightHandAction)
        modelCopyNode.runAction(moveDownAction)
    }
    
    func addUpAction(){
        modelNode.childNode(withName: "rightHand", recursively: false)?.runAction(moveUpRightHandAction)
        modelNode.runAction(moveUpAction)
        modelCopyNode.childNode(withName: "rightHand", recursively: false)?.runAction(moveUpRightHandAction)
        modelCopyNode.runAction(moveUpAction)
    }
    
    
    //MARK:-set up btn
    func setUpMoveToRightBtn(){
        moveToRightBtn.frame = CGRect(x: 210, y: 680, width: 100, height: 100)
        
        
        moveToRightBtn.setImage(UIImage(named: "右走移动.png"), for: .normal)
        moveToRightBtn.imageView?.contentMode = .scaleToFill
        moveToRightBtn.addTarget(self, action: #selector(moveToRight), for: UIControl.Event.touchDown)
        view.addSubview(moveToRightBtn)
    }
    @objc func moveToRight(){
        print(modelNode.position)
        if modelNode.position.x <= -0.2 {
            modelNode.removeAllActions()
            modelCopyNode.removeAllActions()
            //            addUpAction()
            addRightMoveAction()
        } else {
            addLeftMoveAction()
        }
    }
    
    func setUpMoveToLeftBtn(){
        moveToLeftBtn.frame = CGRect(x: 60, y: 680, width: 100, height: 100)
       
        moveToLeftBtn.setImage(UIImage(named: "左走移动.png"), for: .normal)
        moveToLeftBtn.imageView?.contentMode = .scaleToFill
        moveToLeftBtn.addTarget(self, action: #selector(moveToLeft), for: UIControl.Event.touchDown)
        view.addSubview(moveToLeftBtn)
    }
    @objc func moveToLeft(){
        //        addLeftMoveAction()
        //        addRightMoveAction()
        print(modelNode.position)
        
        if modelNode.position.x >= 0.95 {
            modelNode.removeAllActions()
            modelCopyNode.removeAllActions()
            //            addDownAction()
            addLeftMoveAction()
        } else {
            addRightMoveAction()
        }
        
        
    }
    
    func setUpSWKJumpBtn(){
        sWKJumpBtn.frame = CGRect(x: 920, y: 680, width: 100, height: 100)
        sWKJumpBtn.setImage(UIImage(named: "跳.png"), for: .normal)
        sWKJumpBtn.imageView?.contentMode = .scaleToFill
        sWKJumpBtn.addTarget(self, action: #selector(sWKJump), for: UIControl.Event.touchDown)
        view.addSubview(sWKJumpBtn)
    }
    @objc func sWKJump(){
        //        addSWKJumpAction()
        
        if modelNode.position.y >= 0.45 {
            modelNode.removeAllActions()
            modelCopyNode.removeAllActions()
            //            addLeftMoveAction()
            addDownAction()
        } else {
            addSWKJumpAction()
        }
        
        if modelNode.position.x <= -0.2 {
            modelNode.removeAllActions()
            modelCopyNode.removeAllActions()
            //            addUpAction()
            addRightMoveAction()
        } else {
            addLeftMoveAction()
        }
        
        if modelNode.position.x >= 0.95 {
            modelNode.removeAllActions()
            modelCopyNode.removeAllActions()
            //            addDownAction()
            addLeftMoveAction()
        } else {
            addRightMoveAction()
        }
        
      
    }
    
    func setUpSWKStickAttactBtn(){
        sWKStickAttactBtn.frame = CGRect(x: 1040, y: 680, width: 100, height: 100)
        sWKStickAttactBtn.setImage(UIImage(named: "打.png"), for: .normal)
        sWKStickAttactBtn.imageView?.contentMode = .scaleToFill
        sWKStickAttactBtn.addTarget(self, action: #selector(sWKStickAttact), for: UIControl.Event.touchDown)
        view.addSubview(sWKStickAttactBtn)
    }
    @objc func sWKStickAttact(){
        //        addSWKStickAction()
        
        if modelNode.position.y >= 0.45 {
            modelNode.removeAllActions()
            modelCopyNode.removeAllActions()
            //            addLeftMoveAction()
            addDownAction()
        } else {
            addSWKStickAction()
        }
        
        if modelNode.position.x <= -0.2 {
            modelNode.removeAllActions()
            modelCopyNode.removeAllActions()
            //            addUpAction()
            addRightMoveAction()
        } else {
            addLeftMoveAction()
        }
        
        if modelNode.position.x >= 0.95 {
            modelNode.removeAllActions()
            modelCopyNode.removeAllActions()
            //            addDownAction()
            addLeftMoveAction()
        } else {
            addRightMoveAction()
        }
        
      
    }
    
    func setDownSWKBtn(){
        sWKDownBtn.frame = CGRect(x: 920, y: 570, width: 100, height: 100)
        sWKDownBtn.setImage(UIImage(named: "撤回.png"), for: .normal)
        sWKDownBtn.imageView?.contentMode = .scaleToFill
        sWKDownBtn.addTarget(self, action: #selector(sWKDown), for: UIControl.Event.touchDown)
        view.addSubview(sWKDownBtn)
    }
    @objc func sWKDown(){
        //        addSWKJumpAction()
        
        if modelNode.position.y <= 0.1 {
            modelNode.removeAllActions()
            modelCopyNode.removeAllActions()
            //            addLeftMoveAction()
            addUpAction()
        } else {
            addDownAction()
        }
        
        if modelNode.position.x <= -0.2 {
            modelNode.removeAllActions()
            modelCopyNode.removeAllActions()
            //            addUpAction()
            addRightMoveAction()
        } else {
            addLeftMoveAction()
        }
        
        if modelNode.position.x >= 0.95 {
            modelNode.removeAllActions()
            modelCopyNode.removeAllActions()
            //            addDownAction()
            addLeftMoveAction()
        } else {
            addRightMoveAction()
        }
       
    }
    
    func setUpDemonFallDownBtn(){
        demonFallDownBtn.frame = CGRect(x: 1040, y: 570, width: 100, height: 100)
        
        demonFallDownBtn.setImage(UIImage(named: "转换.png"), for: .normal)
        demonFallDownBtn.imageView?.contentMode = .scaleToFill
        demonFallDownBtn.addTarget(self, action: #selector(demonFallDown), for: UIControl.Event.touchDown)
        view.addSubview(demonFallDownBtn)
    }
    @objc func demonFallDown(){
        let node1 = stageNode.childNode(withName: "SketchUp", recursively: false)
        let node2 = stageNode.childNode(withName: "oldMan", recursively: false)
        let node3 = stageNode.childNode(withName: "oldWoman", recursively: false)
        
        let nodeCopy1 = stageNode.childNode(withName: "SketchUpCopy", recursively: false)
        let nodeCopy2 = stageNode.childNode(withName: "oldManCopy", recursively: false)
        let nodeCopy3 = stageNode.childNode(withName: "oldWomanCopy", recursively: false)
        
        
        if node2?.opacity == 0 && node3?.opacity == 0 && node1?.opacity == 1{
            node1?.runAction(demonAction)
            node2?.runAction(demonAppearAction)
            nodeCopy1?.runAction(demonAction)
            nodeCopy2?.runAction(demonAppearAction)
        } else if node1?.opacity == 0 && node3?.opacity == 0 && node2?.opacity == 1{
            node2?.runAction(demonAction)
            node3?.runAction(demonAppearAction)
            nodeCopy2?.runAction(demonAction)
            nodeCopy3?.runAction(demonAppearAction)
        } else if node1?.opacity == 0 && node2?.opacity == 0 && node3?.opacity == 1{
            node3?.runAction(demonAction)
            node1?.runAction(demonAppearAction)
            nodeCopy3?.runAction(demonAction)
            nodeCopy1?.runAction(demonAppearAction)
        }
    }
    
    
    //MARK:-add background music
    
   
    
    
    //MARK:-set up lead label
    
    
    @objc func processTimer(){
        textViewOne.isHidden = true
        textViewTwo.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(processTimer2), userInfo: nil, repeats: true)
    }
    
    @objc func processTimer2(){
        textViewTwo.isHidden = true
        textViewThree.isHidden = false
        self.setUpMoveToRightBtn()
        self.setUpMoveToLeftBtn()
        self.setUpSWKJumpBtn()
        self.setUpSWKStickAttactBtn()
        self.setDownSWKBtn()
        self.setUpDemonFallDownBtn()
        timer3 = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(processTimer3), userInfo: nil, repeats: true)
    }

    @objc func processTimer3(){
        textViewThree.isHidden = true
        textViewFour.isHidden = false
        timer4 = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(processTimer4), userInfo: nil, repeats: true)
    }
    
    @objc func processTimer4(){
       
        textViewFour.isHidden = true
//        textViewFour.removeFromSuperview()
    }
    
    
    
}
