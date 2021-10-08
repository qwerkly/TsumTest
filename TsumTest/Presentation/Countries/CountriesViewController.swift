//
//  ViewController.swift
//  TsumTest
//
//  Created by Бабич Иван Юрьевич on 06.10.2021.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class CountriesViewController: UIViewController {
    private lazy var activityIndicator = UIActivityIndicatorView(style: .large)
    private lazy var tableView = UITableView()
    private lazy var refreshControl = UIRefreshControl()
    
    private let viewModel: CountriesViewModel
    
    private let disposeBag = DisposeBag()
    
    init(viewModel: CountriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
   
    required init?(coder: NSCoder) { return nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        layoutViews()
        setupViews()
        bind()
        
        viewModel.fetchCountries()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func addSubviews() {
        view.addSubview(activityIndicator)
        view.addSubview(tableView)
    }
    
    private func layoutViews() {
        activityIndicator.snp.makeConstraints { $0.center.equalToSuperview() }
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .customBackground
        
        tableView.register(CountryCell.self, forCellReuseIdentifier: "CountryCell")
        tableView.estimatedRowHeight = 80
        tableView.refreshControl = refreshControl
        tableView.isHidden = true
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }
    
    private func bind() {
        viewModel.loading
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.loading
            .bind(to: tableView.rx.isHidden)
            .disposed(by: disposeBag)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        refreshControl.rx
            .controlEvent(.valueChanged)
            .bind(to: viewModel.refresh)
            .disposed(by: disposeBag)
        
        viewModel.countries
            .bind(to: tableView.rx.items(cellIdentifier: "CountryCell", cellType: CountryCell.self)) { _, country, cell in
                cell.set(title: country.name, subtitle: country.capital)
            }
            .disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(Country.self)
            .map { $0.name }
            .bind(to: viewModel.selectCountry)
            .disposed(by: disposeBag)
        
        viewModel.endRefreshing
            .subscribe(onNext: { [unowned self] in
                refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate
extension CountriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 80 }
}
