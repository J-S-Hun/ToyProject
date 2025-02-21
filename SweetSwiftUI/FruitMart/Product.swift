//
//  Product.swift
//  FruitMart
//
//  Created by 전성훈 on 2023/06/03.
//  Copyright © 2023 Giftbot. All rights reserved.
//

import Foundation

struct Product: Decodable, Identifiable {
    var id: UUID = UUID()
    
    let name: String
    let imageName: String
    let price: Int
    let description: String
    var isFavorite: Bool = false
    
    enum CodingKeys: CodingKey {
        case name 
        case imageName
        case price
        case description
        case isFavorite
    }
}
