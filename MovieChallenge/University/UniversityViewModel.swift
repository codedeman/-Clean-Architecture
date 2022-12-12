//
//  UniversityViewModel.swift
//  MovieChallenge
//
//  Created by Kevin on 12/12/22.
//

import Foundation
import RxSwift

protocol UniversityProtocol: AnyObject {
    func performSearch(apiRequest: APIRequest) -> Observable<[UniversityModel]>
}

class UniversityViewModel: NetWorkLayer, UniversityProtocol {
   
    func performSearch(apiRequest: APIRequest) -> Observable<[UniversityModel]> {
        let baseURL = URL(string: "http://universities.hipolabs.com/")!
        let request = apiRequest.request(with: baseURL)
        return super.send(urlRequest: request)
    }
    
}
