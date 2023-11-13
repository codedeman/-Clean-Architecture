//
//  ContentView.swift
//  MovieChallengeSwiftUIVersion
//
//  Created by Kevin on 11/12/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: MovieViewModel = .init()
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView(content: {
            VStack {

                if viewModel.isSearching {
                    ProgressView()
                } else {
                    List(viewModel.result) { movie in
                        MovieRow(movie: movie)
                    }
                }

            }
        }).navigationTitle("Search").toolbar(content: {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: { dismiss() }) {
                    Text("Done")
                }
            }
        }).searchable(text: $viewModel.searchTerm)

        .onReceive(viewModel.$result, perform: { _ in
            Task {
               await viewModel.executeQuery()
            }
        })

    }
}

struct BookSearchTaskCancellationView_Previews: PreviewProvider {
  static var previews: some View {
      ContentView(viewModel: MovieViewModel())
  }
}


