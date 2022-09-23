//
//  nushViewController.swift
//  nongYing
//
//  Created by Blacour on 2020/7/30.
//

import UIKit

class nushViewController: UIViewController {
    
    var anotherDrawBoard = AnotherDrawBoard()
    var myNumber = 1
    var hintView = UIView()
    var hintImage2 = UIImageView()
    var removeButton = UIButton()
   
    @IBOutlet weak var baigujing: UIImageView!
    
    @IBOutlet weak var popingUpWindowsView2: UIView!
    @IBOutlet weak var popingUpWindowsView1: UIView!
    @IBOutlet weak var drawView: UIView!
    
    @IBOutlet weak var popingViewOut: UIButton!
    @IBOutlet weak var dropOut: UIButton!
    
    @IBOutlet weak var trueViewBut: UIButton!
    @IBOutlet weak var wujibayu: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        removeButton.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        removeButton.addTarget(self,action:#selector(removeView),for:.touchUpInside)
        hintImage2.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        hintImage2.image = UIImage(named: "画皮-1")
        hintView.frame = CGRect(x: 0, y: 0,width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        hintView.addSubview(hintImage2)
        view.addSubview(hintView)
        hintView.addSubview(removeButton)

        // Do any additional setup after loading the view.
        self.anotherDrawBoard = AnotherDrawBoard(frame: CGRect(x:0, y:0, width:mScreenWidth, height:mScreenHeight))
        self.drawView.addSubview(anotherDrawBoard)
       
    

    }
    @IBAction func trueViewBut(_ sender: UIButton) {
        popingUpWindowsView2.transform = CGAffineTransform(scaleX: 0.3, y: 2.0)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [UIView.AnimationOptions.curveEaseOut,.allowUserInteraction], animations: {
            self.popingUpWindowsView2.alpha = 1
            self.popingUpWindowsView2.layer.cornerRadius = 30
            self.popingUpWindowsView2.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    
    
    @IBAction func wujibayu(_ sender: UIButton) {
        popingUpWindowsView1.transform = CGAffineTransform(scaleX: 0.3, y: 2.0)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [UIView.AnimationOptions.curveEaseOut,.allowUserInteraction], animations: {
            self.popingUpWindowsView1.alpha = 1
            self.popingUpWindowsView1.layer.cornerRadius = 30
            self.popingUpWindowsView1.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    @objc func removeView() {
        self.hintView.removeFromSuperview()
        self.hintImage2.alpha = 0
        removeButton.removeFromSuperview()
        
        
        
    }
    
    @IBAction func popingViewOut(_ sender: Any) {
        
        self.popingUpWindowsView2.alpha = 0
       
    }
    
    @IBAction func dropOut(_ sender: Any) {
        if myNumber % 2 == 0 {
            self.baigujing.alpha = 1
            myNumber = myNumber + 1
            
        }else {
            self.baigujing.alpha = 0
            myNumber = myNumber + 1
            
        }
        
       
    }
    
//    @objc func tapaction(){
//        self.present(ViewController(), animated: false, completion: nil)
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
