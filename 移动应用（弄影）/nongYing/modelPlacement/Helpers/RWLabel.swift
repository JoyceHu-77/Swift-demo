

import UIKit

class RWLabel: UILabel {
  override func drawText(in rect: CGRect) {
    let insets = UIEdgeInsets.init(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
    super.drawText(in: rect.inset(by: insets))
  }

}
