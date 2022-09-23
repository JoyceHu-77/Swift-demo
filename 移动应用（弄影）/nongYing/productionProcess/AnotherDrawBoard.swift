//
//  AnotherDrawBoard.swift
//  Draw
//
//  Created by Objective-C on 2017/1/13.
//  Copyright © 2017年 Quan Wai.Inc. All rights reserved.
//

import UIKit

class AnotherDrawBoard: UIView {
    var path = CGMutablePath() //当前画线的路径
    var color = UIColor() //当前画线的颜色
    var font_size = CGFloat() //当前画线的线宽
    var pointArray = NSMutableArray() //保存当前路径上的点
    var pathArray = NSMutableArray() //保存绘制线条的path

    
    //初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white;
        
        //初始化线条的颜色和宽度
        self.color = UIColor.black;
        self.font_size = 4;
    }
    
    //不写下面这个方法就报错
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //画线
    //触摸开始
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //创建path
        self.path = CGMutablePath();
        //把路径加入到路径数组中
        if !self.pathArray.contains(self.path) {
            self.pathArray.add(self.path);
        }
        
        //获取当前触摸点
        let touch:UITouch = touches.first! as UITouch;
        //当前点
        let currentPoint:CGPoint = touch.location(in: self);
        //移动到触摸点（原点）
        self.path.move(to: currentPoint);
        
        //百分比转换
        let point_x:CGFloat = currentPoint.x;
        let point_y:CGFloat = currentPoint.y;
        let point_dict:NSDictionary = ["x":100*point_x/mScreenWidth,
                                       "y":100*point_y/mScreenHeight]
        //保存下这个点
        self.pointArray.add(point_dict);
    }
    
    //触摸移动
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //当前移动点
        let touch:UITouch = touches.first! as UITouch;
        let currentPoint:CGPoint = touch.location(in: self);
        //移动画线
        self.path.addLine(to: currentPoint);
        
        //百分比转换
        let point_x:CGFloat = currentPoint.x;
        let point_y:CGFloat = currentPoint.y;
        let point_dict:NSDictionary = ["x":100*point_x/mScreenWidth,
                                       "y":100*point_y/mScreenHeight]
        //保存下这个点
        self.pointArray.add(point_dict);
        
        self.setNeedsDisplay();
    }
    
    //触摸结束
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {        
        //上传保存的点
        NSLog("%@", self.pointArray);
    }
    
    //触摸取消
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    //draw rect
    override func draw(_ rect: CGRect) {
        let context:CGContext = UIGraphicsGetCurrentContext()!;
        
        //重绘线条
        for index in 0 ..< self.pathArray.count {
            //线条宽度
            context.setLineWidth(self.font_size);
            //线条填充色
            context.setFillColor(UIColor.clear.cgColor);
            //线条颜色
            context.setStrokeColor(self.color.cgColor);
            //圆角线条
            context.setLineCap(CGLineCap(rawValue: 1)!);
            context.setLineJoin(CGLineJoin(rawValue: 1)!);
            
            let path:CGMutablePath = self.pathArray.object(at: index) as! CGMutablePath;
            context.addPath(path);
            context.drawPath(using: .fillStroke);
            UIGraphicsEndImageContext()
        }
        
    }

}
