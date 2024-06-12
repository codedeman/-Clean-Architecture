//
//  ContentView.swift
//  MovieChallengeSwiftUIVersion
//
//  Created by Kevin on 11/12/23.
//

import SwiftUI
import ShimmerLoading

struct ContentView: View {
    @StateObject var viewModel = MovieViewModel(network: NetworkALaMo())
    @Environment(\.dismiss) var dismiss

    var body: some View {

        NavigationView {
            List {
                if viewModel.isSearching {
                    // Show shimmer loading items
                    ForEach(0..<10, id: \.self) { _ in
                        ShimmerView(color: .gray,direction: .leftToRight) {
                            MovieRow(movie: .init())
                        }.frame(height: 100)
                    }
                } else {
                    // Show actual movie rows
                    ForEach(viewModel.result) { movie in
                        MovieRow(movie: movie)
                    }
                }
            }
            .navigationTitle("Search")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: { dismiss() }) {
                        Text("Done")
                    }
                }
            }
            .searchable(text: $viewModel.searchTerm)
        }
    }
}
