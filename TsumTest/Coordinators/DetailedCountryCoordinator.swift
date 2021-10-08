//
//  DetailedCountryCoordinator.swift
//  TsumTest
//
//  Created by Бабич Иван Юрьевич on 07.10.2021.
//

import UIKit
import RxCocoa
import RxSwift

final class DetailedCountryCoordinator: BaseCoordinator<Void> {
    private let viewController: UIViewController
    private let country: String
    
    private let disposeBag = DisposeBag()
    
    init(viewController: UIViewController, country: String) {
        self.viewController = viewController
        self.country = country
    }
    
    override func start() {
        let viewModel = DetailedCountryViewModelImpl(repository: CountriesRepositoryImpl(), country: country)
        let countryViewController = DetailedCountryViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: countryViewController)
        
        viewController.present(navigationController, animated: true)
    }
}
