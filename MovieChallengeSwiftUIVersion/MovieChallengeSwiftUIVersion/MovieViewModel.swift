import Foundation
import Combine
@MainActor
final class MovieViewModel: ObservableObject {

    @Published var searchTerm: String = ""
    @Published private(set) var result: [SearchModel] = []
    @Published private(set) var isSearching = false

    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    private var network: NetWorkLayerProtocol

    @MainActor

    init(network: NetWorkLayerProtocol) {
        self.network = network
        $searchTerm
            .debounce(for: 0.8, scheduler: DispatchQueue.main)
            .handleEvents(receiveRequest: { _ in
                self.isSearching = true
            })
            .map { searchTerm -> AnyPublisher<[SearchModel], Never> in
                return  self.network.searchBooks(matching: searchTerm)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { movies in
                self.result = movies
            }
            .store(in: &cancellables)


    }

//
//    private func searchBooks(matching searchTerm: String) -> AnyPublisher<[SearchModel], Never> {
//
//        let escapedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
//        let rootURL = "https://www.omdbapi.com/?s="
//        let key = "&apikey=b831f50c"
//        let urlString = rootURL + escapedSearchTerm + key
//        let url = URL(string: urlString)!
//        return URLSession.shared.dataTaskPublisher(for: url)
//          .map { ouput in
//              return ouput.data
//          }
//          .decode(type: MovieResponse.self, decoder: JSONDecoder())
//          .map(\.Search)
//          .replaceError(with: [SearchModel]())
//          .eraseToAnyPublisher()
//    }
}

//extension MovieViewModel: URLSessionDelegate {
//    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        if let trust = challenge.protectionSpace.serverTrust,
//           SecTrustGetCertificateCount(trust) > 0 {
//            if let certificate = SecTrustGetCertificateAtIndex(trust, 0) {
//                let data = SecCertificateCopyData(certificate) as Data
//
//                if certificates.contains(data) {
//                    completionHandler(.useCredential, URLCredential(trust: trust))
//                    return
//                } else {
//                    //TODO: Throw SSL Certificate Mismatch
//                }
//            }
//
//        }
//        completionHandler(.cancelAuthenticationChallenge, nil)
//
//    }




