//
//  DialogCollectionViewCell.swift
//  nongYing
//
//  Created by Blacour on 2020/11/10.
//

import UIKit

class DialogCollectionViewCell: UICollectionViewCell {
    
    var delegate:DialogCollectionViewCellDelegate?
    var index = 0
    
    @IBOutlet weak var screenImageButton: UIButton!
    @IBOutlet weak var screenLabel: UILabel!
    @IBAction func screenImageButtonTapped(_ sender: UIButton) {
        delegate?.screenImageButtonTapped(index: index)
    }
}


protocol DialogCollectionViewCellDelegate {
    func screenImageButtonTapped(index: Int)
}

