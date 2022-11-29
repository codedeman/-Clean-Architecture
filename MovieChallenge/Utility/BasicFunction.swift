//
//  BasicFunction.swift
//  MovieChallenge
//
//  Created by Kevin on 11/29/22.
//

import Foundation
import UIKit
typealias ClosureNormal = () -> Void


//func showPopup(complete: ClosureNormal? = nil) {
//    self.modalPresentationStyle = .overCurrentContext
//    
//    if let _ = topViewController() as? SLAlertViewController {
//        return
//    }
//    
//    if let _ = topViewController() as? UIAlertController {
//        return
//    }
//    
//    topViewController()?.present(self, animated: false, completion: complete)
//}
//
//
//func topViewController() -> UIViewController? {
//    let keyWindows = UIApplication.shared.windows.filter {$0.isKeyWindow}
//    if let keyWindow = keyWindows.first {
//        if var topController = keyWindow.rootViewController {
//            while let presentedViewController = topController.presentedViewController {
//                topController = presentedViewController
//            }
//            return topController
//        }
//        return nil
//    }
//    return nil
//}


