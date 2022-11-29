import UIKit
import RxSwift
import RxCocoa


//example(of: "DisposeBag") {
  // 1
  let disposeBag = DisposeBag()

  // 2
  Observable.of("A", "B", "C")
    .subscribe { // 3
      print($0)
    }
    .disposed(by: disposeBag) // 4
//}
