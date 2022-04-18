//
//  IAPHelper.swift
//  PerformDemo
//
//  Created by mac on 13/01/22.
//

import Foundation
import StoreKit

class IAPHelper: NSObject {
    
   static let sharedInstance = IAPHelper()
    
    var request: SKProductsRequest!
    
    let paymentQueue = SKPaymentQueue.default()
    
    func getProducts() {
        
        let products: Set = [IAPProduct.pro.rawValue,
                             IAPProduct.setlist.rawValue]
        self.request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
    }
    
    
    func purchase(product: SKProduct) {
        
        let payment = SKPayment(product: product)
        paymentQueue.add(payment)
    }
    
    
    func restorePurchase() {
        paymentQueue.restoreCompletedTransactions()
    }
    
}


extension IAPHelper: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let dict = ["products": response.products]
        NotificationCenter.default.post(name: .allProducts, object: dict as [String: Any])
    }
    
}

extension IAPHelper: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            
            switch transaction.transactionState {
            case .purchasing:
                print("purchasing....")
                
            case .purchased:
                print("purchased....")
                
            case .restored:
                print("restored....")
                
            case .failed:
                print("failed....")
                
            case .deferred :
                print("defered....")
                
            @unknown default:
                print("sdgsdfgfg")
            }
        }
    }
    
    
}
