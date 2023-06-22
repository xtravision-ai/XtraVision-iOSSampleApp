//
//  UIViewExt.swift
//  XtraVision-iOSSampleApp
//
//  Created by XTRA on 13/06/23.
//

import UIKit

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable var cornerRadiusWithMask: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var makeItRound: Bool {
        get {
            return (layer.cornerRadius == self.frame.size.height/2)
        }
        set {
            layer.cornerRadius = self.frame.size.height/2
            layer.masksToBounds = true
        }
    }
}
