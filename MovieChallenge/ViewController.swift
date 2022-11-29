//
//  ViewController.swift
//  MovieChallenge
//
//  Created by Kevin on 11/29/22.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    var listMovie: [SearchModel] = []
    private let disposeBag = DisposeBag()
    var viewModel = MovieModel()
    @IBOutlet weak var lblEmptyMessage: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarView: UISearchBar!
    @IBOutlet weak var lblResult: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setUpUI() {
        self.searchBarView.delegate = self
        self.tableView.backgroundColor = .clear
        tableView.register(MovieTableViewCell.nib, forCellReuseIdentifier: MovieTableViewCell.identifier)
        self.tableView.separatorColor = .clear
        self.tableView.estimatedRowHeight = 300
        self.tableView.rowHeight = UITableView.automaticDimension
        self.setUpViewModel()
    }
    
    private func setUpViewModel() {
        searchBarView.rx.text.orEmpty.throttle(.microseconds(300), scheduler: MainScheduler.instance).distinctUntilChanged().flatMapLatest { query -> Observable<MovieResponse?> in
            print("query \(query)")
            if query.isEmpty {
                return .just(nil)
            }
            return self.viewModel.getlistMovie(keyworld: query).observe(on: MainScheduler.instance)
        }.asObservable().map {$0?.Search ?? []
//            self.lblResult.rx.text = $0
        }.bind(to: tableView.rx.items) {(tableView, items, model) in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier) as? MovieTableViewCell else {return UITableViewCell()}
            print(Thread.isMainThread)
            cell.bindingData(data: model)
            return cell
        }.disposed(by: disposeBag)
        
    }
    
    private func showEmptyMessage() {
        self.tableView.isHidden = listMovie.isEmpty == true
        self.lblResult.text = ""
        self.lblEmptyMessage.isHidden = !listMovie.isEmpty
    }
    
    private func showAlertWithMessage(content: String) {
        let alert = UIAlertController(title: "Notification", message: content, preferredStyle: .alert)
        self.present(alert, animated: true)
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.listMovie = []
            self.showEmptyMessage()
        } else {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(ViewController.reload), object: nil)
            perform(#selector(reload),with: nil,afterDelay: 1)

        }
    }
    
    @objc func reload() {
        guard let searchText = searchBarView.text?.uppercased() else { return }
//        self.viewModelWithoutRx?.performGetMovie(keyWord: searchText)
    }
    
}

