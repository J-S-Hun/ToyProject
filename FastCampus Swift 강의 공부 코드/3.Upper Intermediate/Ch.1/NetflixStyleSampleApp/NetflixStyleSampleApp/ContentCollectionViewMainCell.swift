//
//  ContentCollectionViewMainCell.swift
//  NetflixStyleSampleApp
//
//  Created by 전성훈 on 2022/09/04.
//

import UIKit

class ContentCollectionViewMainCell: UICollectionViewCell {
    let baseStackView = UIStackView()
    let menuStackView = UIStackView()
    
    // menuStackView Component
    let tvButton = UIButton()
    let movieButton = UIButton()
    let categoryButton = UIButton()
    
    // baseStackView Component
    let imageView = UIImageView()
    let descriptionLabel = UILabel()
    let contentStackView = UIStackView()
    
    // baseStackView Sub ContentStackView Component
    let plusButton = UIButton()
    let playButton = UIButton()
    let infoButton = UIButton()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        [baseStackView, menuStackView].forEach {
            contentView.addSubview($0)
        }
        
        // baseStackView
        baseStackView.axis = .vertical
        baseStackView.alignment = .center
        baseStackView.distribution = .fillProportionally
        baseStackView.spacing = 5
        
        [imageView,descriptionLabel,contentStackView].forEach {
            baseStackView.addArrangedSubview($0)
        }
        
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints {
            $0.width.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(imageView.snp.width)
        }
        
        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = .white
        descriptionLabel.sizeToFit()
        
        contentStackView.axis = .horizontal
        contentStackView.alignment = .center
        contentStackView.distribution = .fillEqually
        contentStackView.spacing = 20
        
        // contentStackView Sub Component
        [plusButton,infoButton].forEach {
            $0.titleLabel?.font = .systemFont(ofSize: 13)
            $0.setTitleColor(.white, for: .normal)
            $0.imageView?.tintColor = .white
            $0.adjustVerticalLayout(5)
        }
        
        plusButton.setTitle("내가 찜한 콘텐츠", for: .normal)
        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        
        infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        infoButton.setTitle("정보", for: .normal)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        
        playButton.setTitle("▸ 재생", for: .normal)
        playButton.setTitleColor(.black, for: .normal)
        playButton.backgroundColor = .white
        playButton.layer.cornerRadius = 3
        playButton.snp.makeConstraints {
            $0.width.equalTo(90)
            $0.height.equalTo(30)
        }
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        
        [plusButton,playButton,infoButton].forEach {
            contentStackView.addArrangedSubview($0)
        }
        
        contentStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(60)
        }
        
        baseStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // menuStackView
        menuStackView.axis = .horizontal
        menuStackView.alignment = .center
        menuStackView.distribution = .equalSpacing
        menuStackView.spacing = 20
        
        [tvButton,movieButton,categoryButton].forEach {
            menuStackView.addArrangedSubview($0)
            $0.setTitleColor(.white, for: .normal)
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 1
            $0.layer.shadowRadius = 3
        }
        
        tvButton.setTitle("TV 프로그램", for: .normal)
        movieButton.setTitle("영화", for: .normal)
        categoryButton.setTitle("카테고리 ▾", for: .normal)
        
        tvButton.addTarget(self, action: #selector(tvButtonTapped), for: .touchUpInside)
        movieButton.addTarget(self, action: #selector(movieButtonTapped), for: .touchUpInside)
        categoryButton.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)

        
        menuStackView.snp.makeConstraints {
            $0.top.equalTo(baseStackView)
            $0.leading.trailing.equalToSuperview().inset(30)
        }
        
    }
    
    @objc func tvButtonTapped(sender: UIButton!) {
        print("TEST: TV Button Tapped")
    }
    @objc func movieButtonTapped(sender: UIButton!) {
        print("TEST: Movie Button Tapped")
    }
    @objc func categoryButtonTapped(sender: UIButton!) {
        print("TEST: Category Button Tapped")
    }
    @objc func plusButtonTapped(sender: UIButton!) {
        print("TEST: Plus Button Tapped")
    }
    @objc func infoButtonTapped(sender: UIButton!) {
        print("TEST: Info Button Tapped")
    }
    @objc func playButtonTapped(sender: UIButton!) {
        print("TEST: Play Button Tapped")
    }
}
