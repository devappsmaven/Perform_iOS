//
//  SettingsVC.swift
//  PerformDemo
//
//  Created by mac on 10/01/22.
//

import UIKit

class SettingsVC: UIViewController {

    //MARK:- IBOUTLETS
    @IBOutlet weak var tblViewSettings: UITableView!
    @IBOutlet weak var lblAbout: UILabel!
    var arrSettingList = ["How to Videos","Support","Other apps by DanteMedia.com","Turn your App Idea into a reality!","Perform App Version","Copyright © 2022-DANTE MEDIA,LLC"]
    
    //MARK:- VIEW LIFECYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tblViewSettings.register(UINib(nibName: "SettingsTVCell", bundle: nil), forCellReuseIdentifier: "SettingsTVCell")
        
        lblAbout.text = "About Perform"
    }
   
    //MARK:- IBACTIONS
    @IBAction func btnDoneAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
   //MARK:- UITABLEVIEW DELEGATE AND DATASOURCE METHODS
extension SettingsVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSettingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTVCell", for: indexPath) as! SettingsTVCell
        cell.lblName.text = arrSettingList[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}
