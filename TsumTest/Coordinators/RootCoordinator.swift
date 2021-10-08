//
//  RootCoordinator.swift
//  TsumTest
//
//  Created by Бабич Иван Юрьевич on 06.10.2021.
//

import UIKit
import RxSwift

final class RootCoordinator: BaseCoordinator<Void> {
    let window: UIWindow
    private let navigationController = UINavigationController()
    
    private let disposeBag = DisposeBag()
    
    init(window: UIWindow = UIWindow(frame: UIScreen.main.bounds)) {
        self.window = window
    }
    
    override func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        let viewModel: CountriesModuleOutput = CountriesViewModelImpl(repository: CountriesRepositoryImpl())
        let viewController = CountriesViewController(viewModel: viewModel as! CountriesViewModelImpl)
        
        viewModel.didSelectCountry
            .subscribe(onNext: { [unowned self] in
                let coordinator = DetailedCountryCoordinator(viewController: viewController, country: $0)
                coordinate(to: coordinator)
            })
            .disposed(by: disposeBag)
        
        navigationController.viewControllers = [viewController]
    }
}
