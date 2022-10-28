//
//  CommonFunctions.swift
//  DemoApp
//
//  Created by XTRA on 14/10/22.
//

import UIKit

enum StoryBoardName:String {
    case main = "Main"
}

func findViewControllerIn(storyBoard:StoryBoardName , identifier: String?) -> UIViewController? {
    if let _ = identifier{
        return UIStoryboard(name: storyBoard.rawValue, bundle: Bundle.main).instantiateViewController(withIdentifier: identifier!)
    }
    else {
        return UIStoryboard(name: storyBoard.rawValue, bundle: Bundle.main).instantiateInitialViewController()
    }
}
