//
//  StoreItem.swift
//  iTunesSearch
//
//  Created by Lore P on 05/11/2022.
//

import UIKit

struct StoreItem: Codable {
    let name: String
    let artist: String
    var kind: String
    
    var artworkURL: URL
    
    enum CodingKeys: String, CodingKey {
        case name = "trackName"
        case artist = "artistName"
        case kind
        
        case artworkURL = "artworkUrl100"
    }
}

struct SearchResponse: Codable {
    let results: [StoreItem]
}
