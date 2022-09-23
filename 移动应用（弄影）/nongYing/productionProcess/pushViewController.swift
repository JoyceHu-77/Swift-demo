//
//  SecondViewController.swift
//  testsecond
//
//  Created by Blacour on 2020/7/30.
//

import UIKit
import AVKit
import AVFoundation

class pushViewController: UIViewController {
    
    var isOpen = 0
    
    var player:AVPlayer!
    
    var hintView = UIView()
    var hintImage = UIImageView()
    var removeButton = UIButton()
    var playButton = UIButton()
    
    @IBOutlet weak var popingUpWindowsView: UIView!
    
    
    @IBOutlet weak var nextView: UIButton!
    
    override func viewDidLoad() {
        popingUpWindowsView.alpha = 0
        playBackgroundMusic(filename: "音乐水泡.mp3")
        removeButton.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        removeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        removeButton.addTarget(self,action:#selector(removeView),for:.touchUpInside)
        playButton.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        playButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        playButton.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        hintImage.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        hintImage.image = UIImage(named: "净皮-1")
        hintView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        hintView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        view.addSubview(hintView)
        //定义一个视频文件路径
        let filePath = Bundle.main.path(forResource: "chongxi", ofType: "MOV")
        let videoURL = URL(fileURLWithPath: filePath!)
        //定义一个playerItem，并监听相关的通知
        let playerItem = AVPlayerItem(url: videoURL)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: playerItem)
        //定义一个视频播放器，通过playerItem径初始化
        player = AVPlayer(playerItem: playerItem)
        //设置大小和位置（全屏）
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        //添加到界面上
        self.hintView.layer.addSublayer(playerLayer)
        hintView.addSubview(playButton)
        hintView.addSubview(hintImage)
        hintView.addSubview(removeButton)
    }
    
    
    //视频播放完毕响应
    @objc func playerDidFinishPlaying() {
        print("播放完毕!")
        popingUpWindowsView.transform = CGAffineTransform(scaleX: 0.3, y: 2.0)
        UIView.animate(withDuration: 1, delay: 0.8, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [UIView.AnimationOptions.curveEaseOut,.allowUserInteraction], animations: {
            self.hintView.removeFromSuperview()
            self.popingUpWindowsView.alpha = 1
            self.popingUpWindowsView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    
    
    func handlePinchGesture(sender: UIPinchGestureRecognizer){
        
        //状态是否结束，如果结束保存数据
        if sender.state == UIGestureRecognizer.State.ended{
            player.play()
        }
    }
    
    
    
    @objc func removeView() {
        UIView.animate(withDuration: 1.5) {
            self.hintImage.alpha = 0
            
        }
        removeButton.removeFromSuperview()
        
        print("hh")
    }
    
    func zhuanhuan()  {
        if nextView.isSelected {
            backgroundMusicPlayer.stop()
            
            
        } else {
            
            backgroundMusicPlayer.play()
            
        }
        nextView.isSelected.toggle()
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
//        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.prepareToPlay()
        
    }
    
    
    @objc func playVideo() {
        if isOpen == 0{
            //开始播放
            player.play()
            isOpen = 1
            zhuanhuan()
            print("1")
        }
    }
    
}

