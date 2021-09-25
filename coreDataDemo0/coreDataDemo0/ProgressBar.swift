//
//  ProgressBar.swift
//  coreDataTestDemo
//
//  Created by Blacour on 2021/8/27.
//

import Foundation
import UIKit

class ProgressBarView: UIView {
    // 模拟progress属性 取值范围0.0-1.0
    var value: CGFloat = 0.0
    
    override func draw(_ rect: CGRect) {
        let c = UIGraphicsGetCurrentContext()!
        #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).set() // 设置进度条的背景色
        let ins: CGFloat = 2
        // 设置绘制区域 在原UIView尺寸的基础上向内缩 2 points
        let r = self.bounds.insetBy(dx: ins, dy: ins)
        // 2头圆弧的半径
        let radius: CGFloat = r.size.height / 2
        let d90 = CGFloat.pi / 2
      
        // 绘制路径
        let path = CGMutablePath()
        path.move(to: CGPoint(x: r.maxX - radius, y: ins))
        path.addArc(center: CGPoint(x: radius+ins, y: radius+ins), radius: radius, startAngle: -d90, endAngle: d90, clockwise: true)
        path.addArc(center: CGPoint(x: r.maxX - radius, y: radius + ins), radius: radius, startAngle: d90, endAngle: -d90, clockwise: true)
        path.closeSubpath()
        c.addPath(path)
        c.setLineWidth(2)
        c.strokePath()
        c.addPath(path)
        c.clip()
        c.fill(CGRect(x: r.origin.x, y: r.origin.y, width: r.width * self.value, height: r.height))
    }
}
