import Foundation

final class MovieViewModel: ObservableObject {

    @Published var searchTerm: String = ""
    @Published private(set) var result: [SearchModel] = []
    @Published private(set) var isSearching = false

    private var searchTask: Task<Void, Never>?

    @MainActor
    func executeQuery() async {
        searchTask?.cancel()

        let currentSearchTerm = searchTerm.trimmingCharacters(in: .whitespaces)
        if currentSearchTerm.isEmpty {
            result = []
            isSearching = false
            return
        }
        isSearching = true
        do {
            let searchResults = try await searchBooks(matching: currentSearchTerm)
            result = searchResults
            isSearching = false
        } catch {
            print("Error searching books: \(error)")
            isSearching = false
        }
    }

    private func searchBooks(matching searchTerm: String) async -> [SearchModel] {
        let escapedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let rootURL = "https://www.omdbapi.com/?s="
        let key = "&apikey=b831f50c"
        let urlString = rootURL + escapedSearchTerm + key

        guard let url = URL(string: urlString) else { return [] }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let searchResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
            guard let searchResults = searchResponse.Search else { return [] }
            return searchResults
        } catch {
            print("Error decoding search results: \(error)")
            return []
        }
    }
}
