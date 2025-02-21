//
//  Observable.swift
//  customReactiveProgramming
//
//  Created by 전성훈 on 2023/11/02.
//

import Foundation

enum ObservableEvent<Value> {
    case next(Value)
    case error(Error)
    case completed
}

class Observable<Value> {
    /// - observer : 실제 관찰자 객체
    /// - block: 값이 변경될 때 실행될 클로저를 저장
    struct Observer<Value> {
        weak var observer: AnyObject?
        let block: (ObservableEvent<Value>) -> Void
    }
    
    /// - 모든 observers를 저장하는 배열
    private var observers = [Observer<Value>]()
        
    /// - 실제 관찰되는 값
    /// - 값이 설정될 때마다 'didSet'에서 'notifyObservers' 메서드를 호출하여 모든 observer에게 알린다.
    var value: Value {
        didSet { notifyObservers(event: .next(value)) }
    }
    
    init(_ value: Value) {
        print("Observable Init")
        
        self.value = value
    }
    
    deinit {
        print("Observable Deinit")
        observers.removeAll()
    }
    
    /// observer를 추가한다. 추가될 때 현재 값에 대한 알림도 바로 전달한다.
    @discardableResult
    fileprivate func observe(
        on observer: AnyObject,
        observerBlock: @escaping (ObservableEvent<Value>) -> Void
    ) -> Observable<Value> {
        observers.append(Observer(observer: observer, block: observerBlock))
        observerBlock(.next(self.value))
        
        return self
    }
    
    /// 모든 observers에게 값을 알린다
    private func notifyObservers(event: ObservableEvent<Value>) {
        for observer in observers {
            observer.block(event)
        }
    }
    
    fileprivate func removeDisposable(for observer: AnyObject) -> () -> Void {
        return { [weak self] in
            self?.remove(observer: observer)
        }
    }
    
    /// 특정 observer를 제거한다
    private func remove(observer: AnyObject) {
        observers = observers.filter { $0.observer !== observer }
    }
    
    @discardableResult
    func subscribe(
        on observer: AnyObject,
        disposeBag: DisposeBag,
        onNext: ((Value) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil,
        onCompleted: (() -> Void)? = nil
    ) -> Subscription<Value> {
        
        return Subscription(
            observable: self,
            observer: observer,
            disposeBag: disposeBag,
            onNext: onNext,
            onError: onError,
            onCompleted: onCompleted
        )
    }
}

final class Subscription<Value> {
    
    private let observable: Observable<Value>
    private weak var observer: AnyObject?
    private let disposeBag: DisposeBag

    init(
           observable: Observable<Value>,
           observer: AnyObject,
           disposeBag: DisposeBag,
           onNext: ((Value) -> Void)? = nil,
           onError: ((Error) -> Void)? = nil,
           onCompleted: (() -> Void)? = nil
    ) {
        self.observable = observable
        self.observer = observer
        self.disposeBag = disposeBag
        
        if let onNext = onNext {
            self.onNext(onNext)
        }
        
        if let onError = onError {
            self.onError(onError)
        }
        
        if let onCompleted = onCompleted {
            self.onCompleted(onCompleted)
        }
        
        print("Subscription Init")
    }
    
    deinit {
        print("Subscription Deinit")
    }
    
    @discardableResult
    func onNext(_ onNext: @escaping (Value) -> Void) -> Self {
        guard let observer = observer else { return self }
        
        let disposable = observable.observe(on: observer) { event in
            if case .next(let value) = event {
                onNext(value)
            }
        }.removeDisposable(for: observer)
        
        disposeBag.add(disposable)
        return self
    }
    
    @discardableResult
     func onError(_ onError: @escaping (Error) -> Void) -> Self {
         guard let observer = observer else { return self }

         let disposable = observable.observe(on: observer) { event in
             if case .error(let error) = event {
                 onError(error)
             }
         }.removeDisposable(for: observer)
         
         disposeBag.add(disposable)
         return self
     }
     
     @discardableResult
     func onCompleted(_ onCompleted: @escaping () -> Void) -> Self {
         guard let observer = observer else { return self }

         let disposable = observable.observe(on: observer) { event in
             if case .completed = event {
                 onCompleted()
             }
         }.removeDisposable(for: observer)

         disposeBag.add(disposable)
         return self
     }
}
