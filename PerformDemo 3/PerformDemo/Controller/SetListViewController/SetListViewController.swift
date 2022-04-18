//
//  SetListViewController.swift
//  PerformDemo
//
//  Created by mac on 17/11/21.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import CoreData
import GoogleSignIn
import GoogleAPIClientForREST
import SwiftyDropbox

protocol SetListViewControllerDelegate {
    func passDocument(document: Document)
}

class SetListViewController: UIViewController, UITextFieldDelegate {
    
    //    MARK:- IBOUTLETS and VARIABLES
    
    @IBOutlet weak var btnImportOutlet: UIButton!
    @IBOutlet weak var btnSettingOutlet: UIButton!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnMove: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnSelectAll: UIButton!
    @IBOutlet weak var btnSegementControl: UISegmentedControl!
    @IBOutlet weak var lblAllPlaylist: UILabel!
    @IBOutlet weak var setListTableView: UITableView!
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    
    var searchEnabled = Bool()
    var documents = [Document]()
    var searchedDocument = [Document]()
    var setList = [Setlist]()
    var arrSelectedDocument = [Document]()
    var arrSelectedSetList = [Setlist]()
    var delegate : SetListViewControllerDelegate?
    var searchedSetlist = [Setlist]()
    var isSelect = false
    var isDocExist:Bool! = false
    
    //    MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBarOutlet.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchDocuments()
    }
    
    //    MARK:- Private Methods
    
    func selectFiles() {
        let documentPickerController = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String], in: .import)
        documentPickerController.delegate = self
        self.present(documentPickerController, animated: true, completion: nil)
    }
    
    func fetchDocuments() {
        CoreDataManager.sharedInstance.fetchDocuments { (documents, error) in
            if error == nil {
                if let documents = documents {
                    self.documents = documents
                    self.setListTableView.reloadData()
                }
            }
        }
    }
    
    func fetchSetList() {
        CoreDataManager.sharedInstance.fetchSetList { (setList, error) in
            if error == nil {
                if let setList = setList {
                    self.setList = setList
                    self.setListTableView.reloadData()
                }
            }
        }
    }
    func saveSetList(setList: [String:Any]) {
        CoreDataManager.sharedInstance.saveSetList(docDict: setList) { (isSuccess) in
            if isSuccess {
                self.fetchSetList()
            } else {
                print("error in save setList")
            }
        }
    }
    
    //    MARK:- Google Login
    private func setupGoogleSignIn() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeDrive]
        GIDSignIn.sharedInstance().signIn()
    }
    
    func loginToDropbox() {
        if DropboxClientsManager.authorizedClient != nil {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GoogleDriveDataVC") as! GoogleDriveDataVC
            vc.isDropboxScreen = true
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            let scopeRequest = ScopeRequest(scopeType: .user, scopes: ["account_info.read","files.metadata.read","files.content.read"], includeGrantedScopes: false)
            DropboxClientsManager.authorizeFromControllerV2(UIApplication.shared, controller: self, loadingStatusDelegate: nil, openURL: { url in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }, scopeRequest: scopeRequest)
        }
    }
    
    func saveDocsetRelation(setList:[Setlist],document:[Document]) {
        CoreDataManager.sharedInstance.saveDocSetRelation(setList: setList, document: document) { (isSuccess) in
            self.arrSelectedDocument.removeAll()
            self.arrSelectedSetList.removeAll()
        }
    }
    //    MARK:- IBACTIONS
    
    @IBAction func btnSettingAction(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnimportAction(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.alert)
        
        let googleDrive = UIAlertAction(title: "Google Drive", style: .default) { alert in
            self.setupGoogleSignIn()
        }
        alertController.addAction(googleDrive)
        
        let dropBox = UIAlertAction(title: "Dropbox", style: .default) { (action) in
            self.loginToDropbox()
        }
        alertController.addAction(dropBox)
        
        let files =  UIAlertAction(title: "Files", style: .default) { (action) in
            self.selectFiles()
        }
        alertController.addAction(files)
        
        let cancelAct = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAct)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func btnAddAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Add Setlist", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) -> Void in
            textField.placeholder = "Setlist name"
            textField.autocapitalizationType = .words
        }
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (alertAction) -> Void in
            let val = (alert.textFields![0] as UITextField).text! as String
            self.saveSetList(setList: ["setName":val])
        }
        let cancleAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (alertAction) -> Void in
        }
        alert.addAction(cancleAction)
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
    @IBAction func btnSelectAction(_ sender: UIButton) {
        self.btnSegementControl.isUserInteractionEnabled = false
        btnSettingOutlet.isHidden = true
        btnSelectAll.isHidden = false
        btnSelect.isHidden = true
        btnImportOutlet.isHidden = true
        btnCancel.isHidden = false
        
        self.isSelect = true
        
        DispatchQueue.main.async {
            self.setListTableView.reloadData()
        }
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.arrSelectedDocument.removeAll()
        self.arrSelectedSetList.removeAll()
        self.btnSegementControl.isUserInteractionEnabled = true
        self.btnSegementControl.selectedSegmentIndex = 0
        self.btnSegementControl.isHidden = false
        self.lblAllPlaylist.isHidden = true
        btnSettingOutlet.isHidden = false
        btnSelectAll.isHidden = true
        btnSelect.isHidden = false
        btnImportOutlet.isHidden = false
        btnCancel.isHidden = true
        btnMove.isHidden = true
        btnDone.isHidden = true
        self.isSelect = false
        
        DispatchQueue.main.async {
            self.setListTableView.reloadData()
        }
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        
    }
    
    @IBAction func btnMoveAction(_ sender: UIButton) {
        self.btnSegementControl.selectedSegmentIndex = 1
        self.fetchSetList()
        self.btnSegementControl.isHidden = true
        self.lblAllPlaylist.isHidden = false
        self.btnDone.isHidden = false
        btnMove.isHidden = true
        self.searchEnabled = false
    }
    
    @IBAction func btnDoneAction(_ sender: UIButton) {
        
        self.btnSegementControl.isUserInteractionEnabled = true
        self.setListTableView.isEditing = false
        self.setListTableView.allowsMultipleSelectionDuringEditing = false
        self.btnSegementControl.selectedSegmentIndex = 1
        self.lblAllPlaylist.isHidden = true
        btnSegementControl.isHidden = false
        btnSelect.isHidden = true
        btnAdd.isHidden = false
        btnSettingOutlet.isHidden = false
        btnImportOutlet.isHidden = false
        btnCancel.isHidden = true
        btnDone.isHidden = true
        self.isSelect = false
        
        saveDocsetRelation(setList: arrSelectedSetList, document: arrSelectedDocument)
        
        DispatchQueue.main.async {
            self.setListTableView.reloadData()
        }
    }
    
    @IBAction func btnSelectAllAction(_ sender: UIButton) {
        btnMove.isHidden = false
        btnSelectAll.isHidden = true
        self.isSelect = true
        self.setListTableView.separatorStyle = .none
        let selectRows = self.setListTableView.numberOfRows(inSection: 0)
        for row in 0..<selectRows {
            self.setListTableView.selectRow(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: .none)
        }
        self.arrSelectedDocument = self.documents
    }
    
    @IBAction func btnSegementAction(_ sender: UISegmentedControl) {
        if btnSegementControl.selectedSegmentIndex == 0 {
            
            btnSelect.isHidden = false
            btnAdd.isHidden = true
            btnSelectAll.isHidden = true
            self.setListTableView.isEditing = false
            self.setListTableView.allowsMultipleSelectionDuringEditing = false
            self.isSelect = false
            self.fetchDocuments()
            if searchEnabled {
                if #available(iOS 13.0, *) {
                    self.searchBarOutlet.searchTextField.resignFirstResponder()
                    self.searchBarOutlet.searchTextField.text = ""
                } else {
                    self.searchBarOutlet.resignFirstResponder()
                    self.searchBarOutlet.text = ""
                }
            }
            self.searchEnabled = false
        } else if  btnSegementControl.selectedSegmentIndex == 1 {
            
            btnSelect.isHidden = true
            btnAdd.isHidden = false
            btnSelectAll.isHidden = true
            btnCancel.isHidden = true
            btnMove.isHidden = true
            btnImportOutlet.isHidden = false
            btnSettingOutlet.isHidden = false
            self.setListTableView.isEditing = false
            self.setListTableView.allowsMultipleSelectionDuringEditing = false
            self.isSelect = false
            self.fetchSetList()
            if searchEnabled {
                if #available(iOS 13.0, *) {
                    self.searchBarOutlet.searchTextField.resignFirstResponder()
                    self.searchBarOutlet.searchTextField.text = ""
                } else {
                    self.searchBarOutlet.resignFirstResponder()
                    self.searchBarOutlet.text = ""
                }
            }
            self.searchEnabled = false
        }
        
    }
    @IBAction func btnPlayPlayListAction(_ sender: UIButton) {
    }
    
}

//MARK:- TableView Delegate and Datasource
extension SetListViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if btnSegementControl.selectedSegmentIndex == 0 {
            if searchEnabled {
                return self.searchedDocument.count
            } else {
                return documents.count
            }
        } else if btnSegementControl.selectedSegmentIndex == 1 {
            if searchEnabled {
                 return searchedSetlist.count
            } else {
                return setList.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.setListTableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
        if btnSegementControl.selectedSegmentIndex == 0 {
            if searchEnabled {
                if self.searchedDocument.count > 0
                 {
                    cell.textLabel?.text = "\(searchedDocument[indexPath.row].docName!)"
                }
                else
                 {
                    cell.textLabel?.text = ""
                }
            } else {
                if self.documents.count > 0
                {
                    cell.textLabel?.text = "\(documents[indexPath.row].docName!)"
                }
                else
                {
                    cell.textLabel?.text = ""
                }
            }
            
            if self.isSelect {
                self.setListTableView.isEditing = true
                self.setListTableView.allowsMultipleSelectionDuringEditing = true
            } else {
                self.setListTableView.isEditing = false
                self.setListTableView.allowsMultipleSelectionDuringEditing = false
            }
            
        } else if btnSegementControl.selectedSegmentIndex == 1 {
            if searchEnabled {
                if self.searchedSetlist.count > 0
                 {
                    cell.textLabel?.text = "\(searchedSetlist[indexPath.row].setName!)"
                }
                else
                 {
                    cell.textLabel?.text = ""
                }
            } else {
                if self.setList.count > 0
                {
                    cell.textLabel?.text = "\(setList[indexPath.row].setName!)"
                }
                else
                {
                    cell.textLabel?.text = ""
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchEnabled {
            if self.isSelect {
                if btnSegementControl.selectedSegmentIndex == 0 {
                    btnDone.isHidden = true
                    btnMove.isHidden = false
                    btnSelectAll.isHidden = true
                    let document = self.searchedDocument[indexPath.row]
                    if self.arrSelectedDocument.contains(document) {
                        self.arrSelectedDocument.removeAll { $0 as Document === document as Document }
                    } else {
                        self.arrSelectedDocument.append(document)
                    }
                } else if btnSegementControl.selectedSegmentIndex == 1 {
                    let setList = self.searchedSetlist[indexPath.row]
                    if self.arrSelectedSetList.contains(setList) {
                        self.arrSelectedSetList.removeAll { $0 as Setlist === setList as Setlist }
                    } else {
                        self.arrSelectedSetList.append(setList)
                    }
                }
            } else {
                if btnSegementControl.selectedSegmentIndex == 0 {
                    delegate?.passDocument(document: searchedDocument[indexPath.row])
                    self.navigationController?.popViewController(animated: true)
                } else if btnSegementControl.selectedSegmentIndex == 1 {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                    vc.setList = self.searchedSetlist[indexPath.row]
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
        } else {
            if self.isSelect {
                if btnSegementControl.selectedSegmentIndex == 0 {
                    btnDone.isHidden = true
                    btnMove.isHidden = false
                    btnSelectAll.isHidden = true
                    let document = self.documents[indexPath.row]
                    if self.arrSelectedDocument.contains(document) {
                        self.arrSelectedDocument.removeAll { $0 as Document === document as Document }
                    } else {
                        self.arrSelectedDocument.append(document)
                    }
                } else if btnSegementControl.selectedSegmentIndex == 1 {
                    let setList = self.setList[indexPath.row]
                    if self.arrSelectedSetList.contains(setList) {
                        self.arrSelectedSetList.removeAll { $0 as Setlist === setList as Setlist }
                    } else {
                        self.arrSelectedSetList.append(setList)
                    }
                }
            } else {
                if btnSegementControl.selectedSegmentIndex == 0 {
                    delegate?.passDocument(document: documents[indexPath.row])
                    self.navigationController?.popViewController(animated: true)
                } else if btnSegementControl.selectedSegmentIndex == 1 {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                    vc.setList = self.setList[indexPath.row]
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
        }
        
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if self.isSelect {
            if btnSegementControl.selectedSegmentIndex == 0 {
                let document = self.documents[indexPath.row]
                if self.arrSelectedDocument.contains(document) {
                    self.arrSelectedDocument.removeAll { $0 as Document === document as Document }
                } else {
                    self.arrSelectedDocument.append(document)
                }
            } else if btnSegementControl.selectedSegmentIndex == 1 {
                let setList = self.setList[indexPath.row]
                if self.arrSelectedSetList.contains(setList) {
                    self.arrSelectedSetList.removeAll { $0 as Setlist === setList as Setlist }
                } else {
                    self.arrSelectedSetList.append(setList)
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if btnSegementControl.selectedSegmentIndex == 0 {
            
            var pickedDocument: Document?
            
            if self.searchEnabled {
                pickedDocument = self.searchedDocument[indexPath.row]
            } else {
                pickedDocument = self.documents[indexPath.row]
            }
                        
            let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
                DispatchQueue.main.async {
                    let deletedSong = pickedDocument
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Document")
                    let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
                    fetchRequest.includesPropertyValues = false
                    do {
                        managedObjectContext?.delete(deletedSong!)
                        managedObjectContext!.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
                        try managedObjectContext?.save()
                        self.documents.remove(at: indexPath.row)
                    CoreDataManager.sharedInstance.fetchDocuments(completionHandler: { (document, error) in
                            if error == nil {
                                self.fetchDocuments()
                            }
                        })
                    } catch {
                    }
                }
            }
            
            let rename = UIContextualAction(style: .normal, title: "Rename") { (action, sourceView, completionHandler) in
                let alertAddList = UIAlertController(title: "Perform!", message: "Please enter new name for song.", preferredStyle: .alert)
                alertAddList.addTextField { (textField) in
                    

                    textField.text = pickedDocument!.docName ?? ""
                    textField.delegate = self as UITextFieldDelegate
                    textField.layer.cornerRadius = 4
                    textField.autocapitalizationType = .words
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let okAction = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                    
                    let answer = alertAddList.textFields![0]
                    
                    if answer.text!.count > 0
                    {
                        let docName = "\(answer.text!)"
                                                
                        
                        let docDict = ["docName": docName,"docData": pickedDocument!.docData!,"docPromptSize":pickedDocument!.docPromptSize ,"docPromptSpeed":pickedDocument!.docPromptSpeed] as [String : Any]
                        
                        
                        CoreDataManager.sharedInstance.fetchDocuments(completionHandler: {(documents, error) in
                            if error == nil {
                                if let document = documents {
                                    for document in document {
                                        if document.docName ?? "" == docName {
                                            self.isDocExist = true
                                        }
                                    }
                                    
                                    if self.isDocExist == true {
                                        self.isDocExist = false
                                        self.dismiss(animated: true, completion: nil)
                                    }else {
                                        DispatchQueue.main.async {
                                        _ = CoreDataManager.sharedInstance.updateDocument(documnet: pickedDocument!, docDict: docDict)
                                            
                                            self.fetchDocuments()
                                        }
                                    }
                                }
                            }
                        })
                    }
                }
                alertAddList.addAction(cancelAction)
                alertAddList.addAction(okAction)
                self.present(alertAddList, animated: true, completion: nil)
            }
            let swipeActionConfig = UISwipeActionsConfiguration(actions: [rename,delete])
            swipeActionConfig.performsFirstActionWithFullSwipe = false
            return swipeActionConfig
        } else {
            
            var pickedSetlist: Setlist?
            
            if self.searchEnabled {
                pickedSetlist = self.searchedSetlist[indexPath.row]
            } else {
                pickedSetlist = self.setList[indexPath.row]
            }
            
            
            let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
                DispatchQueue.main.async {
                    let deletedSong = pickedSetlist
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Setlist")
                    let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
                    fetchRequest.includesPropertyValues = false
                    do {
                        managedObjectContext?.delete(deletedSong!)
                        managedObjectContext!.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
                        try managedObjectContext?.save()
                        self.setList.remove(at: indexPath.row)
                    CoreDataManager.sharedInstance.fetchDocuments(completionHandler: { (document, error) in
                            if error == nil {
                                self.fetchSetList()
                            }
                        })
                    } catch {
                    }
                }
            }
            let rename = UIContextualAction(style: .normal, title: "Rename") { (action, sourceView, completionHandler) in
                let alertAddList = UIAlertController(title: "Perform!", message: "Please enter new name for song.", preferredStyle: .alert)
                alertAddList.addTextField { (textField) in
                    let setlist = pickedSetlist!.setName ?? ""
                    textField.text = setlist
                    textField.delegate = self as UITextFieldDelegate
                    textField.layer.cornerRadius = 4
                    textField.autocapitalizationType = .words
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let okAction = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                    
                    let answer = alertAddList.textFields![0]
                    
                    if answer.text!.count > 0
                    {
                        let setName = "\(answer.text!)"
                        
                        let docDict = ["setName": setName] as [String : Any]
                        
                        CoreDataManager.sharedInstance.fetchSetList(completionHandler: {(setLists, error) in
                            if error == nil {
                                if let setLists = setLists {
                                    for setList in setLists {
                                        if setList.setName ?? "" == setName {
                                            self.isDocExist = true
                                        }
                                    }
                                    
                                    if self.isDocExist == true {
                                        self.isDocExist = false
                                        let alert = UIAlertController(title: "Perform!", message: "This document is already exist in your list please choose different name for your document.", preferredStyle: .alert)
                                        alert.addAction(cancelAction)
                                        DispatchQueue.main.async {
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                    }else {
                                        DispatchQueue.main.async {
                                          CoreDataManager.sharedInstance.updateSetList(setList: pickedSetlist!, docDict: docDict)
                                            
                                            self.fetchSetList()
                                        }
                                    }
                                }
                            }
                        })
                    }
                }
                alertAddList.addAction(cancelAction)
                alertAddList.addAction(okAction)
                self.present(alertAddList, animated: true, completion: nil)
            }
            let swipeActionConfig = UISwipeActionsConfiguration(actions: [rename,delete])
            swipeActionConfig.performsFirstActionWithFullSwipe = false
            return swipeActionConfig
        }
    }
    
}


extension SetListViewController: UINavigationControllerDelegate,UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            
            var docDict = [String:Any]()
            docDict["docName"] = url.lastPathComponent.replacingOccurrences(of: ".pdf", with: "", options: NSString.CompareOptions.literal, range: nil)
            let data = NSData(contentsOf: url)
            docDict["docData"] = data
            
            CoreDataManager.sharedInstance.saveDocument(docDict: docDict) { (isSuccess) in
                if isSuccess {
                    self.fetchDocuments()
                }
            }
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension SetListViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GoogleDriveDataVC") as! GoogleDriveDataVC
        if let _ = error {
            vc.service.authorizer = nil
        } else {
            vc.service.authorizer = user.authentication.fetcherAuthorizer()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
extension SetListViewController: UISearchBarDelegate {
    func filterContent(forSearchText searchText: String)
    {
        if btnSegementControl.selectedSegmentIndex == 0 {
            self.searchedDocument.removeAll()
            for document in self.documents
            {
                let names = "\((document as AnyObject).value(forKey: "docName")!)"
                if((names).lowercased().contains(searchText.lowercased()))
                {
                    searchedDocument.append(document)
                }
                self.setListTableView.reloadData()
            }
        } else if btnSegementControl.selectedSegmentIndex == 1 {
            self.searchedSetlist.removeAll()
            for setlist in self.setList
            {
                let names = "\((setlist as AnyObject).value(forKey: "setName")!)"
                if((names).lowercased().contains(searchText.lowercased()) )
                {
                    searchedSetlist.append(setlist)
                }
              //  self.selectedSearchedPlaylistIndexes.removeAll()
//                if self.searchedSetlist.count != 0 {
//                    for index in 0...self.searchedSetlist.count - 1 {
//                        self.selectedSearchedPlaylistIndexes.append(index)
//                    }
//                }
                self.setListTableView.reloadData()
            }
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" {
            if #available(iOS 13.0, *) {
                self.searchBarOutlet.searchTextField.resignFirstResponder()
                self.searchBarOutlet.searchTextField.text = ""
            } else {
                self.searchBarOutlet.resignFirstResponder()
                self.searchBarOutlet.text = ""
            }
            self.searchEnabled = false
            self.setListTableView.reloadData()
        }
        else {
            searchEnabled = true
            filterContent(forSearchText: searchBar.text!)

            self.setListTableView.reloadData()
        }
    }
       
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchEnabled = true
        filterContent(forSearchText: searchBar.text!)
    }
       
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBarOutlet.resignFirstResponder()
        self.searchBarOutlet.showsCancelButton = false
        if #available(iOS 13.0, *) {
            self.searchBarOutlet.searchTextField.text = ""
        } else {
            self.searchBarOutlet.text = ""
        }
        searchEnabled = false
        setListTableView.reloadData()
    }
}
