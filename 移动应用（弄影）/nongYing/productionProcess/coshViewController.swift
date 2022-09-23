//
//  coshViewController.swift
//  nongYing
//
//  Created by Blacour on 2020/7/30.
//

import UIKit

class coshViewController: UIViewController {

    
    @IBOutlet weak var popingUpWindowsViewColor: UIView!
    
    @IBOutlet weak var popingUpWindowsViewColorpop: UIView!
    var hintView = UIView()
    var hintImage = UIImageView()
    var removeButton = UIButton()
    @IBOutlet weak var baigujing: UIImageView!
    
    
    @IBOutlet weak var youshou: UIImageView!
    
    @IBOutlet weak var zuoshou: UIImageView!
    @IBOutlet weak var shenti: UIImageView!
    @IBOutlet weak var zuojiao: UIImageView!
    
    @IBOutlet weak var youjiao: UIImageView!
    
    
    @IBOutlet weak var color: UIButton!
    @IBOutlet weak var color2: UIButton!
    @IBOutlet weak var color3: UIButton!
    
    @IBOutlet weak var color4: UIButton!
    
    @IBOutlet weak var color5: UIButton!
    
    @IBOutlet weak var color6: UIButton!
    
    @IBOutlet weak var color7: UIButton!
    
    @IBOutlet weak var popingViewOut: UIButton!
    
    @IBOutlet weak var viewBut: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        removeButton.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        removeButton.addTarget(self,action:#selector(removeView),for:.touchUpInside)
        hintImage.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        hintImage.image = UIImage(named: "填色-1")
        hintView.frame = CGRect(x: 0, y: 0,width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        hintView.addSubview(hintImage)
        view.addSubview(hintView)
        hintView.addSubview(removeButton)

        // Do any additional setup after loading the view.
    }
    @IBAction func color(_ sender: UIButton) {
      
            self.baigujing.alpha = 1
           
    }
    
    
    @IBAction func color2(_ sender: UIButton) {
      
            self.youshou.alpha = 1
           
    }
    @IBAction func color3(_ sender: UIButton) {
      
            self.zuoshou.alpha = 1
           
    }
    @IBAction func color4(_ sender: UIButton) {
      
            self.shenti.alpha = 1
           
    }
    @IBAction func color5(_ sender: UIButton) {
      
            self.youjiao.alpha = 1
           
    }
    @IBAction func color6(_ sender: UIButton) {
      
            self.zuojiao.alpha = 1
           
    }
    
    
    
    @objc func removeView() {
        self.hintView.removeFromSuperview()
        self.hintImage.alpha = 0
        removeButton.removeFromSuperview()
        
    }
    
    @IBAction func viewBut(_ sender: UIButton) {
        popingUpWindowsViewColor.transform = CGAffineTransform(scaleX: 0.3, y: 2.0)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [UIView.AnimationOptions.curveEaseOut,.allowUserInteraction], animations: {
            self.popingUpWindowsViewColor.alpha = 0.8
            self.popingUpWindowsViewColor.layer.cornerRadius = 30
            self.popingUpWindowsViewColor.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @IBAction func color7(_ sender: UIButton) {
        popingUpWindowsViewColorpop.transform = CGAffineTransform(scaleX: 0.3, y: 2.0)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [UIView.AnimationOptions.curveEaseOut,.allowUserInteraction], animations: {
            self.popingUpWindowsViewColorpop.alpha = 0.8
            
            self.popingUpWindowsViewColorpop.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    @IBAction func popingViewOut(_ sender: Any) {
        self.popingUpWindowsViewColor.alpha = 0
    }
//    @IBAction func outView(_ sender: Any) {
//        self.popingUpWindowsViewColorpop.alpha = 0
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
