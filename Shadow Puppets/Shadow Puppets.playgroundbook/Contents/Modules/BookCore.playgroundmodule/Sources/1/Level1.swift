
import Foundation
import SpriteKit

@objc(Level1)
public class Level1: GameScene {
    
    public override func didMove(to view: SKView) {
        super.didMove(to: view)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }
    
    public override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        if score >= 3 {
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false){(timer) in
                let nextLevel = GameScene(fileNamed: "ShowTheKnowledge\(self.playerNumber)")
                nextLevel?.scaleMode = .aspectFill
                self.view?.presentScene(nextLevel)
            }
        }
    }
    
}
