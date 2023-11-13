import Foundation
import Combine
final class MovieViewModel: ObservableObject {

    @Published var searchTerm: String = ""
    @Published private(set) var result: [SearchModel] = []
    @Published private(set) var isSearching = false

    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    @MainActor

    init() {
        $searchTerm
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .handleEvents(receiveRequest: { _ in
                self.isSearching = true
            })
            .map { searchTerm -> AnyPublisher<[SearchModel], Never> in
                self.isSearching = true
                return  self.searchBooks(matching: searchTerm)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { movies in
                self.result = movies
            }
            .store(in: &cancellables)

    }


    private func searchBooks(matching searchTerm: String)  -> AnyPublisher<[SearchModel], Never> {
        let escapedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let rootURL = "https://www.omdbapi.com/?s="
        let key = "&apikey=b831f50c"
        let urlString = rootURL + escapedSearchTerm + key
        let url = URL(string: urlString)!
        return URLSession.shared.dataTaskPublisher(for: url)
          .map(\.data)
          .decode(type: MovieResponse.self, decoder: JSONDecoder())
          .map(\.Search)
          .replaceError(with: [SearchModel]())
          .eraseToAnyPublisher()
    }
}
