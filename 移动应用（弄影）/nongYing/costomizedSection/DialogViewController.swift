//
//  DialogViewController.swift
//  nongYing
//
//  Created by Blacour on 2020/8/6.
//

import UIKit

class DialogViewController: UIViewController {

    
    var segueNum = Int()
    
    let image = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
    let screens = ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一", "十二"]
    
    let imageWallpaper = ["01","0花枝", "0花枝1", "0弄影", "0女2", "0双手挥舞","0椭圆","0祥云实心","0一口道尽","0印泥","0云","02","03","04","05","06"]
    let screensWallpaper = ["001","花枝", "花枝1", "弄影", "女2", "双手挥舞","椭圆","祥云实心","一口道尽","印泥","云","002","003","004","005","006"]
    
    var delegate: DialogViewControllerDelegate?
    
    
    
    @IBOutlet weak var screenCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenCollectionView.delegate = self
        screenCollectionView.dataSource = self
        screenCollectionView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    }

}

extension DialogViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "screenCell", for: indexPath) as! DialogCollectionViewCell
        if segueNum == 2 {
            cell.screenImageButton.setImage(UIImage(named: screensWallpaper[indexPath.row]), for: .normal)
        } else {
            cell.screenImageButton.setImage(UIImage(named: screens[indexPath.row]), for: .normal)
        }
        cell.delegate = self
        cell.index = indexPath.row
        return cell
    }
}

extension DialogViewController: DialogCollectionViewCellDelegate{
    func screenImageButtonTapped(index: Int) {
        dismiss(animated: true, completion: nil)
        if segueNum == 2 {
            delegate?.screenImageButtonTapped(image: UIImage(named: imageWallpaper[index])!)
        } else {
            delegate?.screenImageButtonTapped(image: UIImage(named: image[index])!)
        }
        
    }
}

protocol DialogViewControllerDelegate {
    func screenImageButtonTapped(image: UIImage)
    
}



