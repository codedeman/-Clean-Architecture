//
//  MovieRequest.swift
//  MovieChallenge
//
//  Created by Kevin on 12/9/22.
//

import Foundation

class MovieRequest: APIRequest {
    var method = RequestType.GET
    var path = "search"
    var parameters = [String: String]()

    init(name: String) {
        parameters["name"] = name
        print("name \(name)")
    }
}
