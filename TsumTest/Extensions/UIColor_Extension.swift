//
//  UIColor_Extension.swift
//  TsumTest
//
//  Created by Бабич Иван Юрьевич on 07.10.2021.
//

import UIKit

extension UIColor {
    static var customBackground: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return .black
                } else {
                    return .white
                }
            }
        } else {
            return .white
        }
    }
}
