//
//  Two.swift
//  testsecond
//
//  Created by Blacour on 2020/7/30.
//
import UIKit
import AVKit
import AVFoundation

class washViewController: UIViewController {
    
    
    var timer :Timer!
    
    var timeCount :Int=0
    
    
    var isOpen = 0
    var player:AVPlayer!
    
    var hintView = UIView()
    var hintImage = UIImageView()
    var removeButton = UIButton()
    var playButton = UIButton()
   
    
    @IBOutlet weak var popingUpWindowsView: UIView!
    
    @IBAction func LongPress(_ sender: Any) {
        if isOpen == 0{
            //开始播放
            player.play()
            print("1")
        }
        timer=Timer.scheduledTimer(timeInterval:2, target:self, selector:#selector(self.tickDown), userInfo:nil, repeats:false)
    }
    

        override func viewDidLoad() {
        
        popingUpWindowsView.alpha = 0
        
        removeButton.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        removeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        removeButton.addTarget(self,action:#selector(removeView),for:.touchUpInside)
        hintImage.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        hintImage.image = UIImage(named: "刮皮-1")
        hintView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        hintView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        view.addSubview(hintView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        
        
        //定义一个视频文件路径
        let filePath = Bundle.main.path(forResource: "guadao", ofType: "MOV")
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
        hintView.addSubview(hintImage)
        hintView.addSubview(removeButton)
    }
    
    
    
    @objc func tickDown(){
        print("0timeCount\(timeCount)")
        timeCount+=1
        player.pause()
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
        UIView.animate(withDuration: 1.0) {
            self.hintImage.alpha = 0
        }
        removeButton.removeFromSuperview()
        print("hh")
    }
    
    @objc func playVideo() {
        if isOpen == 0{
            //开始播放
            player.play()
            print("1")
        }
        timer=Timer.scheduledTimer(timeInterval:1, target:self, selector:#selector(self.tickDown), userInfo:nil, repeats:false)
    }
    
    
}

