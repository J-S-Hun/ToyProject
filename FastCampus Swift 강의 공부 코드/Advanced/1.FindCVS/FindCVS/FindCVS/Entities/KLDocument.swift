//
//  KLDocument.swift
//  FindCVS
//
//  Created by 전성훈 on 2022/11/11.
//

import Foundation

struct KLDocument: Decodable {
    let placeName: String
    let addressName : String
    let roadAddressName : String
    let x: String
    let y: String
    let distance : String
    
    enum CodingKeys: String, CodingKey {
        case x, y, distance
        case placeName = "place_name"
        case addressName = "address_name"
        case roadAddressName = "road_address_name"
    }
}
