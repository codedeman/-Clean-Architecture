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
    func getRepo(_ repo: String) -> Single<[String: Any]>
    func getRepo2(_ repo: String) -> Maybe<[String: Any]>
}

class UniversityViewModel: NetWorkLayer, UniversityProtocol {
    func getRepo2(_ repo: String) -> RxSwift.Maybe<[String : Any]> {
        
        return Maybe<[String: Any]>.create { maybe in
            let task = URLSession.shared.dataTask(with: URL(string: "https://api.github.com/repos/\(repo)")!) { data, response, error in
                if let error = error {
                    maybe(.error(error))
                    return
                }
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves),
                      let result = json as? [String: Any] else {
                    return
                }
                maybe(.success(result))
            }
            task.resume()
          return  Disposables.create {task.cancel()}
        }
    }
    
    func getRepo(_ repo: String) -> RxSwift.Single<[String : Any]> {
        return Single<[String: Any]>.create { single in
            let task = URLSession.shared.dataTask(with: URL(string: "https://api.github.com/repos/\(repo)")!) { data, response, error in
                if let error = error {
                    single(.failure(error))
                    return
                }
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves),
                      let result = json as? [String: Any] else {
                    single(.failure(ErrorDefine.notFound))
                    return
                }
                single(.success(result))
            }
            task.resume()
            return Disposables.create {task.cancel()}
        }
    }
   
    func performSearch(apiRequest: APIRequest) -> Observable<[UniversityModel]> {
        let baseURL = URL(string: "http://universities.hipolabs.com/")!
        let request = apiRequest.request(with: baseURL)
        return super.send(urlRequest: request)
    }
    
}
