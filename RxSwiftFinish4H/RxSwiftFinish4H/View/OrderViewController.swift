//
//  OrderViewController.swift
//  RxSwiftFinish4H
//
//  Created by 전성훈 on 2023/04/19.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class OrderViewController :UIViewController {
    
    var viewModel: OrderViewModelType
    let disposeBag = DisposeBag()
    
    let scrollView = UIScrollView()
    
    let contentView = UIView()
    
    let titleOrdered = UILabel()
    let orderedItems = UITextView()
    let priceToPay = UILabel()
    let items = UILabel()
    let vat = UILabel()
    let itemsPrice = UILabel()
    let vatPrice = UILabel()
    let separator = UIView()
    let totalPrice = UILabel()
    
    var selectedMenus : [ViewMenu] = []
    
    init(viewModel: OrderViewModelType = OrderViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        attribute()
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        
    }
    
    func bind() {
        
    }
    
    // MARK: 초기 UI Attribute 설정
    private func attribute() {
        
        let price = selectedMenus.map { $0.count * $0.price}.reduce(0, +)
        let vatt = 100
        
        view.backgroundColor = .systemBackground
        
        navigationItem.title = "Receipt"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes =
        [.foregroundColor: UIColor.white]
        
        
        titleOrdered.text = "Ordered Items"
        titleOrdered.font = .systemFont(ofSize: 24, weight: .medium)
                
        orderedItems.isScrollEnabled = false
        orderedItems.text = selectedMenus.map { "\($0.name) \($0.count)개"}.joined(separator: "\n")
        orderedItems.sizeToFit()
        
        orderedItems.font = .systemFont(ofSize: 32, weight: .light)
        
        priceToPay.text = "Price to Pay"
        priceToPay.font = .systemFont(ofSize: 24, weight: .medium)
        
        items.text = "Items"
        items.font = .systemFont(ofSize: 32, weight: .light)
        
        vat.text = "VAT"
        vat.font = .systemFont(ofSize: 32, weight: .light)
        
        itemsPrice.text = String(price)
        itemsPrice.font = .systemFont(ofSize: 18, weight: .medium)
        
        vatPrice.text = String(vatt)
        vatPrice.font = .systemFont(ofSize: 18, weight: .medium)
        
        separator.backgroundColor = .black
        
        totalPrice.text = String(price + vatt)
        totalPrice.font = .systemFont(ofSize: 48, weight: .heavy)
    }

    // MARK: Layout 설정
    private func layout() {
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.top)
            $0.leading.equalTo(scrollView.snp.leading)
            $0.trailing.equalTo(scrollView.snp.trailing)
            $0.bottom.equalTo(scrollView.snp.bottom)
        }
        
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

        let contentViewHeight = contentView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor)

        contentViewHeight.priority = .defaultLow
        contentViewHeight.isActive = true
        
        [
            titleOrdered,
            orderedItems,
            priceToPay,
            items,
            vat,
            itemsPrice,
            vatPrice,
            separator,
            totalPrice
        ].forEach { contentView.addSubview($0) }
        
        titleOrdered.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top).inset(32.0)
            $0.leading.equalTo(contentView.snp.leading).inset(16.0)
        }
        
        orderedItems.snp.makeConstraints {
            $0.top.equalTo(titleOrdered.snp.bottom).offset(32.0)
            $0.leading.equalTo(contentView.snp.leading).inset(16.0)
            $0.trailing.equalTo(contentView.snp.trailing).inset(16.0)
        }

        priceToPay.snp.makeConstraints {
            $0.top.equalTo(orderedItems.snp.bottom).offset(16.0)
            $0.leading.equalTo(contentView.snp.leading).inset(16.0)
        }

        items.snp.makeConstraints {
            $0.top.equalTo(priceToPay.snp.bottom).offset(16.0)
            $0.leading.equalTo(contentView.snp.leading).inset(16.0)
        }

        vat.snp.makeConstraints {
            $0.top.equalTo(items.snp.bottom).offset(16.0)
            $0.leading.equalTo(contentView.snp.leading).inset(16.0)
        }

        itemsPrice.snp.makeConstraints {
            $0.top.equalTo(priceToPay.snp.bottom).offset(16.0)
            $0.trailing.equalTo(contentView.snp.trailing).inset(16.0)
        }

        vatPrice.snp.makeConstraints {
            $0.top.equalTo(items.snp.bottom).offset(16.0)
            $0.trailing.equalTo(contentView.snp.trailing).inset(16.0)
        }

        separator.snp.makeConstraints {
            $0.top.equalTo(vatPrice.snp.bottom).offset(32.0)
            $0.leading.equalTo(contentView.snp.leading ).inset(16.0)
            $0.trailing.equalTo(contentView.snp.trailing).inset(16.0)
            $0.height.equalTo(1)
        }

        totalPrice.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom).offset(32.0)
            $0.bottom.equalTo(contentView.snp.bottom).inset(16.0)
            $0.trailing.equalTo(contentView.snp.trailing).inset(16.0)
        }
    }
}

