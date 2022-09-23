//
//  ViewControllerTest.swift
//  nongYing
//
//  Created by Blacour on 2020/10/26.
//

import UIKit

class ViewControllerTest: UIViewController, DialogViewControllerDelegate {
    
    var timer = Timer()
    var  timer2 = Timer()
    @IBOutlet weak var textViewBiZhi: UIView!
    
   
    @IBAction func addObjectBtn(_ sender: UIButton) {
        moveView.center = CGPoint(x: 590, y: 310)
        performSegue(withIdentifier: "HomeToDialog", sender: nil)
    }
    @IBAction func changeView(_ sender: UIButton) {
                if isChange == true {
                    self.view.bringSubviewToFront(platform)
                    addGestureRecognizer()
                    isChange = false
                } else {
                    self.view.sendSubviewToBack(platform)
                    isChange = true
                }
        
    }
    
    
    var moveImage = UIImageView()
    var testImageView = UIImageView()
    var testImage = UIImage()
    var testImageArray = [UIImage]()
    var testImageViewPoint = CGPoint()
    var testImagePointArray = [CGPoint]()
    var testImageTransformArray = [CGAffineTransform]()
    var platform = UIView()
    var startCenter = CGPoint()
    var isChange = true
    var moveView = UIView()
    var platform2 = UIView()
    
    
    override func viewDidLoad() {
        
        platform = UIView(frame: CGRect(x: 0, y: 150, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 300))
        platform2 = UIView(frame: CGRect(x: 0, y: 150, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 300))
        //        platform.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        timer2 = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(countTimer), userInfo: nil, repeats: true)
        
        view.addSubview(platform)
        view.addSubview(platform2)
        moveView.frame = CGRect(x: 420, y: 100, width: 340, height: 420)
        platform2.addSubview(moveView)
        for imageNum in 0...testImageArray.count - 1 {
            buildTestImageView(imageNum: imageNum)
            //            print(testImagePointArray)
        }
        //        addGestureRecognizer2()
        
    }
    
    
    //MARK:-生成imageView，以及对应的图片、坐标、状态
    func buildTestImageView(imageNum: Int) {
        print(testImageArray.count)
        var testImageView0 = UIImageView()
        testImageView0.frame = CGRect(x: 420, y: 100, width: 340, height: 420)
        testImageView0.image = testImageArray[imageNum]
        platform.addSubview(testImageView0)
        testImageView = testImageView0
        testImageView.center = testImagePointArray[imageNum + 1]
        testImageView.transform = testImageTransformArray[imageNum + 1]
    }
    
    
    //MARK:-手势1
    func addGestureRecognizer() {
        //添加滑动手势(用于移动和旋转模型)
        let Pan1GestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panFunc))
        platform.addGestureRecognizer(Pan1GestureRecognizer)
        
        //创建缩放手势(用于缩放模型)
        let PinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchFunc))
        platform.addGestureRecognizer(PinchGestureRecognizer)
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotationFunc))
        platform.addGestureRecognizer(rotationGestureRecognizer)
        
    }
    
    @objc func panFunc(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: platform.superview)
        if recognizer.state == .began {
            startCenter = platform.center
        }
        if recognizer.state != .cancelled {
            platform.center = CGPoint(x: startCenter.x + translation.x, y: startCenter.y + translation.y)
        }
    }
    
    @objc func pinchFunc(recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            platform.transform = platform.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
            platform.transform = platform.transform
        }
    }
    
    @objc func rotationFunc(recognizer: UIRotationGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            platform.transform = platform.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0.0
            platform.transform = platform.transform
            //            rotation.velocity 旋转速度 顺时针为正
        }
    }
    
    
    //MARK:-手势2
    func addGestureRecognizer2() {
        //添加滑动手势(用于移动和旋转模型)
        let Pan1GestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panFunc2))
        moveView.addGestureRecognizer(Pan1GestureRecognizer)
        print("move")
        
        //创建缩放手势(用于缩放模型)
        let PinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchFunc2))
        moveView.addGestureRecognizer(PinchGestureRecognizer)
        
        
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotationFunc2))
        moveView.addGestureRecognizer(rotationGestureRecognizer)
    }
    
    @objc func panFunc2(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: moveImage.superview)
        if recognizer.state == .began {
            startCenter = moveImage.center
        }
        if recognizer.state != .cancelled {
            moveImage.center = CGPoint(x: startCenter.x + translation.x, y: startCenter.y + translation.y)
            moveView.center = moveImage.center
            //            print(moveImage.center)
        }
    }
    
    @objc func pinchFunc2(recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            moveImage.transform = moveImage.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
            moveView.transform = moveImage.transform
        }
    }
    
    @objc func rotationFunc2(recognizer: UIRotationGestureRecognizer) {
        
        if recognizer.state == .began || recognizer.state == .changed {
            moveImage.transform = moveImage.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0.0
            moveView.transform = moveImage.transform
            //            rotation.velocity 旋转速度 顺时针为正
        }
    }
    
    
    //MARK:-添加模型
    func screenImageButtonTapped(image: UIImage) {
        testImage = image
        testImageArray.append(testImage)
        var moveImage0 = UIImageView()
        moveImage0.frame = CGRect(x: 420, y: 100, width: 340, height: 420)
        moveImage0.image = image
        //           platform.addSubview(moveImage0)
        platform2.addSubview(moveImage0)
        moveImage = moveImage0
        //           imageArray.append(moveImage)
        addGestureRecognizer2()
    }
    
    
    //MARK:-传值
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeToDialog" {
            let toVC = segue.destination as! DialogViewController
            toVC.delegate = self
            toVC.segueNum = 2
        }
    }
    
    @objc func countTimer(){
        textViewBiZhi.isHidden = true
    }
}
