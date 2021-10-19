//
//  VideoDetails.swift
//  Action Theatre
//
//  Created by Rahul Anand on 08/10/21.
//

import Foundation

struct VideoDetails: Decodable {
    let description: String?
    let id: String?
    let thumb: String?
    let title: String?
    let url: String?
    
    private enum CodingKeys: String, CodingKey {
        case description = "description"
        case id = "id"
        case thumb = "thumb"
        case title = "title"
        case url = "url"
    }
}
