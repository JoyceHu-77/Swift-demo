
import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

@objc(GameViewController)
public class GameViewController: UIViewController {
    
  // AVAudioPlayer
  var gameMusic: AVAudioPlayer?
  
    var playerNumber: Int = 1

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "Level\(playerNumber)") {
                // Set the scale mode to scale to fit the window
                let gscene = scene as! GameScene
                gscene.playerNumber = playerNumber
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = false
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        let soundName = "bgMusic.wav"
        Audio.sharedInstance.playSound(soundFileName: soundName)
        Audio.sharedInstance.player(with: soundName)?.numberOfLoops = -1
        
        
    }

    public override var shouldAutorotate: Bool {
        return true
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    public override var prefersStatusBarHidden: Bool {
        return true
    }
}
