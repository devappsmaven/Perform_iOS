//
//  CoreDataManager.swift
//  PerformDemo
//
//  Created by mac on 18/11/21.
//

import Foundation
import CoreData
import UIKit


class CoreDataManager: NSObject {
    
//    MARK:- VARIABLES(s)
    static let sharedInstance = CoreDataManager()
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        
//    MARK: - Save Document
    func saveDocument(docDict: [String:Any], completionHendler: @escaping(_ success: Bool) -> Void) {
        let document = NSEntityDescription.insertNewObject(forEntityName: "Document", into: self.context!) as! Document
        
        document.docName = docDict["docName"] as? String
        document.docData = docDict["docData"] as? Data
        document.docPromptSize = docDict["docPromptSize"] as? Int16 ?? 24
        document.docPromptSpeed = docDict["docPromptSpeed"] as? Int16 ?? 1
        document.docId = self.getID() ?? 0
        
        do {
            self.context?.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
            try self.context?.save()
            completionHendler(true)
            print("saved")
        } catch let error {
            print("Saving error :- ",error)
            completionHendler(false)
        }
    }
    
    func getID() -> Int64? {
        
        let randomInt = Int.random(in: 1..<1000000)
        
        if let docs = self.fetchDocumentsWithoutCompletion() {
            for doc in docs {
                if doc.docId == randomInt {
                    _ = self.getID()
                    return nil
                }
            }
        }
        
        return Int64(randomInt)
    }

    //    MARK: - Fetch Documents
    func fetchDocuments(completionHandler: @escaping (_ documents: [Document]?, _ error: String?) -> Void) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Document")
        do {
            let documents = try context?.fetch(fetchRequest) as? [Document]
            completionHandler(documents,nil)
        } catch let error {
            completionHandler(nil,error.localizedDescription)
        }
    }
    
    func fetchDocumentsWithoutCompletion() -> [Document]? {
        var docs: [Document]?
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Document")
        do {
            docs = try context?.fetch(fetchRequest) as? [Document]
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        return docs
    }
    
    func getDocumentWithID(Id: Int64) -> Document? {
        if let docs = self.fetchDocumentsWithoutCompletion() {
            for doc in docs {
                if doc.docId == Id {
                    return doc
                }
            }
        }        
        return nil
    }
    
     //MARK: - Save SetList
    func saveSetList(docDict: [String:Any], completionHendler: @escaping(_ success: Bool) -> Void) {
        let document = NSEntityDescription.insertNewObject(forEntityName: "Setlist", into: self.context!) as! Setlist
        document.setName = docDict["setName"] as? String
        do {
            self.context?.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
            try self.context?.save()
            completionHendler(true)
            print("saved")
        } catch let error {
            print("Saving error :- ",error)
            completionHendler(false)
        }
    }

    
    // MARK: - Fetch SetList
    func fetchSetList(completionHandler: @escaping (_ documents: [Setlist]?, _ error: String?) -> Void) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Setlist")
        do {
            let setList = try context?.fetch(fetchRequest) as? [Setlist]
            completionHandler(setList,nil)
        } catch let error {
            completionHandler(nil,error.localizedDescription)
        }
    }
    
    // MARK: - Save DocSetRelation
    
    func saveDocSetRelation(setList: [Setlist],document:[Document], completionHendler: @escaping(_ success: Bool) -> Void) {
       
        let document = document
        
        for docSet in setList {
            let existingValues = docSet.docSetRel?.value(forKey: "document") as! NSSet
            let allSongsForGivenSet = existingValues.allObjects as! [Document]
            var sortIndex = allSongsForGivenSet.count
            for song in document {
                if !(allSongsForGivenSet.contains(song)){
                    let rel = NSEntityDescription.insertNewObject(forEntityName: "DocSetRelation", into: context!) as! DocSetRelation
                    rel.setlist = docSet
                    rel.document = song
                    rel.index = Int32(sortIndex)
                    sortIndex += 1
                } else {
                    print("Song already exists in the given set")
                }
            }
        }
        do {
            self.context?.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
            try self.context?.save()
            print("saved")
            completionHendler(true)
        } catch let error {
            print("Saving error :- ",error)
            completionHendler(false)
        }
    }
    func fetchDocSetRelation(completionHandler: @escaping (_ docSetRelation: [DocSetRelation]?, _ error: String?) -> Void) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DocSetRelation")
        do {
            let docSetRelation = try context?.fetch(fetchRequest) as? [DocSetRelation]
            completionHandler(docSetRelation,nil)
        } catch let error {
            completionHandler(nil,error.localizedDescription)
        }
    }
    
    func updateDocument(documnet: Document, docDict: [String:Any]) -> Document {
        let doc = documnet
        
        doc.docName = docDict["docName"] as? String
        doc.docData = docDict["docData"] as? Data
        doc.docPromptSize = docDict["docPromptSize"] as? Int16 ?? 24
        doc.docPromptSpeed = docDict["docPromptSpeed"] as? Int16 ?? 1
        doc.docId = doc.docId
        
        do {
            self.context!.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
            try self.context?.save()
            print("yes")
        } catch let error {
            print(error)
        }
        
        return doc
    }
    
    func updateSetList(setList : Setlist, docDict: [String:Any]) {
        
        let set = setList
        
        set.setName = docDict["setName"] as? String
        
        do {
            self.context!.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
            try self.context?.save()
            print("yes")
        } catch let error {
            print(error)
        }
        
    }
    
//    func updateDocumentSpeedSize(documnet:Document,docSize:Int16,docSpeed:Int16) -> Document {
//        documnet.docPromptSize = docSize
//        documnet.docPromptSpeed = docSpeed
//        do {
//            self.context?.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
//            try self.context?.save()
//            print("saved")
//        } catch let error {
//            print("Saving error :- ",error)
//        }
//        return documnet
//    }
    
    func saveRecording(document: Document, recData: Data, recStr: String, completionHandler: @escaping(_ success: Bool) -> Void) {
        
        let rec = NSEntityDescription.insertNewObject(forEntityName: "Recording", into: self.context!) as! Recording
        
        rec.recStr = recStr
        rec.recData = recData
        rec.document = document
        
        
        do {
            self.context!.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
            try self.context!.save()
            completionHandler(true)
            
        } catch let err {
            print(err.localizedDescription)
            completionHandler(true)
        }
    }
    
   
    
    func updateRecording(recording: Recording, recStr: String) {
        
        recording.recStr = recStr
        
        do {
            self.context!.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
            try self.context!.save()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func fetchRecordingsForSelectedSong(documentName: String) -> [Recording] {
        var selectedRecordings = [Recording]()
        var allRecordings = [Recording]()
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Recording")
            let sort = NSSortDescriptor(key: "recStr", ascending: true)
            fetchRequest.sortDescriptors = [sort]
            do {
                allRecordings = try self.context!.fetch(fetchRequest) as! [Recording]
            } catch let fetchError {
                print(fetchError.localizedDescription)
            }
            selectedRecordings.removeAll()
            for recording in allRecordings {
                let urlStr = recording.recStr!
                let url = URL(string: urlStr)
                let recName:String = url!.lastPathComponent
                let docRecording = "\(recName.prefix(documentName.count))"
                if docRecording == documentName {
                    selectedRecordings.append(recording)
                }
            }

         return selectedRecordings
    }
    
    func saveDefaultPdf() {
        
        let fileUrl = Bundle.main.url(forResource: "About Perform", withExtension: "pdf")
        print(fileUrl!)
        
        if let thePdfUrl = fileUrl {
            do {
                let data = try Data(contentsOf: thePdfUrl as URL)
                
                let  dictData = ["docName": "About Perform" , "docData": data ,"docPromptSize":24,"docPromptSpeed":1] as [String : Any]
                
                self.saveDocument(docDict: dictData) { success in
                  print("Pdf successfully saved")
                }
                
            } catch {
                print("Unable to load data: \(error)")
            }
        }
        
    }
    
}
