//
//  DialogCollectionViewCell.swift
//  CodeARKit
//
//  Created by Blacour on 2020/8/6.
//

import UIKit

class DialogCollectionViewCellTwo: UICollectionViewCell {
    
    var delegate:DialogCollectionViewCellTwoDelegate?
    var index = 0
    
    @IBOutlet weak var screenImageButton: UIButton!
    @IBOutlet weak var screenLabel: UILabel!
    
    
    @IBAction func screenImageButtonTapped(_ sender: UIButton) {
        delegate?.screenImageButtonTapped(index: index)
    }
    
}


protocol DialogCollectionViewCellTwoDelegate {
    func screenImageButtonTapped(index: Int)
}

