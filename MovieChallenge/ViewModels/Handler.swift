//
//  Handler.swift
//  MovieChallenge
//
//  Created by Kevin on 11/29/22.
//

import Foundation
final class Handler<T> {
    typealias Listener = (T) -> Void
    var listener: Listener?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    init(_ value: T) {
        self.value = value
    }
    func bind(listenner: Listener?) {
        self.listener = listenner
        listenner?(value)
    }
}
