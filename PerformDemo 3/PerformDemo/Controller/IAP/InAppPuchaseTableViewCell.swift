//
//  InAppPuchaseTableViewCell.swift
//  GigHard_Swift
//
//  Created by osx on 02/12/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit


class InAppPuchaseTableViewCell: UITableViewCell {
//    MARK:- IBOUTLET(S) AND VARIABLE(S)
    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var iapLabel: UILabel!
    @IBOutlet weak var buyBtn: UIButton!
    @IBOutlet weak var restoreBtn: UIButton!
    @IBOutlet weak var iconImgViewWidthContstraint: NSLayoutConstraint!
    @IBOutlet weak var buyBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var restoreBtnWidthConstraint: NSLayoutConstraint!
    
    
    var indexPath: Int?
    var productAvailable = [[String:Any]]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.restoreBtn.isHidden = true
        self.buyBtn.layer.cornerRadius = 10.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func restoreBtn(_ sender: UIButton) {
        
    }
}
