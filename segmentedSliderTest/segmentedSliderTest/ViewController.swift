//
//  ViewController.swift
//  segmentedSliderTest
//
//  Created by Blacour on 2021/9/13.
//

import UIKit

class ViewController: UIViewController {
    
    let frame = CGRect(x: 10, y: 100, width: UIScreen.main.bounds.width, height: 56)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sliderView = SegmentedSlider(frame: frame, equivalentDivisionCount: 4, maxLabelValue: 2, initialValue: 0, stepLength: 2) { views, sliceWidth in
            // config views
            let lastViewCount = views.count - 1
            views[lastViewCount].frame = CGRect(x: 0, y: 0, width: 16, height: 16)
            views[lastViewCount].center.y = views[0].center.y
            views[lastViewCount].center.x = views[lastViewCount - 1].center.x + sliceWidth
            views[lastViewCount].layer.cornerRadius = 8
        } valueCallback: { value in
            print("\(value)")
        }
        self.view.addSubview(sliderView)
    }
    
}
