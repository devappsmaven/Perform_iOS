//
//  GoogleDriveDataVC.swift
//  PerformDemo
//
//  Created by mac on 22/11/21.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import SwiftyDropbox

class GoogleDriveDataVC: UIViewController {
    
    //    MARK:- IBOUTLET(s)
    @IBOutlet weak var tableViewGoogleData: UITableView!
    
    //    MARK:- VARIABLE(s)
    var newPath = ""
    var isDropboxScreen = false
    
    let service = GTLRDriveService()
    var arrGoogleDriveFiles = [GTLRDrive_File]()
    var arrDropboxFiles = [Files.Metadata]()
    
    //    MARK:- View Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.isDropboxScreen {
            self.dropboxListFiles(aPath: self.newPath)
            
        } else {
            self.googleDrivelistFiles(root: "")
        }
    }
    
    //    MARK:- IBACTIONS(s)
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnLogoutAction(_ sender: UIButton) {
        if self.isDropboxScreen {
            DropboxClientsManager.resetClients()
            DropboxClientsManager.unlinkClients()
        } else {
            GIDSignIn.sharedInstance().signOut()
        }
        
        let controllers = self.navigationController?.viewControllers
        for vc in controllers! {
            if vc is SetListViewController {
                self.navigationController?.popToViewController(vc as! SetListViewController, animated: true)
            }
        }
    }
    
    //    MARK:- PRIVATEMETHOD(s)
    @objc func importDocument(_ sender:UIButton) {
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let cell = self.tableViewGoogleData.cellForRow(at: indexPath) as! GoogleDriveTVCell
        cell.btnImportDocument.isUserInteractionEnabled = false
        
        if self.isDropboxScreen {
            self.downloadDBFile(file: self.arrDropboxFiles[sender.tag])
            
        } else {
            let file = self.arrGoogleDriveFiles[sender.tag]
            
            let seperatorString =  file.name!.replacingOccurrences(of: ".pdf", with: "", options: NSString.CompareOptions.literal, range: nil)
            
            print(seperatorString)
            self.download(file) { (data, err) in
                self.savePdfFile(document: ["docName": seperatorString , "docData": data ?? Data(),"docPromptSize":24,"docPromptSpeed":1])
            }
        }
    }
    
    func savePdfFile(document: [String:Any]) {
        
        CoreDataManager.sharedInstance.saveDocument(docDict: document) { (isSuccess) in
            if isSuccess {
                if  let controllers = self.navigationController?.viewControllers {
                    for vc in controllers {
                        if vc is SetListViewController {
                            self.navigationController?.popToViewController(vc as! SetListViewController, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    //    MARK:- DROPBOX METHODS(s)
    func dropboxListFiles(aPath: String) {
        if let client = DropboxClientsManager.authorizedClient {
            client.users.getCurrentAccount().response { (response, error) in
                if let account = response {
                    print("Hello \(account.name.givenName)")
                } else {
                    print(error!)
                }
            }
            
            client.files.listFolder(path: aPath).response { (response, error) in
                if let result = response {
                    for entry in result.entries {
                        if let file = (entry as AnyObject) as? Files.FileMetadata {
                            if file.name.hasSuffix(".pdf") {
                                self.arrDropboxFiles.append(entry)
                            }
                        } else if (entry as AnyObject) is Files.FolderMetadata {
                            self.arrDropboxFiles.append(entry)
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableViewGoogleData.reloadData()
                    }
                } else {
                    print(error!)
                }
            }
        }
    }
    
    func downloadDBFile(file: Files.Metadata) {
        if let client = DropboxClientsManager.authorizedClient {
            client.files.download(path: file.pathLower ?? "").response { response, error in
                if let (metadata, data) = response {
                    let seperatorString = metadata.name.replacingOccurrences(of: ".pdf", with: "", options: NSString.CompareOptions.literal, range: nil)
                    self.savePdfFile(document: ["docName": seperatorString, "docData": data])
                } else {
                    print(error!)
                }
            }
        }
    }
    
    
    func moveToFoldert(indexPath: IndexPath) {
        let fileMetadata = self.arrDropboxFiles[indexPath.row]
        if (fileMetadata is Files.FolderMetadata) {
            let newPath = fileMetadata.pathLower
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GoogleDriveDataVC") as! GoogleDriveDataVC
            vc.isDropboxScreen = true
            vc.newPath = newPath!
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //    MARK:- GOOGLE DRIVE METHODS(s)
    
    func googleDrivelistFiles(root : String) { //root
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 100
        query.q = root
        query.fields = "files(id,name,mimeType,modifiedTime,createdTime,fileExtension,size,parents,kind),nextPageToken"
        service.executeQuery(query, completionHandler: {(ticket, files, error) in
            if let filesList : GTLRDrive_FileList = files as? GTLRDrive_FileList {
                
                if let filesShow : [GTLRDrive_File] = filesList.files {
                    
                    for file in filesShow {
                        if let name = file.name {
                            if name.hasSuffix(".pdf") {
                                self.arrGoogleDriveFiles.append(file)
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.tableViewGoogleData.reloadData()
                    }
                }
            }
        })
    }
    
    public func listFiles(_ folderID: String, onCompleted: @escaping (GTLRDrive_FileList?, Error?) -> ()) {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 100
        query.q = "'\(folderID)' in parents and mimeType != 'application/vnd.google-apps.folder'"
        self.service.executeQuery(query) { (ticket, result, error) in
            onCompleted(result as? GTLRDrive_FileList, error)
        }
    }
    
    public func download(_ fileItem: GTLRDrive_File, onCompleted: @escaping (Data?, Error?) -> ()) {
        guard let fileID = fileItem.identifier else {
            return onCompleted(nil, nil)
        }
        
        self.service.executeQuery(GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileID)) { (ticket, file, error) in
            guard let data = (file as? GTLRDataObject)?.data else {
                return onCompleted(nil, nil)
            }
            
            onCompleted(data, nil)
        }
    }
}

//    MARK:- UITABLEVIEW DELEGATES & DATASOURCE(s)
extension GoogleDriveDataVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isDropboxScreen {
            return self.arrDropboxFiles.count
            
        } else {
            return self.arrGoogleDriveFiles.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoogleDriveTVCell", for: indexPath) as! GoogleDriveTVCell
        
        if self.isDropboxScreen {
            cell.dbFile = self.arrDropboxFiles[indexPath.row]
        } else {
            cell.gdFile = self.arrGoogleDriveFiles[indexPath.row]
        }
        cell.btnImportDocument.tag = indexPath.row
        cell.btnImportDocument.addTarget(self, action: #selector(importDocument), for: .touchUpInside)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableViewGoogleData.cellForRow(at: indexPath) as! GoogleDriveTVCell
        
        if cell.accessoryType == .disclosureIndicator {
            if self.isDropboxScreen {
                self.moveToFoldert(indexPath: indexPath)
                
            } else {
                let folderId = self.arrGoogleDriveFiles[indexPath.row].identifier!
                self.listFiles(folderId) { (files, err) in
                    var folderData = [GTLRDrive_File]()
                    if let filesList : GTLRDrive_FileList = files {
                        if let filesShow : [GTLRDrive_File] = filesList.files {
                            for Array in filesShow {
                                folderData.append(Array)
                            }
                        }
                    }
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "GoogleDriveDataVC") as! GoogleDriveDataVC
                    vc.arrGoogleDriveFiles = folderData
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
