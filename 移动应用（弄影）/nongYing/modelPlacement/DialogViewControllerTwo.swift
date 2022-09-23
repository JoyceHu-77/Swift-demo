//
//  DialogViewController.swift
//  CodeARKit
//
//  Created by Blacour on 2020/8/6.
//

import UIKit

class DialogViewControllerTwo: UIViewController, DialogViewControllerTwoDelegate, DialogCollectionViewCellTwoDelegate {
    func screenImageButtonTapped(name: String) {
        
    }
    

    
    let screens = ["002", "003", "004", "005", "006"]
    let titles = ["春鸡", "夏柳", "秋树", "冬梅", "大圣"]
    let models = ["others", "others1", "others4", "others3", "others2"]
    
    var delegate: DialogViewControllerTwoDelegate?
    
   
    @IBOutlet weak var screenCollectionViewTwo: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenCollectionViewTwo.delegate = self
        screenCollectionViewTwo.dataSource = self
    }

}

    
    
extension DialogViewControllerTwo: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "screenCell", for: indexPath) as! DialogCollectionViewCellTwo
        cell.screenImageButton.setImage(UIImage(named: screens[indexPath.row]), for: .normal)
        cell.screenLabel.text = titles[indexPath.row]
        cell.delegate = self
        cell.index = indexPath.row
        return cell
    }
}

extension DialogViewControllerTwo: DialogCollectionViewCellDelegate{
    func screenImageButtonTapped(index: Int) {
        dismiss(animated: true, completion: nil)
        delegate?.screenImageButtonTapped(name: models[index])
    }
}

protocol DialogViewControllerTwoDelegate {
    func screenImageButtonTapped(name: String)
    
}



