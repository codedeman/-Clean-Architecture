//
//  ArticleModel.swift
//  MovieChallenge
//
//  Created by Kevin on 11/29/22.
//

import Foundation

struct MovieResponse: Codable {
    var Search: [SearchModel]?
    var totalResults: String?
    var Response: String?
    init (str: String) {
        self.Response = str
    }
}

struct SearchModel: Codable {
    var Title: String?
    var Year: String?
    var imdbID : String?
    var type: String?
    var Poster: String?
    
    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case Title
        case Poster
        case imdbID
        case Year
    }
}
