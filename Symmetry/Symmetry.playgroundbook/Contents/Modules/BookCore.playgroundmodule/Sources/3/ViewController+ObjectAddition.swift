
//

import UIKit
import SceneKit
import ARKit

extension ViewController {
    
    func getModel(named name: String) -> SCNNode? {
        let scene = SCNScene(named: "art.scnassets/\(name)/\(name).scn")
        guard let model = scene?.rootNode.childNode(withName: "SketchUp", recursively: false) else {return nil}
        model.name = name
        
        var scale: CGFloat
        
        switch name {
        case "iPhoneX":         scale = 0.25
        default:                scale = 1
        }
        
        model.scale = SCNVector3(scale, scale, scale)
        return model
    }
    
    @IBAction func addObjectButtonTapped(_ sender: Any) {
        print("Add button tapped")
        
        guard focusSquare != nil else {return}
        
        let modelName = "iPhoneX"
        guard let model = getModel(named: modelName) else {
            print("Unable to load \(modelName) from file")
            return
        }
        //        model.name = "model"
        
        let hitTest = sceneView.hitTest(screenCenter, types: .existingPlaneUsingExtent)
        guard let worldTransformColumn3 = hitTest.first?.worldTransform.columns.3 else {return}
        model.position = SCNVector3(worldTransformColumn3.x, worldTransformColumn3.y, worldTransformColumn3.z)
        model.name = "model"
        sceneView.scene.rootNode.addChildNode(model)
        
        print("\(modelName) added successfully")
        
        modelsInTheScene.append(model)
        print("Currently have \(modelsInTheScene.count) model(s) in the scene")
        let count = modelsInTheScene.count
        print(count)
        
        let node = modelsInTheScene[count - 1]
        node.name = "model"
        //print(node.name)
        
        //        var model0 = modelsInTheScene[count - 1]
        //        model0.name = String(count)
    }
    
    @IBAction func change(_ sender: UIButton) {
        let count = modelsInTheScene.count
        if count > 1 {
            let node = modelsInTheScene[count - 1]
            node.name = "model"
            let node0 = modelsInTheScene[count - 2]
            node0.name = "model0"
        }else{
            print("There is no next model")
        }
    }
    
//    @IBAction func change0(_ sender: UIButton) {
//        
//        var count = modelsInTheScene.count
//        if count >= 2 {
//            let node = modelsInTheScene[count - 1]
//            node.name = "model0"
//            let node1 = modelsInTheScene[count - 2]
//            node1.name = "model"
//        }else{
//            print("There is no previous model")
//        }
//        
//    }
    
}

