//
//  ViewController.swift
//  nongYing
//
//  Created by Blacour on 2020/10/23.
//

import UIKit
import AVFoundation
var audioPlayer:AVAudioPlayer = AVAudioPlayer()
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        playBackgroundMusic(filename: "background1.mp3")
        playRecording(name: "猪八戒")
        title = ""
       
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
//        playBackgroundMusic(filename: "background1.mp3")
    }
    
    
    
    //MARK:- LC:
    
     func playRecording(name:String) {
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
    
    var backgroundMusicPlayer: AVAudioPlayer!
    func playBackgroundMusic(filename: String) {
        let url = Bundle.main.url(forResource: filename, withExtension: nil)
        if (url == nil) {
            print("Could not find file: background.mp3")
            return
        }
        backgroundMusicPlayer = try! AVAudioPlayer(contentsOf: url!)
        if backgroundMusicPlayer == nil {
            print("no nusic")
            return
        }
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.prepareToPlay()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
