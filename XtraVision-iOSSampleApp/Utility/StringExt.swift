//
//  StringExt.swift
//  DemoApp
//
//  Created by XTRA on 17/10/22.
//

import UIKit

extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}
