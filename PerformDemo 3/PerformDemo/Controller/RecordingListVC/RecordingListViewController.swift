//
//  RecordingListViewController.swift
//  PerformDemo
//
//  Created by Apps Maven on 14/02/22.
//

import UIKit
import CoreData
import MessageUI

protocol checkDeleteRecording {
    func recordingDelete(recording:Recording,type:String?,name:String?)
}

class RecordingListViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var tblRecordings: UITableView!

    var delegate:checkDeleteRecording?
    
    var arrRecordings = [Recording]()
    
    var currentDoc: Document?
    
    var exportedSong: String? = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tblRecordings.register(UINib(nibName: "SettingsTVCell", bundle: nil), forCellReuseIdentifier: "SettingsTVCell")
        
        listRecordings()

    }
    
    func listRecordings() {
        if let doc = self.currentDoc {
            
            let recordings = doc.value(forKey: "recordings") as! NSSet
            self.arrRecordings = recordings.allObjects as! [Recording]
            
            if arrRecordings.count == 0 {
                UserDefaults.standard.removeObject(forKey: doc.docName ?? "")
            }
            
            self.tblRecordings.reloadData()
        }
    }
    
    @IBAction func btnDoneAction(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
}



extension RecordingListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.arrRecordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTVCell", for: indexPath) as! SettingsTVCell
        cell.accessoryType = .none
        cell.lblName.text = "\(self.arrRecordings[indexPath.row].recStr ?? "")"
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 64
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = ["recording": self.arrRecordings[indexPath.row]]
        
        NotificationCenter.default.post(name: .passRecording, object: dict)
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
            
            DispatchQueue.main.async {
                let deletedSong = self.arrRecordings[indexPath.row]
                
                self.delegate?.recordingDelete(recording: self.arrRecordings[indexPath.row], type: "Delete", name: "")
                
                do {
                    CoreDataManager.sharedInstance.context?.delete(deletedSong)
                    CoreDataManager.sharedInstance.context?.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
                    try CoreDataManager.sharedInstance.context?.save()
                    
                    
                    self.listRecordings()
                    
                } catch let catchError {
                    print(catchError.localizedDescription)
                }
            }
        }
        
        let rename = UIContextualAction(style: .normal, title: "Rename") { (action, sourceView, completionHandler) in
            
            let alertAddList = UIAlertController(title: "Perform!", message: "Please enter new name for recording.", preferredStyle: .alert)
            
            alertAddList.addTextField { (textField) in
                textField.text = self.arrRecordings[indexPath.row].recStr
                textField.delegate = self as UITextFieldDelegate
                textField.layer.cornerRadius = 4
                textField.autocapitalizationType = .words
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            let okAction = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                
                let answer = alertAddList.textFields![0]
                
                if answer.text!.count > 0 {
                    
                    var isexist:Bool = false
                    
                    for duplicateRec in self.arrRecordings {
                        if "\(duplicateRec.recStr ?? "")" == "\(answer.text ?? "")" {
                            isexist = true
                        }
                    }
                    
                    if isexist == true {
                        isexist = false
                        let alert = UIAlertController(title: "Perform!", message: "This recording name is already exist in your list please choose different name for your recording.", preferredStyle: .alert)
                        alert.addAction(cancelAction)
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                    } else {
                        CoreDataManager.sharedInstance.updateRecording(recording: self.arrRecordings[indexPath.row], recStr: "\(answer.text ?? "")")
                        
                        self.delegate?.recordingDelete(recording: self.arrRecordings[indexPath.row], type: "Rename", name: "\(answer.text ?? "")")
                        
                        self.listRecordings()
                    }
                    
                }
                
            }
            alertAddList.addAction(cancelAction)
            alertAddList.addAction(okAction)
            self.present(alertAddList, animated: true, completion: nil)
        }
        
        let share = UIContextualAction(style: .normal, title: "Share") { (action, sourceView, completionHandler) in
            
            DispatchQueue.main.async {
                
                if MFMailComposeViewController.canSendMail() {
                    let mailComposer = MFMailComposeViewController()
                    mailComposer.mailComposeDelegate = self
                    mailComposer.setToRecipients([""])
                    mailComposer.setSubject("\(self.arrRecordings[indexPath.row].recStr ?? "") exported from Perform!")
                    mailComposer.setMessageBody("", isHTML: true)
                    
                    
                    self.exportedSong = "\(self.arrRecordings[indexPath.row].recStr ?? "")"
                    
                    if let audioData = self.arrRecordings[indexPath.row].recData {
                        mailComposer.addAttachmentData(audioData, mimeType: "audio/mp4a-latm", fileName: "\(self.arrRecordings[indexPath.row].recStr ?? "")")
                    }

                    mailComposer.modalPresentationStyle = .fullScreen
                    self.present(mailComposer, animated: true)
                } else {
                    let alertView = UIAlertController(title: "Perform!", message: "Make sure your device can send Emails.", preferredStyle: .alert)
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
                    alertView.addAction(dismissAction)
                    self.present(alertView, animated: true, completion: nil)
                }
            }
        }
        
        share.backgroundColor = UIColor(red: 34.0/255.0, green: 34.0/255.0, blue: 34.0/255.0, alpha: 1)
        let swipeActionConfig = UISwipeActionsConfiguration(actions: [share, rename, delete])
        swipeActionConfig.performsFirstActionWithFullSwipe = false
        
        return swipeActionConfig
        
    }
    
}



extension RecordingListViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Cancelled")
        case MFMailComposeResult.saved.rawValue:
            print("saved")
        case MFMailComposeResult.failed.rawValue:
            print("failed")
        case MFMailComposeResult.sent.rawValue:
            print("sent")
            let alertView = UIAlertController(title: "Perform!", message: "\(self.exportedSong ?? "") exported successfully.", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertView.addAction(dismissAction)
            DispatchQueue.main.async {
            self.present(alertView, animated: true, completion: nil)
            }
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
}
