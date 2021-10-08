//
//  CountryCell.swift
//  TsumTest
//
//  Created by Бабич Иван Юрьевич on 07.10.2021.
//

import UIKit
import SnapKit

final class CountryCell: UITableViewCell {
    private lazy var titleLabel = UILabel()
    private lazy var subtitleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        layoutViews()
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { return nil }
    
    private func addSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
    }
    
    private func layoutViews() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
    
    private func setupViews() {
        selectionStyle = .none
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        subtitleLabel.font = .systemFont(ofSize: 16)
    }
    
    func set(title: String, subtitle: String?) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
