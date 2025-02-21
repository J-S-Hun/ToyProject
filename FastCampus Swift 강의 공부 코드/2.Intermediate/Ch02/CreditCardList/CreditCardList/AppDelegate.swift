//
//  AppDelegate.swift
//  CreditCardList
//
//  Created by 전성훈 on 2022/08/30.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift


@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        let db = Firestore.firestore()
        
        // db에 값이 있는지 없는지 확인해서 없으면 데이터 넣기
        db.collection("creditCardList").getDocuments {snapshot, _ in
            guard snapshot?.isEmpty == true else {return}
            let batch = db.batch()
            
            let card0Ref = db.collection("creditCardList").document("card0")
            let card1Ref = db.collection("creditCardList").document("card1")
            let card2Ref = db.collection("creditCardList").document("card2")
            let card3Ref = db.collection("creditCardList").document("card3")
            let card4Ref = db.collection("creditCardList").document("card4")
            let card5Ref = db.collection("creditCardList").document("card5")
            let card6Ref = db.collection("creditCardList").document("card6")
            let card7Ref = db.collection("creditCardList").document("card7")
            let card8Ref = db.collection("creditCardList").document("card8")
            let card9Ref = db.collection("creditCardList").document("card9")

            do {
                try batch.setData(from : CreditCardDummy.card0, forDocument: card0Ref)
                try batch.setData(from : CreditCardDummy.card1, forDocument: card1Ref)
                try batch.setData(from : CreditCardDummy.card2, forDocument: card2Ref)
                try batch.setData(from : CreditCardDummy.card3, forDocument: card3Ref)
                try batch.setData(from : CreditCardDummy.card4, forDocument: card4Ref)
                try batch.setData(from : CreditCardDummy.card5, forDocument: card5Ref)
                try batch.setData(from : CreditCardDummy.card6, forDocument: card6Ref)
                try batch.setData(from : CreditCardDummy.card7, forDocument: card7Ref)
                try batch.setData(from : CreditCardDummy.card8, forDocument: card8Ref)
                try batch.setData(from : CreditCardDummy.card9, forDocument: card9Ref)
            } catch let error {
                print("ERROR writng card to Firestore \(error.localizedDescription)")
            }
            
            batch.commit()
        }
        
        
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

