//
//  EditViewController.swift
//  PerformDemo
//
//  Created by mac on 17/11/21.
//

import UIKit
import PDFKit
import MessageUI
import QuickLook

class EditViewController: UIViewController, PDFViewDelegate {
   
    
  
    //    MARK:- IBOUTLETS(s)
    @IBOutlet weak var btnPrompt: UIButton!
    @IBOutlet weak var pdfSuperView: UIView!
   
    @IBOutlet weak var vwFormatView: UIView!
    
    @IBOutlet weak var vwFormatHeightContstraint: NSLayoutConstraint!
    @IBOutlet weak var btnExport: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
        
    //    MARK:- VARIABLES(s)
    var pdfView: PDFView!
    var currentDocument: Document?
    
    var previewFile: URL?
    
    var indicator = UIActivityIndicatorView()
    
    //    MARK:- VIEW CYCLE(s)
    override func viewDidLoad() {
        super.viewDidLoad()
        vwFormatView.isHidden = true
        vwFormatHeightContstraint.constant = 0
        
        self.pdfView = PDFView.init()
    
        if let docId = UserDefaults.standard.value(forKey: "currentDocId") as? Int64 {
            if let curDoc = CoreDataManager.sharedInstance.getDocumentWithID(Id: docId) {
                self.currentDocument = curDoc
            }
            
        } else {
            if let docs = CoreDataManager.sharedInstance.fetchDocumentsWithoutCompletion() {
                for doc in docs {
                    
                    if "\(doc.docName ?? "")" == "About Perform" {
                        self.currentDocument = doc
                        
                        break
                    }
                    
                }
            }
        }
        
        if let curDoc = self.currentDocument {
            self.setDocument(document: curDoc)            
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationCall(_:)), name: .passPdfDocument, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pdfView.frame = view.frame
    }
    
    //    MARK:- IBACTIONS(s)
    @IBAction func btnPromptAction(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PromptDocumentViewController") as! PromptDocumentViewController
        if let doc = self.currentDocument {
            vc.document = doc
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnExportAction(_ sender: UIButton) {
        self.sendEmail()
    }
    
    @IBAction func btnShareAction(_ sender: UIButton) {
        
        let pdfData = self.currentDocument?.docData
        let vc = UIActivityViewController(
            activityItems: [pdfData!],
            applicationActivities: []
        )
        vc.excludedActivityTypes = [UIActivity.ActivityType.airDrop,UIActivity.ActivityType.assignToContact,UIActivity.ActivityType.copyToPasteboard,UIActivity.ActivityType.postToTencentWeibo,UIActivity.ActivityType.print,UIActivity.ActivityType.saveToCameraRoll,UIActivity.ActivityType.mail]
        vc.popoverPresentationController?.sourceView = sender
        present(vc, animated: true, completion: nil)
    }
    @IBAction func btnIAPAction(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "InAppPurchaseViewController") as! InAppPurchaseViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnMyDocsAction(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SetListViewController") as! SetListViewController
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnEditAction(_ sender: UIButton) {
        
        if self.currentDocument != nil {
            let quickLookViewController = QLPreviewController()
            
            quickLookViewController.dataSource = self
            quickLookViewController.delegate = self
            
            self.previewFile = self.getFileFromDirectory()
            
            self.present(quickLookViewController, animated: true)
            
        } else {
            let ac = UIAlertController(title: "Perform!", message: "There is no file.", preferredStyle: .alert)
            let okAct = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            ac.addAction(okAct)
            self.present(ac, animated: true, completion: nil)
        }

    }
  
    
    //    MARK:- PRIVATE METHODS(s)
    
    @objc func notificationCall(_ sender:Notification) {
        let object = sender.object as! [String:Any]
        self.currentDocument = object["document"] as? Document
        if let doc = currentDocument {
            setDocument(document: doc)
        }
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let docName = "\(lblTitle!.text ?? "")"
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setToRecipients([""])
            mailComposer.setSubject("\(docName) lyrics exported from Perform!")
            mailComposer.setMessageBody("Here's the latest version of \(docName) from Perform!", isHTML: true)
            if let fileData = self.currentDocument?.docData {
                print ("File data loaded.")
                print (fileData)
                mailComposer.addAttachmentData(fileData as Data, mimeType: "application/pdf", fileName: "GST")
            }
            
            mailComposer.modalPresentationStyle = .fullScreen
            present(mailComposer, animated: true)
        } else {
            let alertView = UIAlertController(title: "Perform!", message: "Make sure your device can send Emails.", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alertView.addAction(dismissAction)
            self.present(alertView, animated: true, completion: nil)
        }
    }
    func setDocument(document:Document) {
        
        UserDefaults.standard.set(document.docId, forKey: "currentDocId")
        
        pdfView.autoScales = true
        pdfView.delegate = self
        self.lblTitle.text = document.docName
        if let documentData = document.docData {
            pdfView.document = PDFDocument(data: documentData)
        } else {
            
           pdfView.document = nil
        }
    
        pdfView.frame = CGRect.init(x: 0, y: 0, width: pdfSuperView.frame.width, height: pdfSuperView.frame.height)
        
       self.pdfSuperView.addSubview(pdfView)
        
        self.writeFileToDirectory()
    }
    
    func writeFileToDirectory() {
        var pdfURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
        pdfURL = pdfURL.appendingPathComponent("Swift.pdf") as URL
        
        if let data = self.currentDocument?.docData {
            do {
                
                try data.write(to: pdfURL, options: .atomicWrite)
            }
            catch let err {
                print(err.localizedDescription)
            }
        }
    }
    
    func getFileFromDirectory() -> URL? {
        
        var url : URL? = nil
        
        if let pdfURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last {
            url = pdfURL.appendingPathComponent("Swift.pdf") as URL
        }
        
        return url
        
    }
    
}

//    MARK:- DELEGATE METHODS(s)
extension EditViewController: SetListViewControllerDelegate {
    func passDocument(document: Document) {
        self.currentDocument = document
        self.setDocument(document: document)
    }
}

extension EditViewController: MFMailComposeViewControllerDelegate {
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
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - QLPreviewControllerDataSource
extension EditViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        
        return self.getFileFromDirectory()! as QLPreviewItem
    }
}

// MARK: - QLPreviewControllerDelegate
extension EditViewController: QLPreviewControllerDelegate {
    
    func previewControllerWillDismiss(_ controller: QLPreviewController) {
        print("saved..")
    }
    
    func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
        .updateContents
    }
    
    func previewController(_ controller: QLPreviewController, didUpdateContentsOf previewItem: QLPreviewItem) {
        
        do {
            let data = try Data(contentsOf: previewItem as! URL)
            
            if let doc = self.currentDocument {
               
            let docDict = ["docName":doc.docName ?? "","docData":data,"docPromptSize":doc.docPromptSize ,"docPromptSpeed":doc.docPromptSpeed] as [String : Any]
                
                
            self.currentDocument = CoreDataManager.sharedInstance.updateDocument(documnet: self.currentDocument!, docDict: docDict)
                
            DispatchQueue.main.async {
                self.setDocument(document: self.currentDocument!)
                }
                
            }
            
        } catch let errs {
            print(errs.localizedDescription)
        }
        
    }
    
    func previewController(_ controller: QLPreviewController, didSaveEditedCopyOf previewItem: QLPreviewItem, at modifiedContentsURL: URL) {
        print(previewItem)
    }
    
}
