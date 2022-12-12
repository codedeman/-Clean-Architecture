//
//  UniversityViewController.swift
//  MovieChallenge
//
//  Created by Kevin on 12/12/22.
//

import UIKit
import RxCocoa
import RxSwift

class UniversityViewController: UIViewController {

    private let disposeBag = DisposeBag()
    var viewModel = UniversityViewModel()
    private let tableView = UITableView()

    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search for university"
        return searchController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(MovieTableViewCell.nib, forCellReuseIdentifier: MovieTableViewCell.identifier)
        navigationItem.searchController = searchController
        navigationItem.title = "University finder"
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
        self.configureLayout()
        self.configureBinding()
        // Do any additional setup after loading the view.
    }

    private func configureLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.contentInset.bottom = view.safeAreaInsets.bottom
    }
    
    private func configureBinding() {
        searchController.searchBar.rx.text.orEmpty.throttle(.milliseconds(300), scheduler: MainScheduler.instance).asObservable().map {$0.lowercased()
            
        }.flatMapLatest { request -> Observable<[UniversityModel]> in
            if request.isEmpty {
                return .just([])
            } else {
                let rq = UniversityRequest(name: request)
                return self.viewModel.performSearch(apiRequest: rq).observe(on: MainScheduler.instance)
            }
        }.bind(to: tableView.rx.items) {(tableView, items, model) in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier) as? MovieTableViewCell else {return UITableViewCell()}
            print(Thread.isMainThread)
            cell.binding(data: model)
            return cell
        }.disposed(by: disposeBag)
        
    }
    
    deinit {
        print("viewmodel is delocate \(self.viewModel)")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
