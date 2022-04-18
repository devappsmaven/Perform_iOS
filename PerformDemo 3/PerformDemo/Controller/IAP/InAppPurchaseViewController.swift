//
//  InAppPurchaseViewController.swift
//  GigHard_Swift
//
//  Created by osx on 02/12/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import StoreKit

//MARK:- ENUMS
enum FeaturesPurchased:String {
    case All
    case AudioVideo
    case SetLists
    case None
}

var features : FeaturesPurchased = .None

class InAppPurchaseViewController: UIViewController {
    
//    MARK:- IBOUTLET(S) AND VARIABLE(S)
    @IBOutlet weak var iAPTableView: UITableView!
    @IBOutlet weak var specialOffersBtn: UIButton!
    @IBOutlet weak var appPurchaseBtn: UIButton!
    
    var headerLabel:UILabel!
    var isOfferSelected = true
    var isPurchased =  UserDefaults.standard.bool(forKey:  "isPurchased")
    var noPurchases = "No purchases found. If you have previously made purchases which do not appear here, tap the Restore button to re-download them"
    var moduleSelected:Int = 0
    
    var products = [SKProduct]()
   
    
//    MARK:- VIEW LIFE CYCLE METHOD(S)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IAPHelper.sharedInstance.getProducts()
        
        
        self.iAPTableView.register(UINib(nibName: "InAppPuchaseTableViewCell", bundle: nil), forCellReuseIdentifier: "InAppPuchaseTableViewCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleAllProducts), name: .allProducts, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "timeOut"), object: nil)
    }
    
    //MARK:- OBJECTIVES METHODS
    @objc func handleAllProducts(noti: Notification) {
        if let dict = noti.object as? [String: Any]{
            self.products = dict["products"] as! [SKProduct]
        }
       
        DispatchQueue.main.async {
            self.iAPTableView.reloadData()
        }
        
    }
    
    //    MARK:- IBACTIONS(S)
    @IBAction func doneBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func myPurchasesAction(_ sender: UIButton) {
     
    }
    
    @IBAction func restoreAction(_ sender: UIButton) {
    
        IAPHelper.sharedInstance.restorePurchase()
        
    }
    
    @IBAction func offersAction(_ sender: UIButton) {
       
    }
    
    @objc func callPurchasingMethod(_ sender: UIButton) {
        IAPHelper.sharedInstance.purchase(product: self.products[sender.tag])
    }
}

//    MARK:- UITABLEVIEW DATASURCE AND DELEGATE METHODS(S)
extension InAppPurchaseViewController:UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = iAPTableView.dequeueReusableCell(withIdentifier: "InAppPuchaseTableViewCell", for: indexPath) as! InAppPuchaseTableViewCell
        
        let product = products[indexPath.row]
        
        cell.iapLabel.text = product.localizedTitle + " " + product.localizedDescription
        
        cell.buyBtn.setTitle("\(product.priceLocale.currencySymbol ?? "")\(product.price)", for: .normal)
        
        
        cell.buyBtn.tag = indexPath.row
        cell.buyBtn.addTarget(self, action: #selector(self.callPurchasingMethod(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.iAPTableView.frame.size.width, height: 80))
        headerLabel = UILabel(frame: CGRect(x: 0, y: (headerView.frame.size.height - 60) / 2.0, width: headerView.frame.size.width, height: 60))
        
        headerLabel.font = UIFont.boldSystemFont(ofSize: 34)
        
        if isOfferSelected {
            headerLabel.text = "Special Offers"
        } else {
            headerLabel.text = "My Purchases"
        }
        
        headerLabel.textColor = UIColor.darkGray
        headerLabel.textAlignment = .center
        headerView.backgroundColor = .clear
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80.0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.moduleSelected = indexPath.row
    }
    
}

