### 주제:  FastCampus 강의 + tag 추가 삭제 기능 구현
---
### 메모: 
> 간단해보이는 로직 구현에도 충분한 연습이 없다면 깨끗하게 구현하기 힘들다는 것을 몸소 느낌
#### 기존 FastCampus 강의
- TTGTagCollectionView 외부 라이브러리 사용 
    - UITableViewHeaderFooterView에 구현
- WKWebView를 활용한 WebView 구현
    - UIpasteboard.general.string 를 통해 link copy 
    - **Q:** WKWebView활용 간 **Security code** `This method should not be called on the main thread as it may lead to UI unresponsiveness.` 해결해야하는 것인가?? 
    - **Q:** WKWebView가 main thread에서 작동을 안하기때문에 발생하는 것??
- Naver News 검색 API 기능 구현
    - News Request Model  
    - News Response Model 
    - News Search Manager 구현 
        - Manager는 protocol를 활용하여 구현 -> 향후 test 작업간 mock 생성을 위해
        - Alamofire 외부 라이브러리 활용
    ```  swift
    import Foundation
    
    import Alamofire
    
    protocol NewsSearchManagerProtocol {
        func request(
            from keyword: String,
            start: Int,
            display: Int,
            completionHandler: @escaping ([News]) -> Void
        )
    }
    
    struct NewsSearchManager: NewsSearchManagerProtocol {
        func request(
            from keyword: String,
            start: Int,
            display: Int,
            completionHandler: @escaping ([News]) -> Void
        ) {
            guard let url = URL(string: "https://openapi.naver.com/v1/search/news.json") else {return}
            let parameters = NewsRequestModel(
                start: start,
                display: display,
                query: keyword
            )
            let headers: HTTPHeaders = [
                "X-Naver-Client-Id": "ie04mHhHFUiO1i9Pzzgw",
                "X-Naver-Client-Secret": "Nr6VZbR7ac"
            ]
            
            AF
                .request(url, method: .get, parameters: parameters, headers: headers)
                .responseDecodable(of: NewsResponseModel.self) { response in
                    switch response.result {
                    case .success(let result):
                        completionHandler(result.items)
                    case .failure(let error):
                        print(error)
                    }
                }
                .resume()
        }
    }
    ```
- pagination 기능 구현 
- **강의 내용 단점 및 버그** 
    1. Tag 키워드 변경 불가
    2. Tag클릭 시 기존 Tags에 Tags 추가되는 버그 발견
<p align="center">
  <img width="320" height="580" src="./1.png">
</p>
<p align="center">
  <img width="320" height="580" src="./2.png">
</p>
#### 추가 구현
- TagCollectionView 생성
    - flowLayout 설정 (자세히 공부 필요)
    - **Q:** Dynamic Cell 생성을 위해선 FlowLayout 설정?? 
    ``` swift
        private lazy var tagCollectionView: UICollectionView = {
           let layout = UICollectionViewFlowLayout()
            let inset: CGFloat = 16.0
            layout.estimatedItemSize = CGSize(width: 50, height: 50)
            layout.sectionInset = UIEdgeInsets(
                top: inset,
                left: inset*3,
                bottom: inset,
                right: inset*3
            )
            layout.minimumLineSpacing = inset
            
            let collectionView = UICollectionView(
                frame: .zero,
                collectionViewLayout: layout
            )
    
            collectionView.register(
                TagPlusCollectionViewCell.self,
                forCellWithReuseIdentifier: TagPlusCollectionViewCell.identifier
            )
            collectionView.delegate = presenter
            collectionView.dataSource = presenter
    
            return collectionView
        }()
    ```
    - UILabel padding 넣기
    ``` swift
    final class PaddingLabel: UILabel {

    private var padding = UIEdgeInsets(
        top: 6,
        left: 10,
        bottom: 6,
        right: 10
    )

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bott
        om
        contentSize.width += padding.left + padding.right
        return contentSize
    }
}
    ```
- 추가 버튼 생성 
    - Tag 삭제 버튼 클릭시 비활성화 구현
    - 추가 버튼 클릭시 AlertController 구현
        - 빈 값, cancel 클릭 시 값 반영 x 
        - 순환 참조 방지
- 선택 삭제 버튼 생성 
    - 선택 클릭시 '취소', 'Trash' 버튼 표시 및 변경 로직 구현
- **userDefaults로 데이터 연동**
    - **userDefaults Manager 구현** 
    ``` swift
    import Foundation
    
    protocol UserDefaultsManagerProtocol {
        func getTags() -> [Tags]
        func setTags(_ newValues: Tags)
       func deleteTags(_ values: [Tags])
    }
    
    struct UserDefaultsManager: UserDefaultsManagerProtocol {
        enum Key: String {
            case news
        }
        func getTags() -> [Tags] {
            guard let data = UserDefaults.standard.data(forKey: Key.news.rawValue) else {return [ ]}
            return (try? PropertyListDecoder().decode([Tags].self, from: data)) ?? []
        }
        func setTags(_ newValues: Tags) {
            var currentTags: [Tags] = getTags()
            currentTags.insert(newValues, at: 0)
            UserDefaults.standard.set(
                try? PropertyListEncoder().encode(currentTags), forKey: Key.news.rawValue)
        }
        func deleteTags(_ values: [Tags]) {
            let currentTags: [Tags] = getTags()
            let changeTags = currentTags.filter { !values.contains($0) }
            UserDefaults.standard.set(
                try? PropertyListEncoder().encode(changeTags), forKey: Key.news.rawValue)
        }
    }
         ```
    - **userDefaults 연동을 위한 (News/Tags)Presenter에 데이터 구현**
- **작은 버그들 수정** 
    1. 삭제 tag 선택 후 다시 해제 불가 해결
    2. tag 생성 시 빈 textfield임에도 불구하고 Ok시 빈 값으로 추가되는 버그 해결
    3. trash 버튼 클릭 시 추가 버튼 활성화 안됨 해결
<p align="center">
  <img width="320" height="580" src="./make.gif">
</p>
<p align="center">
  <img width="320" height="580" src="./delete.png">
</p>
