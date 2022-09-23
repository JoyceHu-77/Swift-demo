/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Main view controller for the AR experience.
 */

import UIKit
//import RealityKit
import SceneKit
import ARKit
import MultipeerConnectivity

class ViewController: UIViewController, ARSessionDelegate, ARSCNViewDelegate {
    
    //    @IBOutlet var arView: ARView!
    @IBOutlet weak var messageLabel: MessageLabel!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    
    var modelNode: SCNNode!
    var modelCopyNode: SCNNode!
    var stageNode: SCNNode!
    var addSWKBtn = UIButton()
    var addBGJBtn = UIButton()
    var addStageBtn = UIButton()
    var scenePoint: CGPoint!
    
    var swkAnchorArray = [ARAnchor]()
    var bgjAnchorArray = [ARAnchor]()
    
//    var stageHitTest: ARHitTestResult!
    var stageWorldTransformColumn: simd_float4x4!
    
    var multipeerSession: MultipeerSession?
    let coachingOverlay = ARCoachingOverlayView()
    var peerSessionIDs = [MCPeerID: String]()
    var sessionIDObservation: NSKeyValueObservation?
    var configuration: ARWorldTrackingConfiguration?
    
    
    override func viewDidLoad() {
        setUpSWKAddBtn()
        setUpBGJAddBtn()

    }
    
    
    //MARK:-init
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        //        arView.session.delegate = self
        sceneView.session.delegate = self
        sceneView.delegate = self
        
        configuration = ARWorldTrackingConfiguration()
        
        // Enable a collaborative session.
        configuration?.isCollaborationEnabled = true
        
        // Enable realistic reflections.
        configuration?.environmentTexturing = .automatic
        
        sceneView.session.run(configuration!)
        
        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        let scene = SCNScene()
        scene.isPaused = false
        sceneView.scene = scene
        
        sessionIDObservation = observe(\.sceneView.session.identifier, options: [.new]) { object, change in
            print("SessionID changed to: \(change.newValue!)")
            guard let multipeerSession = self.multipeerSession else { return }
            self.sendARSessionIDTo(peers: multipeerSession.connectedPeers)
        }
        
        setupCoachingOverlay()
        
        // Start looking for other players via MultiPeerConnectivity.
        multipeerSession = MultipeerSession(receivedDataHandler: receivedData, peerJoinedHandler:
                                                peerJoined, peerLeftHandler: peerLeft, peerDiscoveredHandler: peerDiscovered)
        
        // Prevent the screen from being dimmed to avoid interrupting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true
        
        messageLabel.displayMessage("Tap the screen to place cubes.\nInvite others to launch this app to join you.", duration: 60.0)
    }
    
    
    
    //MARK:-MultipeerConnectivity
    /// - Tag: DidOutputCollaborationData
    func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
        guard let multipeerSession = multipeerSession else { return }
        if !multipeerSession.connectedPeers.isEmpty {
            guard let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
            else { fatalError("Unexpectedly failed to encode collaboration data.") }
            // Use reliable mode if the data is critical, and unreliable mode if the data is optional.
            let dataIsCritical = data.priority == .critical
            multipeerSession.sendToAllPeers(encodedData, reliably: dataIsCritical)
        } else {
//            print("Deferred sending collaboration to later because there are no peers.")
        }
    }
    
    func receivedData(_ data: Data, from peer: MCPeerID) {
        if let collaborationData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARSession.CollaborationData.self, from: data) {
            sceneView.session.update(with: collaborationData)
            return
        }
        // ...
        let sessionIDCommandString = "SessionID:"
        if let commandString = String(data: data, encoding: .utf8), commandString.starts(with: sessionIDCommandString) {
            let newSessionID = String(commandString[commandString.index(commandString.startIndex,
                                                                        offsetBy: sessionIDCommandString.count)...])
            // If this peer was using a different session ID before, remove all its associated anchors.
            // This will remove the old participant anchor and its geometry from the scene.
            if let oldSessionID = peerSessionIDs[peer] {
                removeAllAnchorsOriginatingFromARSessionWithID(oldSessionID)
            }
            
            peerSessionIDs[peer] = newSessionID
        }
    }
    
    func peerDiscovered(_ peer: MCPeerID) -> Bool {
        guard let multipeerSession = multipeerSession else { return false }
        
        if multipeerSession.connectedPeers.count > 3 {
            // Do not accept more than four users in the experience.
            messageLabel.displayMessage("A fifth peer wants to join the experience.\nThis app is limited to four users.", duration: 6.0)
            return false
        } else {
            return true
        }
    }
    /// - Tag: PeerJoined
    func peerJoined(_ peer: MCPeerID) {
        messageLabel.displayMessage("""
            A peer wants to join the experience.
            Hold the phones next to each other.
            """, duration: 6.0)
        // Provide your session ID to the new user so they can keep track of your anchors.
        sendARSessionIDTo(peers: [peer])
    }
    
    func peerLeft(_ peer: MCPeerID) {
        messageLabel.displayMessage("A peer has left the shared experience.")
        
        // Remove all ARAnchors associated with the peer that just left the experience.
        if let sessionID = peerSessionIDs[peer] {
            removeAllAnchorsOriginatingFromARSessionWithID(sessionID)
            peerSessionIDs.removeValue(forKey: peer)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        // Remove optional error messages.
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            // Present the error that occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                self.resetTracking()
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func resetTracking() {
        guard let configuration = sceneView.session.configuration else { print("A configuration is required"); return }
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override var prefersStatusBarHidden: Bool {
        // Request that iOS hide the status bar to improve immersiveness of the AR experience.
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        // Request that iOS hide the home indicator to improve immersiveness of the AR experience.
        return true
    }
    
    private func removeAllAnchorsOriginatingFromARSessionWithID(_ identifier: String) {
        guard let frame = sceneView.session.currentFrame else { return }
        for anchor in frame.anchors {
            guard let anchorSessionID = anchor.sessionIdentifier else { continue }
            if anchorSessionID.uuidString == identifier {
                sceneView.session.remove(anchor: anchor)
            }
        }
    }
    
    private func sendARSessionIDTo(peers: [MCPeerID]) {
        guard let multipeerSession = multipeerSession else { return }
        let idString = sceneView.session.identifier.uuidString
        let command = "SessionID:" + idString
        if let commandData = command.data(using: .utf8) {
            multipeerSession.sendToPeers(commandData, reliably: true, peers: peers)
        }
    }
    
    
    
    
    
    
    
    
    // MARK: - Load Models
    
    func loadSWKModel() -> SCNNode{
        let modelScene = SCNScene(
            named: "art.scnassets/SunWuKong.scn")!
        modelNode = modelScene.rootNode.childNode(withName: "SunWuKong", recursively: false)!
        return modelNode
    }
    
    func loadBGJModel() -> SCNNode{
        let modelScene = SCNScene(
            named: "art.scnassets/iPhoneX.scn")!
        modelCopyNode = modelScene.rootNode.childNode(withName: "SketchUp", recursively: false)!
        return modelCopyNode
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let name = anchor.name, name.hasPrefix("SunWuKong") {
            node.addChildNode(loadSWKModel())
        }
        if let name = anchor.name, name.hasPrefix("BaiGuJing") {
            node.addChildNode(loadBGJModel())
        }
        
        
    }
    
    //MARK:- set up add btn
    
    func setUpSWKAddBtn(){
//        addSWKBtn.frame = CGRect(x: 80, y: 1000, width: 150, height: 150)
        addSWKBtn.frame = CGRect(x: 50, y: 700, width: 100, height: 100)
        addSWKBtn.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        addSWKBtn.setTitle("孙悟空", for: UIControl.State.normal)
        addSWKBtn.setTitleColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), for: UIControl.State.normal)
        addSWKBtn.addTarget(self, action: #selector(addSWKButton), for: UIControl.Event.touchDown)
        view.addSubview(addSWKBtn)
    }
    @objc func addSWKButton(){
        addBGJBtn.isHidden = true
        scenePoint = view.center
        let hitTest = sceneView.hitTest(scenePoint, types: .estimatedVerticalPlane)
        guard let worldTransformColumn3 = hitTest.first?.worldTransform else {return print("add anchor failed")}
        let anchor = ARAnchor(name: "SunWuKong", transform: worldTransformColumn3)
        sceneView.session.add(anchor: anchor)
        swkAnchorArray.append(anchor)
        if self.swkAnchorArray.count != 1{
            DispatchQueue.main.asyncAfter(deadline: .now() ) {
                self.sceneView.session.remove(anchor: self.swkAnchorArray[self.swkAnchorArray.count - 2])
            }
        }
    }
    
    func setUpBGJAddBtn(){
//        addBGJBtn.frame = CGRect(x: 640, y: 1000, width: 150, height: 150)
        addBGJBtn.frame = CGRect(x: 200, y: 700, width: 100, height: 100)
        addBGJBtn.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        addBGJBtn.setTitle("白骨精", for: UIControl.State.normal)
        addBGJBtn.setTitleColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), for: UIControl.State.normal)
        addBGJBtn.addTarget(self, action: #selector(addBGJButton), for: UIControl.Event.touchDown)
        view.addSubview(addBGJBtn)
    }
    @objc func addBGJButton(){
        addSWKBtn.isHidden = true
        scenePoint = view.center
        let hitTest = sceneView.hitTest(scenePoint, types: .estimatedVerticalPlane)
        guard let worldTransformColumn3 = hitTest.first?.worldTransform else {return print("add anchor failed")}
        let anchor = ARAnchor(name: "BaiGuJing", transform: worldTransformColumn3)
        sceneView.session.add(anchor: anchor)
        bgjAnchorArray.append(anchor)
        if self.bgjAnchorArray.count != 1{
            DispatchQueue.main.asyncAfter(deadline: .now() ) {
                self.sceneView.session.remove(anchor: self.bgjAnchorArray[self.bgjAnchorArray.count - 2])
            }
        }
    }
    
    
    
    
    

    
}
