//
//  IAPProduct.swift
//  PerformDemo
//
//  Created by mac on 13/01/22.
//

import Foundation


enum IAPProduct:String {
    case setlist = "com.dantevmoore.performsetlist"
    case pro = "com.dantevmoore.performpro"
}



extension Notification.Name {
    static let allProducts = Notification.Name(rawValue: "allProducts")
}
