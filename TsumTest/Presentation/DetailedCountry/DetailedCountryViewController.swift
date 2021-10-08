//
//  DetailedCountryViewController.swift
//  TsumTest
//
//  Created by Бабич Иван Юрьевич on 06.10.2021.
//

import UIKit
import RxSwift
import RxCocoa

final class DetailedCountryViewController: UIViewController {
    private lazy var activityIndicator = UIActivityIndicatorView(style: .large)
    
    private lazy var regionTitleLabel = UILabel()
    private lazy var regionLabel = UILabel()
    private lazy var callingPhoneDescLabel = UILabel()
    private lazy var callingCodesStackView = UIStackView()
    private lazy var capitalTitleLabel = UILabel()
    private lazy var capitalLabel = UILabel()
    
    private lazy var repeatButton = UIButton()
    
    private let viewModel: DetailedCountryViewModel
    
    private let disposeBag = DisposeBag()
    
    init(viewModel: DetailedCountryViewModel) {
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
        
        viewModel.fetchCountry()
    }
    
    private func addSubviews() {
        view.addSubview(activityIndicator)
        view.addSubview(regionTitleLabel)
        view.addSubview(regionLabel)
        view.addSubview(callingPhoneDescLabel)
        view.addSubview(callingCodesStackView)
        view.addSubview(capitalTitleLabel)
        view.addSubview(capitalLabel)
        view.addSubview(repeatButton)
    }
    
    private func layoutViews() {
        activityIndicator.snp.makeConstraints { $0.center.equalToSuperview() }
        
        regionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        regionLabel.snp.makeConstraints {
            $0.top.equalTo(regionTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(regionTitleLabel)
        }
        callingPhoneDescLabel.snp.makeConstraints {
            $0.top.equalTo(regionLabel.snp.bottom).offset(30)
            $0.leading.equalTo(regionLabel.snp.leading)
        }
        callingCodesStackView.snp.makeConstraints {
            $0.top.equalTo(callingPhoneDescLabel.snp.bottom).offset(8)
            $0.leading.equalTo(regionLabel.snp.leading)
        }
        capitalTitleLabel.snp.makeConstraints {
            $0.top.equalTo(callingCodesStackView.snp.bottom).offset(30)
            $0.leading.trailing.equalTo(regionTitleLabel)
        }
        capitalLabel.snp.makeConstraints {
            $0.top.equalTo(capitalTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(regionTitleLabel)
        }
        
        repeatButton.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .customBackground
        title = viewModel.country
        navigationController?.navigationBar.prefersLargeTitles = true
        
        activityIndicator.hidesWhenStopped = true
        
        capitalTitleLabel.text = "Capital"
        capitalTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        regionTitleLabel.text = "Region"
        regionTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        callingPhoneDescLabel.text = "Phone codes"
        callingPhoneDescLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        callingCodesStackView.axis = .vertical
        
        repeatButton.setTitle("Repeat", for: .normal)
        repeatButton.setTitleColor(.systemBlue, for: .normal)
        
        capitalTitleLabel.isHidden = true
        regionTitleLabel.isHidden = true
        callingPhoneDescLabel.isHidden = true
    }
    
    private func bind() {
        viewModel.loading
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.hideRepeat
            .bind(to: repeatButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        repeatButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.fetchCountry()
        })
        .disposed(by: disposeBag)
        
        viewModel.detailedCountry
            .subscribe(onNext: { [weak self] country in
                guard let self = self else { return }
                
                self.capitalTitleLabel.isHidden = country?.capital.isEmpty == true
                self.regionTitleLabel.isHidden = country?.region?.isEmpty == true
                self.callingPhoneDescLabel.isHidden = country?.callingCodes.isEmpty == true
                
                self.capitalLabel.text = country?.capital
                self.regionLabel.text = country?.region
                
                self.callingCodesStackView.arrangedSubviews.forEach {
                    self.callingCodesStackView.removeArrangedSubview($0)
                }
                
                country?.callingCodes.forEach {
                    let label = UILabel()
                    label.text = $0
                    self.callingCodesStackView.addArrangedSubview(label)
                }
            })
            .disposed(by: disposeBag)
    }
}
