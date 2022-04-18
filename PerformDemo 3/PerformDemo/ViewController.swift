//
//  ViewController.swift
//  PerformDemo
//
//  Created by mac on 17/11/21.
//

import UIKit
import CoreData


class ViewController: UIViewController {
   
    @IBOutlet weak var lblPlayListTitle: UILabel!
    @IBOutlet weak var btnPlayPlayList: UIButton!
    @IBOutlet weak var tableViewPlayList: UITableView!
    @IBOutlet weak var btnPerform: UIButton!
    @IBOutlet weak var btnSelectOutlet: UIButton!
    @IBOutlet weak var btnSelectAllOutlet: UIButton!
    @IBOutlet weak var btnRemoveOutlet: UIButton!
    @IBOutlet weak var btnCancelOutlet: UIButton!
    @IBOutlet weak var btnBackOutlet: UIButton!
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    
    
    var setList = Setlist()
    var arrDocument = [Document]()
    var arrSelectedDocument = [Document]()
    var selectedAllSongs = [Document]()
    var selectedRel = [DocSetRelation]()
    var searchSongs = [Document]()
    var isSelect:Bool? = false
    var isMove:Bool! = false
    var searchEnabled = Bool()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnPerform.isUserInteractionEnabled = false
        
        self.searchBarOutlet.delegate = self
        fetchDocSetRelation()
        setLayout()
        self.btnRemoveOutlet.isHidden = true
        self.btnSelectAllOutlet.isHidden = true
        self.btnCancelOutlet.isHidden = true
        self.isMove = true
        self.tableViewPlayList.reloadData()
    }
    
    func setLayout() {
        self.btnPlayPlayList.setTitle("Play Setlist - \(self.setList.setName ?? "")", for: .normal)
    }
    
    @IBAction func btnPerfromAction(_ sender: UIButton) {
//        if arrDocument.count != 0 {
//            let promptVC = self.storyboard?.instantiateViewController(withIdentifier: "PromptDocumentViewController") as! PromptDocumentViewController
//            promptVC.playlistName = self.setList.setName!
//            promptVC.playlistData = self.arrDocument
//            promptVC.isPerformPressed = true
//            self.navigationController?.pushViewController(promptVC, animated: true)
//        }
    }
    
    @IBAction func btnSelectAction(_ sender: UIButton) {
        if arrDocument.count > 0 {
            btnSelectOutlet.isHidden = true
            btnSelectAllOutlet.isHidden = false
            btnBackOutlet.isHidden = true
            btnCancelOutlet.isHidden = false
            self.tableViewPlayList.isEditing = false
            self.isMove = false
            if isSelect! {
                isSelect = false
            } else {
                isSelect = true
            }
            self.isSelect = true
            
            DispatchQueue.main.async {
                self.tableViewPlayList.reloadData()
            }
        } else {
            let alertController = UIAlertController(title: "Perform!", message: "Please Add document", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .destructive) { (alertAction) in
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnSelectAllAction(_ sender: UIButton) {
        btnRemoveOutlet.isHidden = false
        btnSelectAllOutlet.isHidden = true
        btnSelectOutlet.isHidden = true
        let selectRows = self.tableViewPlayList.numberOfRows(inSection: 0)
        for row in 0..<selectRows {
            self.tableViewPlayList.selectRow(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: .none)
        }
        self.arrSelectedDocument = self.arrDocument
    }
    
    func getSongs() {
        CoreDataManager.sharedInstance.fetchDocSetRelation { (docSetRel, error) in
            if error == nil {
                self.selectedRel = docSetRel!
            }
        }
        self.arrDocument.removeAll()
        for relation in self.selectedRel {
            if relation.setlist?.setName ==  setList.setName {
                if let document = relation.document {
                    arrDocument.append(document)
                }
            }
        }

        let orderedSet : NSOrderedSet = NSOrderedSet(array: self.arrDocument )
        self.arrDocument = orderedSet.array as! [Document]


        let arr = self.setList.fixedSortingIndexArray()
        self.arrDocument.removeAll()
        for doc in arr ?? [] {
            let docSetRel = doc as! DocSetRelation
            if let document = docSetRel.document {
                self.arrDocument.append(document)
            }

        }

        DispatchQueue.main.async {
            self.tableViewPlayList.reloadData()
        }

    }
    @IBAction func btnRemoveAction(_ sender: UIButton) {
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
        let alertController = UIAlertController(title: "Perform!", message: "Are you sure that you want to remove the selected songs.", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (alertAction) in
            DispatchQueue.main.async {

                
                self.selectedAllSongs = self.arrSelectedDocument
                for relatedSong in self.selectedAllSongs {
                    CoreDataManager.sharedInstance.fetchDocSetRelation(completionHandler: {(docset,error) in
                        if error == nil {
                            for index in 0..<docset!.count {
                                if docset?[index].document?.docName == relatedSong.docName {
                                    if docset?[index].setlist?.setName == self.setList.setName {
                                        self.selectedRel.append((docset?[index])!)
                                    }
                                }
                            }
                        }
                    })
                }
                
                
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DocSetRelation")
                let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
                
                fetchRequest.includesPropertyValues = false
                do {
                    for item in self.selectedRel {
                        managedObjectContext?.delete(item)
                    }
                    managedObjectContext!.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
                    try managedObjectContext?.save()
                } catch {
                }
                
                self.fetchDocSetRelation()
                
                self.isSelect = false
                self.isMove = true
                self.btnCancelOutlet.isHidden = true
                self.btnRemoveOutlet.isHidden = true
                self.btnSelectAllOutlet.isHidden = true
                self.btnBackOutlet.isHidden = false
                self.btnSelectOutlet.isHidden = false
                self.tableViewPlayList.isEditing = false
                self.selectedRel.removeAll()
                self.tableViewPlayList.reloadData()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCancelAction(_ sender: UIButton) {
        self.arrSelectedDocument.removeAll()
        self.selectedRel.removeAll()
        btnCancelOutlet.isHidden = true
        btnRemoveOutlet.isHidden = true
        btnSelectAllOutlet.isHidden = true
        btnSelectOutlet.isHidden = false
        btnBackOutlet.isHidden = false
        self.isSelect = false
        self.tableViewPlayList.isEditing = false
        self.tableViewPlayList.allowsMultipleSelectionDuringEditing = false
        DispatchQueue.main.async {
            self.tableViewPlayList.reloadData()
        }
    }
    
    func fetchDocSetRelation() {
        let existingValues = self.setList.docSetRel?.value(forKey: "document") as! NSSet
        self.arrDocument = existingValues.allObjects as! [Document]
        self.tableViewPlayList.reloadData()
    }
    
    func saveAtIndex() {
        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        let songsToBeAdded = self.arrDocument
        let existingValues = self.setList.docSetRel?.value(forKey: "document") as! NSSet
        var allSongsForGivenSet = existingValues.allObjects as! [Document]
        allSongsForGivenSet.removeAll()
        self.deleteAllSongs()
        var sortIndex = allSongsForGivenSet.count
        for song in songsToBeAdded {
            if !(allSongsForGivenSet.contains(song)){
                let rel = NSEntityDescription.insertNewObject(forEntityName: "DocSetRelation", into: context!) as! DocSetRelation
                rel.setlist = setList
                rel.document = song
                rel.index = Int32(sortIndex)

                song.addToDocSetRel(rel)
                setList.addToDocSetRel(rel)
                sortIndex += 1
            } else {
                print("Song already exists in the given set")
            }
        }
        do {
            context!.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
            try context?.save()
            print("Saved..")
            self.tableViewPlayList.reloadData()
        } catch let err {
            print(err.localizedDescription)
        }
    }
    
    
    func deleteAllSongs() {

        self.selectedAllSongs = self.arrDocument
        for relatedSong in self.selectedAllSongs {
            CoreDataManager.sharedInstance.fetchDocSetRelation(completionHandler: {(docset,error) in
                if error == nil {
                    for index in 0..<docset!.count {
                        if docset?[index].document?.docName == relatedSong.docName {
                            if docset?[index].setlist?.setName == self.setList.setName {
                                self.selectedRel.append((docset?[index])!)
                            }
                        }
                    }
                }
            })
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DocSetRelation")
        let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext

        fetchRequest.includesPropertyValues = false
        do {
            for item in self.selectedRel {
                managedObjectContext?.delete(item)
            }
            managedObjectContext!.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
            try managedObjectContext?.save()
        } catch {
        }
    }

    @IBAction func btnPlayPlayListAction(_ sender: UIButton) {
        
        if arrDocument.count != 0 {
            let promptVC = self.storyboard?.instantiateViewController(withIdentifier: "PromptDocumentViewController") as! PromptDocumentViewController
            promptVC.playlistName = self.setList.setName!
            promptVC.playlistData = self.arrDocument
            promptVC.isPerformPressed = true
            self.navigationController?.pushViewController(promptVC, animated: true)
        }
        
    }
    
}
extension ViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchEnabled {
            return searchSongs.count
        }
        else {
            return arrDocument.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableViewPlayList.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        if searchEnabled {
            cell.textLabel?.text = searchSongs[indexPath.row].docName
        } else {
            cell.textLabel?.text = arrDocument[indexPath.row].docName
        }
       
        if isSelect! {
            self.tableViewPlayList.isEditing = true
            self.tableViewPlayList.allowsMultipleSelectionDuringEditing = true
        }else if isMove{
            self.tableViewPlayList.isEditing = true
            self.tableViewPlayList.allowsMultipleSelectionDuringEditing = false
        }
        self.tableViewPlayList.isEditing = true
        self.tableViewPlayList.allowsSelectionDuringEditing = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSelect! {
            if searchEnabled {
                self.btnRemoveOutlet.isHidden = false
                
                if self.arrSelectedDocument.contains(self.searchSongs[indexPath.row]) {
                    self.arrSelectedDocument.removeAll { $0 as Document === self.arrDocument[indexPath.row] as Document }
                } else {
                    self.arrSelectedDocument.append(self.searchSongs[indexPath.row])
                }
            } else {
            self.btnRemoveOutlet.isHidden = false
            
            if self.arrSelectedDocument.contains(self.arrDocument[indexPath.row]) {
                self.arrSelectedDocument.removeAll { $0 as Document === self.arrDocument[indexPath.row] as Document }
            } else {
                self.arrSelectedDocument.append(self.arrDocument[indexPath.row])
            }
        }
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PromptDocumentViewController") as! PromptDocumentViewController
            vc.document = arrDocument[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if isSelect! {
            if self.arrSelectedDocument.contains(self.arrDocument[indexPath.row]) {
                self.arrSelectedDocument.removeAll { $0 as Document === self.arrDocument[indexPath.row] as Document }
            } else {
                self.arrSelectedDocument.append(self.arrDocument[indexPath.row])
            }
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if isMove {
        let itemToMove = arrDocument[sourceIndexPath.row]
        arrDocument.remove(at: sourceIndexPath.row)
        arrDocument.insert(itemToMove , at: destinationIndexPath.row)
        self.saveAtIndex()
        }
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
extension Setlist {
    func fixedSortingIndexArray() -> [AnyHashable]? {
        let array = fetchAllDocSetRelationsSorted(true)
        var arrayIndex = 0
        for obj in array {
            guard let obj = obj as? DocSetRelation else {
                continue
            }
            if obj.index != arrayIndex {
                obj.index = Int32(truncating: NSNumber(value: arrayIndex))
            }
            arrayIndex += 1
        }
        do {
        try (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext.save()
        } catch {
        }
        return array
        
    }
    func fetchAllDocSetRelationsSorted(_ sorted: Bool) -> [DocSetRelation] {
        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        var result = [DocSetRelation]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DocSetRelation")
      //  let predicate = NSPredicate(format: "docSet == %@", self)
       // fetchRequest.predicate = predicate
        if sorted {
            let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        do {
            result = try context!.fetch(fetchRequest) as! [DocSetRelation]
        } catch let fetchError {
            print(fetchError.localizedDescription)
        }
        return result
    }
}
extension ViewController: UISearchBarDelegate {
    func filterContent(forSearchText searchText: String) {
        self.searchSongs.removeAll()
        for document in self.arrDocument
        {
            let names = "\((document as AnyObject).value(forKey: "docName")!)"
            if((names).lowercased().contains(searchText.lowercased()))
            {
                searchSongs.append(document)
            }
            self.tableViewPlayList.reloadData()
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
            self.tableViewPlayList.reloadData()
        }
        else {
            searchEnabled = true
            filterContent(forSearchText: searchBar.text!)
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
        tableViewPlayList.reloadData()
    }
}

