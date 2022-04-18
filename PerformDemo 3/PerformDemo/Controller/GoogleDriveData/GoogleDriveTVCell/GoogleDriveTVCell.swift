//
//  GoogleDriveTVCell.swift
//  PerformDemo
//
//  Created by mac on 22/11/21.
//

import UIKit
import GoogleAPIClientForREST
import SwiftyDropbox

class GoogleDriveTVCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnImportDocument: UIButton!
    
    var dbFile: Files.Metadata? {
        didSet {
            self.lblName.text = self.dbFile?.name ?? ""
            
            if self.dbFile is Files.FolderMetadata {
                self.accessoryType = .disclosureIndicator
                self.btnImportDocument.isHidden = true
                
            } else {
                if let fileName = dbFile?.name {
                    if fileName.hasSuffix(".pdf") {
                        self.btnImportDocument.isHidden = false
                    } else {
                        self.btnImportDocument.isHidden = true
                    }
                }
            }
            
        }
    }
    
    var gdFile: GTLRDrive_File? {
        didSet {
            self.lblName.text = self.gdFile?.name ?? ""
            if (gdFile?.mimeType as NSString?)?.pathExtension == "folder" {
                self.accessoryType = .disclosureIndicator
                self.btnImportDocument.isHidden = true
            } else {
                self.accessoryType = .none
                if let fileName = gdFile?.name {
                    if fileName.hasSuffix(".pdf") {
                        self.btnImportDocument.isHidden = false
                    } else {
                        self.btnImportDocument.isHidden = true
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
