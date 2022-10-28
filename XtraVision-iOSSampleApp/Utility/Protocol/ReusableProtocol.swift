//
//  ReusableProtocol.swift
//  DemoApp
//
//  Created by XTRA on 14/10/22.
//

import Foundation

protocol ReusableProtocol {
    static var reusableIdentifier:String {
        get
    }
}

extension ReusableProtocol {
    static var reusableIdentifier:String {
        get {
            return "\(self)"
        }
    }
}
