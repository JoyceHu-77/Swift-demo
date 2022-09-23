


import UIKit
import SceneKit
import ARKit

extension ViewControllerModelPlacement {
    
    func getModel(named name: String) -> SCNNode? {
        let scene = SCNScene(named: "art.scnassets/\(name)/\(name).scn")
        guard let model = scene?.rootNode.childNode(withName: "SketchUp", recursively: false) else {return nil}
        model.name = name
        
        var scale: CGFloat
        
        switch name {
        case "others":         scale = 0.25
        case "others1":        scale = 0.35
        case "others2":        scale = 0.35
        case "others3":        scale = 0.25
        case "others4":        scale = 0.35
        default:               scale = 1
        }
        
        model.scale = SCNVector3(scale, scale, scale)
        return model
    }
    
    @IBAction func addObjectButtonTapped(_ sender: Any) {
        print("Add button tapped")
        
        performSegue(withIdentifier: "HomeToDialog", sender: nil)
        
        
    }
    
    @IBAction func change(_ sender: UIButton) {
        var count = modelsInTheScene.count
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

