

import SceneKit

class FocusSquare: SCNNode {
    
    var isClosed: Bool = true {
        didSet {
            geometry?.firstMaterial?.diffuse.contents = self.isClosed ? UIImage(named: "FocusSquare/close") : UIImage(named: "FocusSquare/open")
        }
    }
    
    override init() {
        super.init()
        
        let plane = SCNPlane(width: 0.1, height: 0.1)
        plane.firstMaterial?.diffuse.contents = UIImage(named: "FocusSquare/close")
        plane.firstMaterial?.isDoubleSided = true
        
        geometry = plane
        eulerAngles.x = GLKMathDegreesToRadians(-90)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setHidden(to hidden: Bool) {
        var fadeTo: SCNAction
        
        if hidden {
            fadeTo = .fadeOut(duration: 0.5)
        } else {
            fadeTo = .fadeIn(duration: 0.5)
        }
        
        let actions = [fadeTo, .run({ (focusSquare: SCNNode) in
            focusSquare.isHidden = hidden
        })]
        runAction(.sequence(actions))
    }
}
