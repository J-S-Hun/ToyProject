//
//  FeatureSectionCollectionViewCell.swift
//  AppStore
//
//  Created by 전성훈 on 2022/09/12.
//

import UIKit
import SnapKit
import Kingfisher

final class FeatureSectionCollectionViewCell : UICollectionViewCell {
    
    private lazy var typeLabel : UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.font = .systemFont(ofSize: 12.0, weight: .semibold)
        
        return label
    }()
    
    private lazy var appNameLabel : UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20.0, weight: .bold)
        
        return label
    }()
    
    private lazy var descriptionLabel : UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16.0, weight: .semibold)
        
        return label
    }()
    
    private lazy var imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 7.0
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.separator.cgColor
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    func setup(feature : Feature) {
        setupLayout()
        
        typeLabel.text = feature.type
        appNameLabel.text = feature.appName
        descriptionLabel.text = feature.description
        if let imageURL = URL(string: feature.imageURL) {
            imageView.kf.setImage(with: imageURL)
        }
    }
}

//MARK: Private method
private extension FeatureSectionCollectionViewCell {
    func setupLayout() {
        [
            typeLabel,
            appNameLabel,
            descriptionLabel,
            imageView
        ].forEach { addSubview($0) }
        
        typeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        appNameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(typeLabel.snp.bottom)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(appNameLabel.snp.bottom).offset(4.0)
        }
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(descriptionLabel.snp.bottom).offset(8.0)
            make.bottom.equalToSuperview().inset(8.0)
        }
    }
}
