import UIKit

class ViewControllerOther: UIViewController, DialogViewControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var textViewDingZhi: UIView!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    var timer = Timer()
    var  timer2 = Timer()
    var moveImage = UIImageView()
    var moveView = UIView()
    var imageArray = [UIImageView]()
    var startCenter = CGPoint()
//    let imageView = UIView()
    var platform = UIView()
    var testImage = UIImage()
    var testImageArray = [UIImage]()
    var testImagePointArray = [CGPoint]()
    var testImageTransformArray = [CGAffineTransform]()
    
    @IBAction func resetButton(_ sender: UIButton) {
        reset()
    }
    @IBAction func addObjectButtonTapped(_ sender: UIButton) {
        testImagePointArray.append(moveImage.center)
        testImageTransformArray.append(moveView.transform)
        moveView.center = CGPoint(x: 590, y: 310)
        performSegue(withIdentifier: "HomeToDialog", sender: nil)
        nextBtn.isHidden = false
    }
    
    @IBAction func nextBtn(_ sender: UIButton) {
        testImagePointArray.append(moveView.center)
        testImageTransformArray.append(moveView.transform)
        print(testImagePointArray.count)
        performSegue(withIdentifier: "goToTest", sender: self)
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextBtn.isHidden = true
        timer2 = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(countTimer), userInfo: nil, repeats: true)
        
        platform = UIView(frame: CGRect(x: 0, y: 150, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 300))
        moveView.frame = CGRect(x: 420, y: 100, width: 340, height: 420)
        platform.addSubview(moveView)
        platform.isUserInteractionEnabled = true
        moveImage.isUserInteractionEnabled = true
        hideKeyboardWhenTappedAround()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let viewCenter = CGPoint(x: size.width / 2, y: size.height / 2)
        
    }
    
    
    //MARK:-手势
    func addGestureRecognizer() {
        //添加滑动手势(用于移动和旋转模型)
        let Pan1GestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panFunc))
        moveView.addGestureRecognizer(Pan1GestureRecognizer)
        print("move")

        //创建缩放手势(用于缩放模型)
        let PinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchFunc))
        moveView.addGestureRecognizer(PinchGestureRecognizer)


        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotationFunc))
        moveView.addGestureRecognizer(rotationGestureRecognizer)
    }
    
    @objc func panFunc(recognizer: UIPanGestureRecognizer) {
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
    
    @objc func pinchFunc(recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            moveImage.transform = moveImage.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
            moveView.transform = moveImage.transform
        }
    }
    
    @objc func rotationFunc(recognizer: UIRotationGestureRecognizer) {
        
        if recognizer.state == .began || recognizer.state == .changed {
            moveImage.transform = moveImage.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0.0
            moveView.transform = moveImage.transform
            //            rotation.velocity 旋转速度 顺时针为正
        }
    }
    
    
    //MARK:-撤销
    func reset() {
        if imageArray.count == 0{
            print("0")
        } else{
            var image0 = imageArray[imageArray.count - 1]
            image0.removeFromSuperview()
            imageArray.remove(at: imageArray.count-1)
            print("hh")
        }
        testImagePointArray.removeAll()
        testImageArray.removeAll()
        testImageTransformArray.removeAll()
        
        
    }
    
    
    //MARK:-添加组件模型
    func screenImageButtonTapped(image: UIImage) {
        addGestureRecognizer()
        testImage = image
        testImageArray.append(testImage)
        view.addSubview(platform)
        var moveImage0 = UIImageView()
        moveImage0.frame = CGRect(x: 420, y: 100, width: 340, height: 420)
        moveImage0.image = image
        platform.addSubview(moveImage0)
        moveImage = moveImage0
        imageArray.append(moveImage)
    }
    
    
    //MARK:-传值
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeToDialog" {
            let toVC = segue.destination as! DialogViewController
            toVC.delegate = self
        }
        if segue.identifier == "goToTest" {
            let destinationViewController = segue.destination as! ViewControllerTest
            destinationViewController.testImage = testImage
            destinationViewController.testImageArray = testImageArray
            destinationViewController.testImagePointArray = testImagePointArray
            destinationViewController.testImageTransformArray = testImageTransformArray
        }
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewControllerOther.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func countTimer(){
        textViewDingZhi.isHidden = true
    }
    
}

//MARK:-隐藏选择键盘


