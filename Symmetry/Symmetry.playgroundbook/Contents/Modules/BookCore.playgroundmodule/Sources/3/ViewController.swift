

import UIKit
import SceneKit
import ARKit

@objc(ViewController)
public class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    @IBAction func resetButton(_ sender: UIButton) {
        reset()
    }
    
    var focusSquare: FocusSquare?
    var screenCenter: CGPoint!
    var nodeBeganScale: Float!
    var lastPanPosition: SCNVector3?
     var panStartZ: CGFloat?
    
    var modelsInTheScene: Array<SCNNode> = []
    
    
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
//        addRecognizerToSceneView()
        addGestureRecognizer()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
//        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
        screenCenter = view.center
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/iPhoneX/iPhoneX.scn")!
        
        // Set the scene to the view
//        sceneView.scene = scene
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
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
    
    public func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    public   
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    public   
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
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
        let pointX = Float(point.x / self.view.bounds.size.width) * 0.1
        let pointY = Float(point.y / self.view.bounds.size.height) * 0.1

        //4.设置新的位置 x(point.x+nodePosition.x)、y(-point.y+nodePosition.y)、z(point.y+nodePosition.z)
        let newNodePositionX = pointX + nodePosition.x;
        let newNodePositionY = -pointY + nodePosition.y;
        let newNodePositionZ = (translation.z-0.1 < pointY+nodePosition.z) ? (translation.z-0.1) : (pointY + nodePosition.z);//模型z坐标保持在距离摄像头0.1
        node.position = SCNVector3(newNodePositionX, newNodePositionY, newNodePositionZ)


        //旋转
        let angles = Float((node.eulerAngles.x > 6) ? (Float.pi / 32) : (node.eulerAngles.x + Float.pi / 32))
        node.eulerAngles = SCNVector3(angles, angles, 0)

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
}

