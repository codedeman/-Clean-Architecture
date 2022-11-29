//
//  DetailScreenVC.swift
//  MovieChallenge
//
//  Created by Kevin on 11/29/22.
//

import UIKit

class DetailScreenVC: UIViewController {

    @IBOutlet weak private var ivMovie: UIImageView!
    var url: URL!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ivMovie.k_setImageWithUrl(url: url,placeHolder: UIImage(named: "default"),showLoading: true)
    }

}
