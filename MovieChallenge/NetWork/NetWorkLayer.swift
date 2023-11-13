//
//  APIClient.swift
//  MovieChallenge
//
//  Created by Kevin on 12/9/22.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

enum ErrorDefine: Int, Error {
    case unAuthorized = 401
    case notFound = 404
}

class NetWorkLayer {
        
    func send<T: Codable>(url: URL) -> Observable<T> {
        let urlRq = URLRequest(url: url)
        return URLSession.shared.rx.data(request: urlRq)
            .map {
                try JSONDecoder().decode(T.self, from: $0)
            }
    }
    
    func send<T: Codable>(urlRequest: URLRequest) -> Observable<T> {
        return Observable.create { obs -> Disposable in
         let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
             guard (error == nil) else {return obs.onError(error ?? ErrorDefine.notFound)}
             if let data = data {
                 do {
                     guard let obj = try? JSONDecoder().decode(T.self, from: data)  else {return obs.onError(error ?? ErrorDefine.notFound)}
                     obs.onNext(obj)
                 }
             }
         }
         task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }

    func request<T: Codable> (url: URL) -> Observable<T> {
        let urlRq = URLRequest(url: url)
        return Observable.create { obs -> Disposable in
            let task = URLSession.shared.dataTask(with: urlRq) { data, response, error in
                guard (error == nil) else {return obs.onError(error ?? ErrorDefine.notFound)}
                if let data = data {
                    do {
                        guard let obj = try? JSONDecoder().decode(T.self, from: data)  else {return obs.onError(error ?? ErrorDefine.notFound)}
                        obs.onNext(obj)
                    }
                }
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
}


