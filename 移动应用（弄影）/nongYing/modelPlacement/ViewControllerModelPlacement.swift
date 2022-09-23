import UIKit
import SceneKit
import ARKit

class ViewControllerModelPlacement: UIViewController, DialogViewControllerTwoDelegate{
    
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var sessionStateLabel: UILabel!
    
    @IBOutlet weak var crosshair: UIView!
    
    @IBOutlet weak var textViewOnly: UIView!
    
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBAction func resetButton(_ sender: UIButton) {
        reset()
    }
    var timer = Timer()
    var timer2 = Timer()
    
    var focusSquare: FocusSquare?
    var screenCenter: CGPoint!
    var nodeBeganScale: Float!
    var lastPanPosition: SCNVector3?
    var panStartZ: CGFloat?
    
    var modelsInTheScene: Array<SCNNode> = []
    
    var portalNode: SCNNode? = nil
    var isPortalPlaced = false
    var debugPlanes: [SCNNode] = []
    var viewCenter: CGPoint {
        let viewBounds = view.bounds
        return CGPoint(x: viewBounds.width / 2.0, y: viewBounds.height / 2.0)
    }
    
    let POSITION_Y: CGFloat = -0.25
    let POSITION_Z: CGFloat = -SURFACE_LENGTH*0.5
    
    let DOOR_WIDTH:CGFloat = 1.0
    let DOOR_HEIGHT:CGFloat = 2.4
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGestureRecognizer()
        
        timer2 = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(processTimer), userInfo: nil, repeats: true)
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
        screenCenter = view.center
        
        resetLabels()
        runSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let viewCenter = CGPoint(x: size.width / 2, y: size.height / 2)
        screenCenter = viewCenter
    }
    
    func updateFocusSquare() {
        guard let focusSquareLocal = focusSquare else {return}
        
        guard let pointOfView = sceneView.pointOfView else {return}
        
        let firstVisibleModel = modelsInTheScene.first { (node) -> Bool in
            return sceneView.isNode(node, insideFrustumOf: pointOfView)
        }
        let modelsAreVisible = firstVisibleModel != nil
        if modelsAreVisible != focusSquareLocal.isHidden {
            focusSquareLocal.setHidden(to: modelsAreVisible)
        }
        
        let hitTest = sceneView.hitTest(screenCenter, types: .existingPlaneUsingExtent)
        if let hitTestResult = hitTest.first {
            //            print("Focus square hits a plane")
            
            let canAddNewModel = hitTestResult.anchor is ARPlaneAnchor
            focusSquareLocal.isClosed = canAddNewModel
        } else {
            //            print("Focus square does not hit a plane")
            
            focusSquareLocal.isClosed = false
        }
    }
    
    
    //MARK:-手势
    func addGestureRecognizer() {
        //添加滑动手势(用于移动和旋转模型)
        let Pan1GestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panFunc))
        sceneView.addGestureRecognizer(Pan1GestureRecognizer)
        
        //创建缩放手势(用于缩放模型)
        let PinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchFunc))
        sceneView.addGestureRecognizer(PinchGestureRecognizer)
    }
    
    
    
    @objc func panFunc(recognizer: UIPanGestureRecognizer) {
        
        //1.获取节点在空间中位置
        guard let node = self.sceneView.scene.rootNode.childNode(withName: "model", recursively: true) else {
            return
        }
        let nodePosition = node.position
        
        
        //2.获取相机当前在空间中位置
        guard let cameraTransform = self.sceneView.session.currentFrame?.camera.transform else {
            return
        }
        
        let translation = cameraTransform.columns.3
        
        //3.获取本次滑动的距离
        let point = recognizer.translation(in: self.view)
        let pointX = Float(point.x / self.view.bounds.size.width) * 0.35
        let pointY = Float(point.y / self.view.bounds.size.height) * 0.35
        
        //4.设置新的位置 x(point.x+nodePosition.x)、y(-point.y+nodePosition.y)、z(point.y+nodePosition.z)
        let newNodePositionX = pointX + nodePosition.x;
        let newNodePositionY = -pointY + nodePosition.y;
        let newNodePositionZ = (translation.z-0.1 < pointY+nodePosition.z) ? (translation.z-0.1) : (pointY + nodePosition.z);//模型z坐标保持在距离摄像头0.1
        node.position = SCNVector3(newNodePositionX, newNodePositionY, newNodePositionZ)
        
        
        //旋转
        //        let angles = Float((node.eulerAngles.x > 6) ? (Float.pi / 32) : (node.eulerAngles.x + Float.pi / 32))
        //        node.eulerAngles = SCNVector3(angles, angles, 0)
        
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    
    
    @objc func pinchFunc(recognizer: UIPinchGestureRecognizer) {
        
        //1.获取节点在空间中位置
        guard let node = self.sceneView.scene.rootNode.childNode(withName: "model", recursively: true) else {
            return
        }
        
        if (recognizer.state == UIGestureRecognizer.State.ended) {
            recognizer.scale = 1
        } else {
            
            //2.手势开始时保存node的scale
            if recognizer.state == UIGestureRecognizer.State.began {
                self.nodeBeganScale = node.scale.x
            }
            
            let nodeScale = Float(recognizer.view!.transform.scaledBy(x: recognizer.scale, y: recognizer.scale).a) * self.nodeBeganScale
            node.scale = SCNVector3(nodeScale, nodeScale, nodeScale)
        }
    }
    
    
    func reset() {
        sceneView.scene.rootNode.enumerateChildNodes { (existingNodes, _) in
            existingNodes.removeFromParentNode() //移除所有节点
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeToDialog" {
            let toVC = segue.destination as! DialogViewControllerTwo
            toVC.delegate = self
        }
    }
    
    //MARK:-添加组件模型
    func screenImageButtonTapped(name: String) {
        guard focusSquare != nil else {return}
        
        let modelName = name
        guard let model = getModel(named: modelName) else {
            print("Unable to load \(modelName) from file")
            return
        }
        
        let hitTest = sceneView.hitTest(screenCenter, types: .existingPlaneUsingExtent)
        guard let worldTransformColumn3 = hitTest.first?.worldTransform.columns.3 else {return}
        model.position = SCNVector3(worldTransformColumn3.x, worldTransformColumn3.y, worldTransformColumn3.z)
        model.name = "model"
        sceneView.scene.rootNode.addChildNode(model)
        
        print("\(modelName) added successfully")
        
        modelsInTheScene.append(model)
        print("Currently have \(modelsInTheScene.count) model(s) in the scene")
        var count = modelsInTheScene.count
        print(count)
        
        let node = modelsInTheScene[count - 1]
        node.name = "model"
        print(node.name)
    }
    
    
    //MARK:-portal model
    
    func runSession() {
        let configuration = ARWorldTrackingConfiguration.init()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        
        sceneView?.session.run(configuration,
                               options: [.resetTracking, .removeExistingAnchors])
        
#if DEBUG
        sceneView?.debugOptions = [SCNDebugOptions.showFeaturePoints]
#endif
        
        sceneView?.delegate = self
    }
    
    func resetLabels() {
        messageLabel?.alpha = 1.0
        messageLabel?.text = "移动手机，让app检测到平面，你会看到一个黄色的水平面。"
        sessionStateLabel?.alpha = 0.0
        sessionStateLabel?.text = ""
    }
    
    func showMessage(_ message: String, label: UILabel, seconds: Double) {
        label.text = message
        label.alpha = 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            if label.text == message {
                label.text = ""
                label.alpha = 0
            }
        }
    }
    
    func removeAllNodes() {
        removeDebugPlanes()
        self.portalNode?.removeFromParentNode()
        self.isPortalPlaced = false
    }
    
    func removeDebugPlanes() {
        for debugPlaneNode in self.debugPlanes {
            debugPlaneNode.removeFromParentNode()
        }
        self.debugPlanes = []
    }
    
    //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //      if let hit = sceneView?.hitTest(viewCenter, types: [.existingPlaneUsingExtent]).first {
    //        sceneView?.session.add(anchor: ARAnchor.init(transform: hit.worldTransform))
    //        print("hhhh")
    //      }
    //    }
    
    func makePortal() -> SCNNode {
        let portal = SCNNode()
        
        let floorNode = makeFloorNode()
        floorNode.position = SCNVector3(0, POSITION_Y, POSITION_Z)
        portal.addChildNode(floorNode)
        
        let ceilingNode = makeCeilingNode()
        ceilingNode.position = SCNVector3(0,
                                          POSITION_Y+WALL_HEIGHT,
                                          POSITION_Z)
        portal.addChildNode(ceilingNode)
        
        let farWallNode = makeWallNode()
        farWallNode.eulerAngles = SCNVector3(0, 90.0.degreesToRadians, 0)
        farWallNode.position = SCNVector3(0,
                                          POSITION_Y+WALL_HEIGHT*0.5,
                                          POSITION_Z-SURFACE_LENGTH*0.5)
        portal.addChildNode(farWallNode)
        
        let rightSideWallNode = makeWallNode(maskLowerSide: true)
        rightSideWallNode.eulerAngles = SCNVector3(0, 180.0.degreesToRadians, 0)
        rightSideWallNode.position = SCNVector3(WALL_LENGTH*0.5,
                                                POSITION_Y+WALL_HEIGHT*0.5,
                                                POSITION_Z)
        portal.addChildNode(rightSideWallNode)
        
        let leftSideWallNode = makeWallNode(maskLowerSide: true)
        leftSideWallNode.position = SCNVector3(-WALL_LENGTH*0.5,
                                                POSITION_Y+WALL_HEIGHT*0.5,
                                                POSITION_Z)
        portal.addChildNode(leftSideWallNode)
        
        addDoorway(node: portal)
        placeLightSource(rootNode: portal)
        return portal
    }
    
    func addDoorway(node: SCNNode) {
        let halfWallLength: CGFloat = WALL_LENGTH * 0.5
        let frontHalfWallLength: CGFloat = (WALL_LENGTH - DOOR_WIDTH) * 0.5
        
        
        let rightDoorSideNode = makeWallNode(length: frontHalfWallLength)
        rightDoorSideNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
        rightDoorSideNode.position = SCNVector3(halfWallLength - 0.5 * DOOR_WIDTH,
                                                POSITION_Y+WALL_HEIGHT*0.5,
                                                POSITION_Z+SURFACE_LENGTH*0.5)
        node.addChildNode(rightDoorSideNode)
        
        let leftDoorSideNode = makeWallNode(length: frontHalfWallLength)
        leftDoorSideNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
        leftDoorSideNode.position = SCNVector3(-halfWallLength + 0.5 * frontHalfWallLength,
                                                POSITION_Y+WALL_HEIGHT*0.5,
                                                POSITION_Z+SURFACE_LENGTH*0.5)
        node.addChildNode(leftDoorSideNode)
        
        let aboveDoorNode = makeWallNode(length: DOOR_WIDTH, height: WALL_HEIGHT - DOOR_HEIGHT)
        aboveDoorNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
        aboveDoorNode.position = SCNVector3(0,
                                            POSITION_Y+(WALL_HEIGHT-DOOR_HEIGHT)*0.5+DOOR_HEIGHT,
                                            POSITION_Z+SURFACE_LENGTH*0.5)
        node.addChildNode(aboveDoorNode)
    }
    
    func placeLightSource(rootNode: SCNNode) {
        let light = SCNLight()
        light.intensity = 10
        light.type = .omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(0,
                                        POSITION_Y+WALL_HEIGHT,
                                        POSITION_Z)
        rootNode.addChildNode(lightNode)
    }
    
}


extension ViewControllerModelPlacement: ARSCNViewDelegate {
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard let label = self.sessionStateLabel else { return }
        showMessage(error.localizedDescription, label: label, seconds: 3)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        guard let label = self.sessionStateLabel else { return }
        showMessage("Session interrupted", label: label, seconds: 3)
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        guard let label = self.sessionStateLabel else { return }
        showMessage("Session resumed", label: label, seconds: 3)
        
        DispatchQueue.main.async {
            self.removeAllNodes()
            self.resetLabels()
        }
        runSession()
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            guard anchor is ARPlaneAnchor else {return}
            print("Horizontal surface detected")
            
            //        let planeAnchor = anchor as! ARPlaneAnchor
            //        let planeNode = createPlane(planeAnchor: planeAnchor)
            //        node.addChildNode(planeNode)
            
            guard focusSquare == nil else {return}
            let focusSquareLocal = FocusSquare()
            sceneView.scene.rootNode.addChildNode(focusSquareLocal)
            focusSquare = focusSquareLocal
            
            
            DispatchQueue.main.async {
                if let planeAnchor = anchor as? ARPlaneAnchor, !self.isPortalPlaced {
                    print("xixixi")
#if DEBUG
                    let debugPlaneNode = createPlaneNode(
                        center: planeAnchor.center,
                        extent: planeAnchor.extent)
                    node.addChildNode(debugPlaneNode)
                    self.debugPlanes.append(debugPlaneNode)
#endif
                    self.messageLabel?.alpha = 1.0
                    self.messageLabel?.text = "点击屏幕，放置传送门入口"
                    
                    self.portalNode = self.makePortal()
                    print("xixi")
                    if let portal = self.portalNode {
                        node.addChildNode(portal)
                        print("heihie")
                        self.isPortalPlaced = true
                        
                        self.removeDebugPlanes()
                        self.sceneView?.debugOptions = []
                        
                        DispatchQueue.main.async {
                            self.messageLabel?.text = ""
                            self.messageLabel?.alpha = 0
                        }
                    }
                }
            }
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard anchor is ARPlaneAnchor else {return}
            DispatchQueue.main.async {
                if let planeAnchor = anchor as? ARPlaneAnchor,
                   node.childNodes.count > 0,
                   !self.isPortalPlaced {
                    updatePlaneNode(node.childNodes[0],
                                    center: planeAnchor.center,
                                    extent: planeAnchor.extent)
                }
            }
            
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
            guard anchor is ARPlaneAnchor else {return}
            print("Horizontal surface removed")
        }
        
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            guard let focusSquareLocal = focusSquare else {return}
            
            let hitTest = sceneView.hitTest(screenCenter, types: .existingPlane)
            let hitTestResult = hitTest.first
            guard let worldTransform = hitTestResult?.worldTransform else {return}
            let worldTransformColumn3 = worldTransform.columns.3
            focusSquareLocal.position = SCNVector3(worldTransformColumn3.x, worldTransformColumn3.y, worldTransformColumn3.z)
            
            DispatchQueue.main.async {
                self.updateFocusSquare()
                if let _ = self.sceneView?.hitTest(self.viewCenter,
                                                   types: [.existingPlaneUsingExtent]).first {
//                    self.crosshair.backgroundColor = UIColor.green
                } else {
//                    self.crosshair.backgroundColor = UIColor.lightGray
                }
            }
            
        }
        
        func createPlane(planeAnchor: ARPlaneAnchor) -> SCNNode {
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            plane.firstMaterial?.diffuse.contents = UIImage(named: "grid")
            plane.firstMaterial?.isDoubleSided = true
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
            //        planeNode.eulerAngles.x = -.pi / 2
            planeNode.eulerAngles.x = GLKMathDegreesToRadians(-90)
            
            return planeNode
        }
    }
    
    //MARK:-ViewController+ARSCNViewDelegate移植
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}
        print("Horizontal surface detected")
        
        guard focusSquare == nil else {return}
        let focusSquareLocal = FocusSquare()
        sceneView.scene.rootNode.addChildNode(focusSquareLocal)
        focusSquare = focusSquareLocal
        
        
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor, !self.isPortalPlaced {
                print("xixixi")
#if DEBUG
                let debugPlaneNode = createPlaneNode(
                    center: planeAnchor.center,
                    extent: planeAnchor.extent)
                node.addChildNode(debugPlaneNode)
                self.debugPlanes.append(debugPlaneNode)
#endif
                self.messageLabel?.alpha = 1.0
                self.messageLabel?.text = "点击屏幕，放置传送门入口"
                
                self.portalNode = self.makePortal()
                print("xixi")
                if let portal = self.portalNode {
                    node.addChildNode(portal)
                    print("heihie")
                    self.isPortalPlaced = true
                    
                    self.removeDebugPlanes()
                    self.sceneView?.debugOptions = []
                    
                    DispatchQueue.main.async {
                        self.messageLabel?.text = ""
                        self.messageLabel?.alpha = 0
                    }
                }
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor,
               node.childNodes.count > 0,
               !self.isPortalPlaced {
                updatePlaneNode(node.childNodes[0],
                                center: planeAnchor.center,
                                extent: planeAnchor.extent)
            }
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}
        print("Horizontal surface removed")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let focusSquareLocal = focusSquare else {return}
        
        let hitTest = sceneView.hitTest(screenCenter, types: .existingPlane)
        let hitTestResult = hitTest.first
        guard let worldTransform = hitTestResult?.worldTransform else {return}
        let worldTransformColumn3 = worldTransform.columns.3
        focusSquareLocal.position = SCNVector3(worldTransformColumn3.x, worldTransformColumn3.y, worldTransformColumn3.z)
        
        DispatchQueue.main.async {
            self.updateFocusSquare()
            if let _ = self.sceneView?.hitTest(self.viewCenter,
                                               types: [.existingPlaneUsingExtent]).first {
//                self.crosshair.backgroundColor = UIColor.green
            } else {
//                self.crosshair.backgroundColor = UIColor.lightGray
            }
        }
        
    }
    
    func createPlane(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        plane.firstMaterial?.diffuse.contents = UIImage(named: "grid")
        plane.firstMaterial?.isDoubleSided = true
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
        planeNode.eulerAngles.x = GLKMathDegreesToRadians(-90)
        
        return planeNode
    }

    @objc func processTimer(){
        textViewOnly.isHidden = true
    }
}






