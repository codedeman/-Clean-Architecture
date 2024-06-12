//
//  MyInitializableView.swift
//  MovieChallengeSwiftUIVersion
//
//  Created by Kevin on 6/11/24.
//

import Foundation
import SwiftUI

class DataModel: ObservableObject {
    @Published var name = "Some Name"
    @Published var isEnabled = false
    init(name: String = "Some Name", isEnabled: Bool = false) {
        self.name = name
        self.isEnabled = isEnabled
    }
}


struct MyView: View {
    @StateObject private var model: DataModel


    init(name: String) {
        // SwiftUI ensures that the following initialization uses the
        // closure only once during the lifetime of the view, so
        // later changes to the view's name input have no effect.
        _model = StateObject(wrappedValue: DataModel(name: name))
    }


    var body: some View {
        VStack {
            Text("Name: \(model.name)")
        }
    }
}

