//
//  MenuViewModel.swift
//  RxSwift4HFinal
//
//  Created by 전성훈 on 2023/04/22.
//

import Foundation

import RxSwift
import RxCocoa

protocol MenuViewModelType {
    // ViewModel -> View
    var menus: BehaviorRelay<[ViewMenu]> { get }
    var totalCount: BehaviorRelay<String> { get }
    var totalPrice: BehaviorRelay<String> { get }
    var showOrderPage: Observable<[ViewMenu]> { get }
    var endRefreshControl: Observable<Bool> { get }

    
    // View -> ViewModel
    var increaseCount: AnyObserver<(ViewMenu,Int)> { get }
    var orderButtonTapped: AnyObserver<Void> { get }
    var clearButtonTapped: AnyObserver<Void> { get }
    var refreshControl: AnyObserver<Void> { get }

}

final class MenuViewModel: MenuViewModelType {
    let disposeBag = DisposeBag()
    
    var viewMenus: [ViewMenu] = []
    
    // ViewModel -> View
    var menus =  BehaviorRelay<[ViewMenu]>(value: [])
    var totalCount = BehaviorRelay<String>(value: "0")
    var totalPrice = BehaviorRelay<String>(value: "0")
    var showOrderPage: Observable<[ViewMenu]>
    var endRefreshControl: Observable<Bool>
    
    // View -> ViewModel
    var increaseCount: AnyObserver<(ViewMenu,Int)>
    var orderButtonTapped: AnyObserver<Void>
    var clearButtonTapped: AnyObserver<Void>
    var refreshControl: AnyObserver<Void>
    
    init() {
        let increasing = PublishSubject<(ViewMenu, Int)>()
        let orderingButton = PublishSubject<Void>()
        let clearingButton = PublishSubject<Void>()
        let refreshing = PublishSubject<Void>()
        
        increaseCount = increasing.asObserver()
    
        orderButtonTapped = orderingButton.asObserver()
            
        showOrderPage = orderingButton
            .withLatestFrom(menus)
            .map { $0.filter { $0.count > 0 } }
        
        refreshControl = refreshing.asObserver()
        
        endRefreshControl = refreshing
            .map { true }
            

        clearButtonTapped = clearingButton.asObserver()
      
        clearingButton
                    .withLatestFrom(menus)
                    .map { menus in
                        var menus = menus
                        menus.indices.forEach {
                            menus[$0].count = 0
                        }
                        self.viewMenus = menus
                        return self.viewMenus
                    }
                    .bind(to: menus)
                    .disposed(by: disposeBag)

        increasing
            .map({ (menus, int) in
                if let index = self.viewMenus.firstIndex(where: { $0.id == menus.id }) {
                    self.viewMenus[index].count += int
                    self.viewMenus[index].count = max(self.viewMenus[index].count, 0)
                }
            })
            .subscribe(onNext: { [weak self] _ in
                self?.menus.accept(self!.viewMenus)
            })
            .disposed(by: disposeBag)
            
        
        // Model 데이터 ViewModel로 불러오기
        APIService.fetchMenus { [weak self] menusData, err in
            if err != nil {
                return print("error")
            }
            guard menusData != nil else {
                return print("no data")
            }
            let viewMenus = menusData?.map { $0.asViewMenu() }
            
            self?.viewMenus = viewMenus!
            self?.menus.accept(viewMenus!)
        }
        
        menus
            .map { $0.map { $0.count }.reduce(0, +)}
            .map { "\($0)"}
            .bind(to: totalCount)
            .disposed(by: disposeBag)
                
        menus
            .map { $0.map { $0.count * $0.price}.reduce(0, +)}
            .map { $0.currencyKR() }
            .bind(to: totalPrice)
            .disposed(by: disposeBag)
        
    }
}
