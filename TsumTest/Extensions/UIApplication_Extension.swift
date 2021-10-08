//
//  UIApplication_Extension.swift
//  TsumTest
//
//  Created by Бабич Иван Юрьевич on 07.10.2021.
//

import UIKit

extension UIApplication {
    class func topmostViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topmostViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController, let selected = tabController.selectedViewController {
            return topmostViewController(controller: selected)
        }
        if let presented = controller?.presentedViewController {
            return topmostViewController(controller: presented)
        }
        return controller
    }
}
