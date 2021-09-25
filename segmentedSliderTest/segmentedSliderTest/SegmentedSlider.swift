//
//  SegmentedSlider.swift
//  segmentedSliderTest
//
//  Created by Blacour on 2021/9/15.
//

import Foundation
import UIKit

class SegmentedSlider: UIView {
    
    fileprivate let sliderInsetLeft: CGFloat = 79.5
    fileprivate let sliderInsetRight: CGFloat = 79.5
    fileprivate let lineSpacingPanelHeight: CGFloat = 56
    fileprivate let firstCircleRadius: CGFloat = 4
    fileprivate let lastCircleRadius: CGFloat = 8
    fileprivate let thumbImageRadius: CGFloat = 8
    
    fileprivate var stepLength: CGFloat = 0
    fileprivate var initialValue: Float = 0
    fileprivate var equivalentDivisionCount: Float = 1
    fileprivate var maxLabelValue: Float = 1
    fileprivate lazy var mappingValueMultiplier: Float = equivalentDivisionCount / maxLabelValue
    fileprivate lazy var sliceWidth = (slider.frame.width - thumbImageRadius * 2) / CGFloat(equivalentDivisionCount)
    
    fileprivate var circleArray = [UIView]()
    
    var valueCallback: ((Float) -> ())?
    
    var sliderValueAfterMap: Float?
    
    init(frame: CGRect, equivalentDivisionCount: Float, maxLabelValue: Float, initialValue: Float, stepLength: CGFloat, config:([UIView], CGFloat)->(), valueCallback: ((Float) -> ())?) {
        super.init(frame: frame)
        self.equivalentDivisionCount = equivalentDivisionCount
        self.maxLabelValue = maxLabelValue
        self.initialValue = initialValue
        self.stepLength = stepLength
        self.valueCallback = valueCallback
        
        setUpBasic()
        config(circleArray, sliceWidth)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var slider: UISlider = { () -> UISlider in
        var value = UISlider()
        value.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - sliderInsetRight - sliderInsetLeft, height: lineSpacingPanelHeight)
        value.minimumValue = 0
        value.maximumValue = equivalentDivisionCount
        value.setValue(initialValue, animated: true)
        value.minimumTrackTintColor = RGB(255, green: 126, blue: 126)
        value.maximumTrackTintColor = RGB(245, green: 245, blue: 245)
        value.setThumbImage(RGB(255, green: 126, blue: 126).image(with: CGSize.init(width: 16, height: 16))?.cornered, for: .normal)
        value.addTarget(self, action: #selector(makeSliderDidChange(_:)), for: .valueChanged)
        return value
    }()
    
    @objc
    func makeSliderDidChange(_ sender: UISlider) {
        sender.setValue(round(sender.value), animated: false)
        changeCircleViewColor(sender: sender, indexFloat: sender.value)
        if let valueCallback = valueCallback {
            valueCallback(passOnMappingValue(value: sender.value))
        }
    }
    
    func passOnMappingValue(value: Float) -> Float {
        return value / mappingValueMultiplier
    }
    
    func changeCircleViewColor(sender: UISlider, indexFloat: Float) {
        if circleArray.isEmpty {return}
        let indexFloat = indexFloat
        let floor = floor(indexFloat)
        for (index, view) in circleArray.enumerated() {
            if index < Int(floor) {
                view.backgroundColor = RGB(255, green: 126, blue: 126)
            } else {
                view.backgroundColor = RGB(245, green: 245, blue: 245)
            }
        }
    }
    
    func makeSliderCircleViews(for slider: UISlider, radius: CGFloat, stepLength: CGFloat) -> [UIView] {
        
        var result = [UIView]()
        /// 平分宽度
        let sliceWidth = sliceWidth
        for index in 0..<Int(equivalentDivisionCount) {
            let i = CGFloat(index)
            let view = UIView.init(frame: CGRect(x: 0, y: 0, width: radius * 2 + i * stepLength, height: radius * 2 + i * stepLength))
            view.center.y = slider.center.y
            view.center.x = sliceWidth * (i + 1) + thumbImageRadius
            view.backgroundColor = RGB(255, green: 126, blue: 126)
            view.layer.cornerRadius = radius + i * stepLength * 0.5
            result.append(view)
        }
        return result
    }
    
    
    
}




extension SegmentedSlider {
    
    fileprivate func setUpBasic() {
        makeSliderCircleViews(for: slider, radius: firstCircleRadius, stepLength: stepLength).forEach {
            circleArray.append($0)
            self.addSubview($0)
        }
        changeCircleViewColor(sender: slider, indexFloat: initialValue)
        self.addSubview(slider)
    }
    
    func setValueAndChangeColor(value: Float) {
        slider.setValue(value * mappingValueMultiplier, animated: false)
        changeCircleViewColor(sender: slider, indexFloat: value * mappingValueMultiplier)
    }
    
    public func RGB(_ red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return RGBA(red, green: green, blue: blue, alpha: 1)
    }

    public func RGBA(_ red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor.init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
    
}

//MARK: extention
extension UIImage {
    var cornered: UIImage? {
        get {
            //取最短边长
            let shotest = min(size.width, size.height)
            //输出尺寸
            let outputRect = CGRect(x: 0, y: 0, width: shotest, height: shotest)
            UIGraphicsBeginImageContextWithOptions(outputRect.size, false, 0)
            
            defer {
                UIGraphicsEndImageContext()
            }
            guard let context = UIGraphicsGetCurrentContext() else {
                return nil
            }
            //添加圆形裁剪区域
            context.addEllipse(in: outputRect)
            context.clip()
            //绘制图片
            self.draw(in: CGRect(x: (shotest-size.width)/2,
                                 y: (shotest-size.height)/2,
                                 width: size.width,
                                 height: size.height))
            //获得处理后的图片
            return UIGraphicsGetImageFromCurrentImageContext()
        }
    }
}

extension NSString {
    func image(with attributes : [NSAttributedString.Key : Any], size: CGSize, inset: UIEdgeInsets = .zero, color: UIColor? = nil) -> UIImage? {
        var renderSize = CGSize.zero
        let options = NSStringDrawingOptions.init(arrayLiteral: .usesLineFragmentOrigin, .usesFontLeading)
        if size.width > 0 && size.height > 0 {
            renderSize = size
        } else if size.width > 0 {
            renderSize = CGSize(width: size.width, height: boundingRect(with: CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude), options: options, attributes: attributes, context: nil).size.height)
        } else if size.height > 0 {
            renderSize = CGSize(width: boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: size.width), options: options, attributes: attributes, context: nil).size.width, height: size.height)
        } else {
            return nil
        }
        
        let contextSize = CGSize.init(width: renderSize.width + inset.left + inset.right, height: renderSize.height + inset.top + inset.bottom)
        
        UIGraphicsBeginImageContextWithOptions(contextSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        let context = UIGraphicsGetCurrentContext()
        if let color = color {
            context?.setFillColor(color.cgColor)
            context?.fill(CGRect.init(origin: .zero, size: contextSize))
        }
        draw(in: CGRect.init(origin: CGPoint.init(x: inset.left, y: inset.bottom), size: renderSize), withAttributes: attributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
}

extension UIColor {
    func image(with size: CGSize) -> UIImage? {
        if let cgImage: CGImage = image(with: size) {
            return UIImage.init(cgImage: cgImage)
        }
        return nil
    }
    
    func image(with size: CGSize) -> CIImage? {
        if let cgImage: CGImage = image(with: size) {
            return CIImage.init(cgImage: cgImage)
        }
        return nil
    }
    
    func image(with size: CGSize) -> CGImage? {
        UIGraphicsBeginImageContext(size)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let imageContext = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        imageContext.setFillColor(cgColor)
        imageContext.fill(CGRect.init(origin: .zero, size: size))
        return imageContext.makeImage()
    }
}


