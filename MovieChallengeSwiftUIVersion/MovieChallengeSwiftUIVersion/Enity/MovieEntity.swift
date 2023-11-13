//
//  MovieEntity.swift
//  MovieChallengeSwiftUIVersion
//
//  Created by Kevin on 11/13/23.
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

struct SearchModel: Codable,Identifiable {
    var id = UUID()
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
    
    init(Title: String? = nil, Year: String? = nil, imdbID: String? = nil, type: String? = nil, Poster: String? = nil) {
        self.Title = Title
        self.Year = Year
        self.imdbID = imdbID
        self.type = type
        self.Poster = Poster
    }

    func convertStrtoURL() -> URL {
        return URL(string: Poster ?? "")!

    }

}
