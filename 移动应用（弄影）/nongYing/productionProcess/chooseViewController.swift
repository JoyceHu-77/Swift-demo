//
//  chooseViewController.swift
//  nongYing
//
//  Created by Blacour on 2020/7/30.
//

import UIKit

class chooseViewController: UIViewController {
    
    var hintView = UIView()
    var hintImage = UIImageView()
    var removeButton = UIButton()
   
    
    
    @IBOutlet weak var popingUpWindowsView: UIView!
    
    @IBOutlet weak var popingUpWindowsView2: UIView!
    
    @IBOutlet weak var popingUpWindowsView3: UIView!
    
    @IBOutlet weak var popingUpWindowsView4: UIView!
    
    @IBOutlet weak var popingUpWindowsView5: UIView!
    
    @IBOutlet weak var popingUpWindowsView6: UIView!
    
    @IBOutlet weak var popingUpWindowsView7: UIView!
    
    
    
    @IBOutlet weak var outView: UIButton!
    
    @IBOutlet weak var DoukeyLeftBut: UIButton!
    
    @IBOutlet weak var bullRight: UIButton!
    
    @IBOutlet weak var Pig: UIButton!
    
    @IBOutlet weak var row: UIButton!
    
    @IBOutlet weak var pigLittle: UIButton!
    
    @IBOutlet weak var bullLeft: UIButton!
    
    
    @IBOutlet weak var trueViewBut: UIButton!
    
    
    
    
    @IBAction func tureBut(_ sender: UIButton) {
        popingUpWindowsView.alpha = 0
        popingUpWindowsView2.alpha = 0
        popingUpWindowsView3.alpha = 0
        popingUpWindowsView4.alpha = 0
        popingUpWindowsView5.alpha = 0
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        popingUpWindowsView.alpha = 0
        // Do any additional setup after loading the view.
        removeButton.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        removeButton.addTarget(self,action:#selector(removeView),for:.touchUpInside)
        hintImage.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        hintImage.image = UIImage(named: "选皮-1")
        hintView.frame = CGRect(x: 0, y: 0,width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        hintView.addSubview(hintImage)
        view.addSubview(hintView)
        hintView.addSubview(removeButton)
    }
    
    //MARK:-design popingUpWindow
    @IBAction func DoukeyLeftBut(_ sender: UIButton) {
        popingUpWindowsView.transform = CGAffineTransform(scaleX: 0.3, y: 2.0)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [UIView.AnimationOptions.curveEaseOut,.allowUserInteraction], animations: {
            self.popingUpWindowsView.alpha = 0.8
            self.popingUpWindowsView.layer.cornerRadius = 30
            self.popingUpWindowsView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    @IBAction func BullRight(_ sender: UIButton) {
        popingUpWindowsView2.transform = CGAffineTransform(scaleX: 0.3, y: 2.0)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [UIView.AnimationOptions.curveEaseOut,.allowUserInteraction], animations: {
            self.popingUpWindowsView2.alpha = 0.8
            self.popingUpWindowsView2.layer.cornerRadius = 30
            self.popingUpWindowsView2.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    @IBAction func Pig(_ sender: UIButton) {
        popingUpWindowsView3.transform = CGAffineTransform(scaleX: 0.3, y: 2.0)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [UIView.AnimationOptions.curveEaseOut,.allowUserInteraction], animations: {
            self.popingUpWindowsView3.alpha = 0.8
            self.popingUpWindowsView3.layer.cornerRadius = 30
            self.popingUpWindowsView3.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    @IBAction func Row(_ sender: UIButton) {
        popingUpWindowsView4.transform = CGAffineTransform(scaleX: 0.3, y: 2.0)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [UIView.AnimationOptions.curveEaseOut,.allowUserInteraction], animations: {
            self.popingUpWindowsView4.alpha = 0.8
            self.popingUpWindowsView4.layer.cornerRadius = 30
            self.popingUpWindowsView4.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    @IBAction func pigLittle(_ sender: UIButton) {
        popingUpWindowsView5.transform = CGAffineTransform(scaleX: 0.3, y: 2.0)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [UIView.AnimationOptions.curveEaseOut,.allowUserInteraction], animations: {
            self.popingUpWindowsView5.alpha = 0.8
            self.popingUpWindowsView5.layer.cornerRadius = 30
            self.popingUpWindowsView5.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    @IBAction func bullLeft(_ sender: UIButton) {
        popingUpWindowsView6.transform = CGAffineTransform(scaleX: 0.3, y: 2.0)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [UIView.AnimationOptions.curveEaseOut,.allowUserInteraction], animations: {
            self.popingUpWindowsView6.alpha = 0.8
            self.popingUpWindowsView6.layer.cornerRadius = 30
            self.popingUpWindowsView6.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @IBAction func trueViewBut(_ sender: UIButton) {
        popingUpWindowsView7.transform = CGAffineTransform(scaleX: 0.3, y: 2.0)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [UIView.AnimationOptions.curveEaseOut,.allowUserInteraction], animations: {
            self.popingUpWindowsView7.alpha = 0.9
           
            self.popingUpWindowsView7.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    
    @IBAction func outView(_ sender: Any) {
        
        self.popingUpWindowsView7.alpha = 0
       
    }
    @objc func removeView() {
        self.hintView.removeFromSuperview()
        self.hintImage.alpha = 0
        removeButton.removeFromSuperview()
        
        
        
    }
    
    
    
    
   

}
