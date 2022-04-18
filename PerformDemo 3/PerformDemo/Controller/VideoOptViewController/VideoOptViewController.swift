//
//  VideoOptViewController.swift
//  PerformDemo
//
//  Created by Vineet Sharma on 03/02/22.
//

import UIKit

protocol VideoOptControllerDelegate {
    
    func featureSelected(cameraSel:Bool?,videoRecSel:Bool?)
}

class VideoOptViewController: UIViewController {

    @IBOutlet weak var showMeSwitch: UISwitch!
    @IBOutlet weak var recordMeSwitch: UISwitch!
    
    var isShowMe:Bool?
    var isVideoRecSelected:Bool?
    var isRecordMe:Bool?
    var delegate:VideoOptControllerDelegate? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupLayouts()
        
        isShowMe = UserDefaults.standard.bool(forKey: "isShowMe")
        if isShowMe ?? false {
            showMeSwitch.isOn = true
        } else {
            showMeSwitch.isOn = false
        }
        
        isRecordMe = UserDefaults.standard.bool(forKey: "isRecordMe")
        if isRecordMe ?? false {
            recordMeSwitch.isOn = true
        } else {
            recordMeSwitch.isOn = false
        }
    }
    
//    @objc func handleDoneAction() {
//        UserDefaults.standard.set(isShowMe, forKey: "isShowMe")
//        UserDefaults.standard.set(isRecordMe, forKey: "isRecordMe")
//        self.dismiss(animated: true, completion: nil)
//    }
    
    
    
    func setupLayouts() {
        self.navigationController?.navigationBar.barTintColor = .black
        self.navigationItem.title = "Video Options"
        self.showMeSwitch.layer.borderWidth = 2.0
        self.showMeSwitch.clipsToBounds = true
        self.showMeSwitch.layer.cornerRadius = 15
        self.showMeSwitch.layer.borderColor = UIColor.white.cgColor
        self.recordMeSwitch.layer.borderWidth = 2.0
        self.recordMeSwitch.clipsToBounds = true
        self.recordMeSwitch.layer.cornerRadius = 15
        self.recordMeSwitch.layer.borderColor = UIColor.white.cgColor
    }
    
    
    
    @IBAction func showMeAction(_ sender: UISwitch) {
        if showMeSwitch.isOn {
            isShowMe = true
        }else{
            isShowMe = false
        }
    }
    
    
    @IBAction func recordMeAction(_ sender: UISwitch) {
        if recordMeSwitch.isOn {
            isRecordMe = true
        }else{
            isRecordMe = false
        }
    }
    @IBAction func btnDoneAction(_ sender: UIButton) {
        UserDefaults.standard.set(isShowMe, forKey: "isShowMe")
        UserDefaults.standard.set(isRecordMe, forKey: "isRecordMe")
        print()
        self.delegate?.featureSelected(cameraSel: isShowMe, videoRecSel: isRecordMe)
        self.navigationController?.popViewController(animated: true)
    }
    
}
