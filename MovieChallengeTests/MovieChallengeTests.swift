//
//  MovieChallengeTests.swift
//  MovieChallengeTests
//
//  Created by Kevin on 11/29/22.
//

import XCTest
@testable import MovieChallenge

final class MovieChallengeTests: XCTestCase {
    var suit: MockMovieModelTest!
    
    override  func setUp() {
        super.setUp()
        self.suit = MockMovieModelTest(worker: MovieNetWork())
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        suit.performGetMovie(keyWord: "kevin")
        suit.listMovie.bind {  list  in
            XCTAssertTrue(!list.filter {$0.Title?.uppercased() == "kevin".uppercased()}.isEmpty)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}



class MockMovieModelTest: MovieModelWithoutRx {
    
    override func performGetMovie(keyWord: String) {
        let list = [SearchModel.init(Title: "Kevin",Type: "", Poster: "KKKK"),
                    SearchModel.init(Title: "Dat",Poster: "KKKK"),
                    SearchModel.init(Title: "Fa",Poster: "KKKK"),
                    SearchModel.init(Title: "Test",Poster: "KKKK")
        ]
        self.listMovie.value = list
    }
}
