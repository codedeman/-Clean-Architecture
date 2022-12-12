//
//  MovieViewModel.swift
//  MovieChallenge
//
//  Created by Kevin on 11/29/22.
//

import Foundation
import RxSwift
import RxCocoa

protocol MovieModelProtocol: AnyObject {
    func getlistMovie(keyworld: String) -> Observable <MovieResponse?>
}

class MovieModel: NetWorkLayer, MovieModelProtocol {
    
    func getlistMovie(keyworld: String) -> Observable<MovieResponse?> {
        let rootURl = "https://www.omdbapi.com/?s="
        let key = "&apikey=b831f50c"
        let urlStr = rootURl+"\(keyworld)"+key
        guard let url = URL(string: urlStr) else { return Observable.just(nil) }
        return super.request(url: url)
    }
    
}
