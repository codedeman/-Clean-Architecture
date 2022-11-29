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
class APIClient {
        
        func send<T: Codable>(url:URL) -> Observable<T> {
            let urlRq = URLRequest(url: url)
            return URLSession.shared.rx.data(request: urlRq)
                .map {
                    try JSONDecoder().decode(T.self, from: $0)
                }
        }

       func request<T: Codable> (url: URL) -> Observable<T> {
           let urlRq = URLRequest(url: url)
           let request = URLRequest(url: URL(string: "sdf")!)
           return Observable.create { obs -> Disposable in
            let task = URLSession.shared.dataTask(with: urlRq) { data, response, error in
                guard (error == nil) else {return obs.onError(error ?? ErrorDefine.notFound)}
                if let data = data {
                    do {
                        guard let obj = try? JSONDecoder().decode(T.self, from: data) as? T else {return obs.onError(error ?? ErrorDefine.notFound)}
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





//return Observable.create { obs in
//       URLSession.shared.rx.response(request: request).debug("r").subscribe(
//           onNext: { response in
//               return obs.onNext(response.data)
//       },
//           onError: {error in
//               obs.onError(error)
//       })
//   }
