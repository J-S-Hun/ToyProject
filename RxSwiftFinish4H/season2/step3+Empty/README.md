### 날짜: 2023-04-14 16:56

### 주제:  RxSwift의 근본 강의
---
### 메모: 
#### Step 1) RxSwift에 대해서
###### 1단계
- 비동기 작업이 필요한 코드 예시
~~~ swift 
import RxSwift 
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class ViewController: UIViewController  {
    @IBOutlet var timerLabel: UILabel! 
    @IBOutlet var editView: UITextView!
    
    override func viewDidLoad() { 
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [waek self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }
    
    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) { 
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in 
            v?.isHidden = !s
            }, completion: { [weak self] _ in 
                self?.view.layoutIfNeeded()
            })
    }
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)
        let url = URL(string: MEMBER_LIST_URL)!
        let data = try! Data(contentsOf: url)
        let json = String(data: data, encoding: .utf8)
        self.editView.text = json
        self.setVisibleWithAnimation(self.activityIndicator, false)
    }
}
~~~
- 위 코드를 보면 코드를 실행하면 타이머가 실행되고 Load 버튼을 클릭 시 Json 파일을 다운 받아와서 ActivityIndicator를 실행하고 다운로드가 종료되면 json파일이 editView에 뿌려지고, ActivityIndicator 실행이 종료된다.
- 하지만 실행해보면 json 파일 다운로드 받는 곳이 Main Thread에서 실행되기 때문에 json을 파일 받는 동안 타이머는 실행되지 않고, ActivityIndicator 또한 실행되지 않는다. 
- 그렇기 때문에 json파일을 다운로드 받는 행위를 비동기로 실행시켜서 UI관련 작업에 차질이 없게 실행해야 한다.
###### 2단계
~~~ swift 
    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)
         DispatchQueue.global().async { 
                let url = URL(string: MEMBER_LIST_URL)!
                let data = try! Data(contentsOf: url)
                let json = String(data: data, encoding: .utf8)
                DispatchQueue.main.async { 
                    self.editView.text = json 
                    self.setVisibleWithAnimation(self.activityIndicator, false)
                }
         }
    }
}
~~~
- 위와 같이 dispatchQueue를 활용하여 json을 받는 작업을 다른 thread에서 실행하게 하고 json을 받았을 때 UI를 변경시키는 작업은 main thread에서 실행하게 해서 위에 문제를 해결한다.
- 하지만 위와 같이 실행 할 경우, 코드가 많이 복잡해질수 있으며  button 함수 내부에 dispatchQueue를 넣는 것 보다 dispatchQueue 작업만 따로 빼서 함수로 만드는 것이 더 가독성이 좋다. 
###### 3단계
~~~ swift 
func downloadJSON(_ url: String, _ completion: @escaping (String?) -> Void) -> { 
    DispatchQueue.global().async { 
        let url = URL(string: url)!
        let data = try! Data(contentsOf: url)
        let json = String(data: data, encoding: .utf8)
        DispatchQueue.main.async { 
            completion(json)
        }
    }
}

@IBAction func onLoad() { 
    editView.text = ""
    self.setVisibleWithAnimation(activityIndicator, true)
    
    self.downloadJSON(MEMBER_LIST_URL) { json in 
        self.editView.text = json
        self.setVisibleWithAnimation(self.activityIndicator, false)
    }
}
~~~
- 위와 같이 다른 thread에서 작업하는 활동을 함수로 만들어서 실행하면 가독성이 좋은 코드가 될 수 있다. 
- 하지만 여기서 문제가 발생한다. 
- 위의 작업을 여러번 작동하게 하려면
~~~ swift 
@IBAction func onLoad() { 
    editView.text = ""
    self.setVisibleWithAnimation(activityIndicator, true)
    
    self.downloadJSON(MEMBER_LIST_URL) { json in 
        self.editView.text = json
        self.setVisibleWithAnimation(self.activityIndicator, false)
            
            self.downloadJSON(MEMBER_LIST_URL) { json in 
                self.editView.text = json
                self.setVisibleWithAnimation(self.activityIndicator, false)
            }
            
                self.downloadJSON(MEMBER_LIST_URL) { json in 
                    self.editView.text = json
                    self.setVisibleWithAnimation(self.activityIndicator, false)
                }
        }
}
~~~
- 위와 같이 클로저 안에 클로저 클로저 안에 클로저의 형식으로 코드를 작성해야 한다. 
- 즉, 다른 Thread에서 작업하는 활동을 클로저로 반환하는 것이 아니라 return 값으로 반환하는 작업이 필요하다.
- 다른 Thread에서 작업해서 생긴 Data를 나중에 생기는 데이터에 넣고, 그 데이터를 나중에 사용하면 해결할 수 있다. 
###### 4단계
~~~ swift
import RxSwift 
import SwiftyJSON
import UIKit

// 나중에 생기는 데이터 
class 나중에생기는데이터<T> { 
    private let task: (@escaping (T) -> Void) -> Void
    
    init(task: @escaping (@escaping (T) -> Void) -> Void) { 
        self.task = task
    }
    
    func 나중에오면(_ f: @escaping (T) -> Void) { 
        task(f)
    }
}
let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class ViewController: UIViewController  {
    @IBOutlet var timerLabel: UILabel! 
    @IBOutlet var editView: UITextView!
    
    override func viewDidLoad() { 
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [waek self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }
    
    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) { 
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in 
            v?.isHidden = !s
            }, completion: { [weak self] _ in 
                self?.view.layoutIfNeeded()
            })
    }
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    func downloadJSON(_ url: String) -> 나중에생기는데이터<String?>  { 
        return 나중에생기는데이터() { f in 
            DispatchQueue.global().async { 
                let url = URL(string: url)!
                let data = try! Data(contentsOf: url)
                let json = String(data: data, encoding: .utf8)
                
                DispatchQueue.main.async { 
                    f(json)
                }
            }
        }
    }
    
    @IBAction func onLoad() { 
        editView.text = ""
        self.setVisibleWithAnimation(activityIndicator, true)
        
        let json: 나중에생기는데이터<String?> = downloadJSON(MEMBER_LIST_URL)
        json.나중에오면 { [weak self] json in 
            self?.editView.text = json
            self?.setVisibleWithAnimation(self?.activityIndicator, false)
        }
    }
}
~~~
- 위와 같이 클로저 형식이 아닌 return 값으로 처리할 수 있다. 
- 위와 같이 작업하는 것이 바로 RxSwift이다. 
- **RxSwift는 비동기 데이터를 completion handler로 전달하는 것이 아니라 return 값을 전달하기 위해 만들어진 유틸리티이다.**
~~~ swift 
import RxSwift 
import SwiftyJSON
import UIKit

let disposeBag = DisposeBag()
let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class ViewController: UIViewController  {
    @IBOutlet var timerLabel: UILabel! 
    @IBOutlet var editView: UITextView!
    
    override func viewDidLoad() { 
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [waek self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }
    
    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) { 
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in 
            v?.isHidden = !s
            }, completion: { [weak self] _ in 
                self?.view.layoutIfNeeded()
            })
    }
    
    func downloadJson(_ url: String) -> Observable<String?> { 
        return Observable.create() { emitter in 
            let url = URL(string: url )!
            // * URLSession 자체가 다른 쓰레드에서 실행*
            let task = URLSession.shared.dataTask(with: url) { (data, _, err) in 
                guard err == nil else { 
                    emitter.onError(err!)
                    return
                }
                if let data = data, let json = String(data: data, encoding: .utf8) { 
                    emitter.onNext(json)
                }
                
                emitter.onCompleted()
            }
            
            task.resume() 
            
            return Disposables.create() { 
                task.cancel()
            }
        }    
    }
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func onLoad() { 
        editView.text = ""
        self.setVisibleWithAnimation(activityIndicator, true)
        
        downloadJson(MEMBER_LIST_URL)
            .subscribe { event in 
                switch event { 
                    case .next(let json): 
                        DispatchQueue.main.async { 
                            self.editView.text = json 
                            self.setVisibleWithAnimation(self.activityIndicator, false)
                        }
                    case .completed: 
                    case .error(_): 
                    
                }
            }
    }
}
~~~
- 위 코드를 확인해보면 subscribe 내부 next안에 'weak self'처리를 하지 않을 것을 볼 수 있다.
    - subscribe에서 weak self 없이 순환참조를 막을 수 있는 방법이 있는데,  closure가 발생하면 reference count가 증가 하고 closure가 없어지면 reference count가 감소 하는 것을 활용하면 되느데, Observable이 .completed되거나 .error가 발생하면 closure가 없어지니 reference count가 감소한다. 
    - 즉, Observable을 만들 때 completed 되게 만들면 weak self를 안 만들어줘도 된다. 하지만 코드 위험성 방지 측면에서 weak self 해주는 게 좋을 것 같다.
 - subscribe 내부 onNext DispatchQueue.main.async{ }를 외부에서 처리하는 방법이 있다. 
~~~ swift
 downloadJson(MEMBER_LIST_URL)
     .observeOn(MainScheduler.instance)
     .subscribe(onNext: { json in 
         self.editView.text = json 
         self.setVisibleWithAnimation(self.activityIndicator, false)
     }) 
~~~
- 위와 같이 Observable된 데이터를 subscribe해줘서 데이터를 처리하거나, 
- 다른 쓰레드에서 작업하는 데이터를 observeOn(MainScheduler.instance)를 활용하여 Main Thread에서 실행 시켜주는 것을 **operator**라고 한다.
    - map, filter 등 관련 operator도 사용 가능하다. 
#### Step 2) RxSwift + MVVM을 활용한 앱 예제
!(test)[https://github.com/Jeon0976/TIL/blob/main/SubFile/스크린샷%20보관함/Simulator%20Screen%20Shot%20-%20iPhone%2014%20Pro%20-%202023-04-20%20at%2013.18.42.png]!(test2)[https://github.com/Jeon0976/TIL/blob/main/SubFile/스크린샷%20보관함/Simulator%20Screen%20Shot%20-%20iPhone%2014%20Pro%20-%202023-04-20%20at%2013.18.46.png]
- MenuViewController
~~~ swift 
import UIKit
import RxSwift 
import RxCocoa

class MenuViewController: UIViewController { 
    let cellID = "MenuItemTableViewCell"
    
    let viewModel = MenuListViewModel() 
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() { 
        super.viewDidLoad()
        // 1
        viewModel.menuObservable
            .bind(to: tableView.rx.items(cellIdentifier: cellID, cellType: MenuItemTableViewCell.self)) { index, item, cell in 
                cell.title.text = item.name
                cell.price.text = "\(item.price)"
                cell.count.text = "\(item.count)"
                // 2
                cell.onChange = { [weak self] increase in 
                    self?.viewModel.changeCount(item, increase)
                }
            }
            .disposed(by: disposeBag)
        // 3
        viewModel.itemsCount
            .map { "\($0)"}
            .catchErrorJustReturn("")
            .observeOn(MainScheduler.instance)
            .bind(to: itemCountLabel.rx.text)
        // 4
        viewModel.totalPrice
            .asDriver(onErrorJustReturn: 0)
            .map { $0.currencyKR() }
            .drive(totalPrice.rx.text)
            .disposed(by: disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any? ) { 
        let identifier = segue.identifier ?? "" 
        if identifier == "OrderViewController", 
            let selectedMenus = sender as? [Menu],
            let orderVC = segue.destination as? OrderViewController { 
                orderVC.selectedMenus = selectedMenus
            }
    }
    
    func showAlert(_ title: String, _ message: String) { 
        let alretVC = UIAertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default ))
        present(alertVC, animated: true, completion: nil)
    }
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var itemCountLabel: UILabel!
    @IBOutlet var totalPrice: UILabel!
    
    // 5 
    @IBAction func onClear() {
        viewModel.clearAllItemSelections()
    }
    // 6
    @IBAction func onOrder(_ sender: UIButton) {
        let selectedMenus = viewModel.onOrder()
         performSegue(withIdentifier: "OrderViewController", sender: selectedMenus)
    }
}
~~~
- MenuViewModel
~~~ swift 
import Foundation
import RxSwift 
import RxCocoa

class MenuListViewModel { 
    let disposeBag = DisposeBag()
    
    var menus:[Menu] = []
    
    // 1
    var menuObservable = BehaviorRelay<[Menu]>(value: [])
    // 3 
    lazy var itemsCount = menuObservable.map { 
        $0.map { $0.count }.reduce(0, +)
    }     
    // 4 
    lazy var totalPrice = menuObservable.map { 
        $0.map { $0.price * $0.count }.reduce(0, +)
    }
    
    init () { 
        let menus = APIService.fetchAllMenusRx()
            .map { data in 
                struct Response: Decodable { 
                    let menus: [MenuItem]
                }
                let response = try! JSONDecoder().decode(Response.self, from: data)
                
                return response.menus
            }
            .map { menuItems in 
                menuItems.map { Menu.fromMenuItems(item: $0) }
            }
        menus.subscribe { menus in 
            self.menus = menus
            self.menuObservable.accept(self.meuns)
        }
        .disposed(by: disposeBag)
    }
    // 5
    func clearAllItemSelections() { 
        menus.indices.forEach { index in 
            menus[index].count = 0
        }
        menuObservable.accept(menus)
    }
    // 2 
    func changeCount(_ item: Menu, _ increase: Int) { 
        if let index = menus.firstIndex(where: {$0.id == item.id}) { 
            menus[index].count += increase
            menus[index].count = max(menus[index].count , 0)
        }
        menuObservable.accept(menus)
    }
    
    // 6
    func onOrder() -> [Menu] { 
        let selectedMenus = menus.filter {$0.count > 0 }
        
        return selectedMenus
    }
}
~~~
- MenuItemTableViewCell
~~~ swift 
import UIKit

class MenuItemTableViewCell: UITableViewCell {
    @IBOutlet var title: UILabel!
    @IBOutlet var count: UILabel!
    @IBOutlet var price: UILabel!
    
    // 2
    var onChange: ((Int) -> Void)?
    
    @IBAction func onIncreaseCount() {
        onChange?(1)
    }

    @IBAction func onDecreaseCount() {
        onChange?(-1)

    }
}
~~~
- OrderViewController + ViewModel
~~~ swift 
import UIKit

class OrderViewController: UIViewController { 
    var selectedMenus: [Menu] = []
    
    override func viewDidLoad() { 
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) { 
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        
        let orderList = selectedMenus.map { "\($0.name) \($0.count)개"}.joined(separator: "\n")
        orderList.text = orderList
        
        let price = selectedMenus.map { $0.count * $0.price }.reduce(0, +)
        let vat = 100
        itemsPrice.text = String(price)
        vatPrice.text = String(vat)
        totalPrice.text = String(vat + price)
    }
    
    override func viewWillDisappear(_ animated: Bool) { 
        super.viewWilDisappear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) { 
        super.viewDidAppear(animated)
        updateTextViewHeight() 
    }
    
    func updateTextViewHeight() { 
        let text = ordersList.text ?? "" 
        let width = ordersList.bounds.width 
        let font = orderList.font ?? UIFont.systemFont(ofSize: 20)
        
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect, 
                                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)
        let height = boundingBox.height)
        
        orderListHeight.constant = height + 40
    }
    
    @IBOutlet var ordersList: UITextView!
    @IBOutlet var ordersListHeight: NSLayoutConstraint!
    @IBOutlet var itemsPrice: UILabel!
    @IBOutlet var vatPrice: UILabel!
    @IBOutlet var totalPrice: UILabel!
}
~~~
###### 1 
- menu struct data를 받는 menuObservable을 UI작업의 사용될 데이터이기 때문에 BehaviorRelay로 받는다. 여기서 초기값 빈값을 설정하고 init 함수에서 API service를 활용해서 데이터를 받아온다음 받아온 데이터를 access 해준다.
- viewController에서 menuObservable을 tableView cell 생성에 bind 해준다. 
###### 2
- ItemTableViewCell 내부에 onChange의 값이 들어올 때마다 선택된 item을 viewModel의 changeCount함수로 값을 보내준다.
- changeCount함수를 통해서 Menu값을 변경해주고 변경된 Menu값을 meunObservable의 access 해준다.
###### 3
- viewModel의 menuObservable의 값이 변할때마다 lazy var itemsCount 값을 변화시켜주고 
- itemsCount의 값을 ViewController에서 구독해준다.
- 이때 UI가 변화하기 때문에 error가 발생하면 안되서,
- catchErrorJustReturn("")을 통해 error 발생 시 반환될 값, observeOn(MainScheduler.instance) 를 통해 UI에 값을 반영 시키기 전에 Main Thread로 변형 시켜준다.
###### 4 
- viewModel의 menuObservable의 값이 변할때마다 lazy var totalPrice 값을 변화시켜주고 totalPrice의 값을 viewController에서 구독해준다.
- 위와 같은 작업을 할 때 쉽게 해줄수 있는 메서드가 있는데 이는 Driver이다. driver는 항상 메인 쓰레드에서 작동을 보장한다.
- asDriver를 통해 driver화 해주고 
- drive(totalPrice.rx.text) 를 통해 받아준다 driver를 받아준다.
###### 5
- viewModel 의 clear 함수를 호출한다.
###### 6
- viewModel의 order 함수를 호출한다.

### 출처(참고문헌) 
- https://www.youtube.com/watch?v=iHKBNYMWd5I&t=3328s
- https://reactivex.io/documentation/operators/observeon.html

### 연결문서 
- [[-RxSwift]]
- [[- UIKit]]

### Tag
- #IOS/RxSwift 
- #IOS/Asynchronous 
