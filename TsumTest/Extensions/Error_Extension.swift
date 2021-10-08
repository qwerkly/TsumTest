//
//  Error_Extension.swift
//  TsumTest
//
//  Created by Бабич Иван Юрьевич on 07.10.2021.
//

import UIKit
import Moya
import Alamofire

extension Error {
    func present(on controller: UIViewController? = UIApplication.topmostViewController(), completion: (() -> Void)? = nil) {
        Alert.present(error: self, on: controller, completion: completion)
    }
    
    var isOffline: Bool {
        if let moyaError = self as? MoyaError {
            if case let .underlying(error, _) = moyaError {
                if let afError = error.asAFError?.underlyingError {
                    let nsError = afError as NSError
                    return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorNotConnectedToInternet
                }
                let nsError = error as NSError
                return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorNotConnectedToInternet
            }
        }
        return false
    }
}

class Alert {
    static func present<T: Error>(
        error: T,
        on controller: UIViewController? = UIApplication.topmostViewController(),
        completion: (() -> Void)?
    ) {
        let title = "Ошибка"
        let text = !error.isOffline ? error.localizedDescription : "No internet connection"
        
        let alertVC = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alertVC.addAction(.init(title: "Понятно", style: .default) { _ in
            completion?()
        })
        
        controller?.present(alertVC, animated: true)
    }
}
