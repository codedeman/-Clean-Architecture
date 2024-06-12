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
                self.isSearching = false
            }
            .store(in: &cancellables)


    }

}




