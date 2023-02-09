//
//  TabBarViewController.swift
//  TwitterClone
//
//  Created by 전성훈 on 2023/02/09.
//

import UIKit

class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBarViewControllers: [UIViewController] = TabBarItem.allCases
            .map { tabCase in
                let viewController = tabCase.viewController
                viewController.tabBarItem = UITabBarItem(
                    title: tabCase.title,
                    image: tabCase.icon.default,
                    selectedImage: tabCase.icon.selected
                )
                
                return viewController
            }
        self.viewControllers = tabBarViewControllers
    }
}

