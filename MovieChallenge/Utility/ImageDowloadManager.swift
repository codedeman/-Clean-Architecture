//
//  ImageDowloadManager.swift
//  MovieChallenge
//
//  Created by Kevin on 11/29/22.
//

import Foundation
import UIKit

typealias ImageDownloadHandler = (_ image: UIImage?, _ url: URL, _ indexPath: IndexPath?, _ error: Error?) -> Void

final class ImageDownloadManager {
    private var completionHandler: ImageDownloadHandler?
    var operation: PGOperation!
    let imageCache = NSCache<NSString, UIImage>()
    static var shared = ImageDownloadManager()
    
    private init() {}
    
    lazy var imageDownloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "com.imageDownloadqueue"
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    func dowLoadImage(url:URL, hander:@escaping ImageDownloadHandler) {
        self.completionHandler = hander
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
//            print("Return cached image for \(url)")
            self.completionHandler?(cachedImage, url, nil, nil)
        } else {
            operation = PGOperation(url: url, indexPath: nil)
            operation.downloadHandler = { (image, url, indexPath, error) in
                if let newImage = image {
                    self.imageCache.setObject(newImage, forKey: url.absoluteString as NSString)
                }
                self.operation.queuePriority = .high
                self.completionHandler?(image, url, indexPath, error)
            }

            imageDownloadQueue.addOperation(operation)
        }
    }
    
    func cancelTaskProcess() {
        imageDownloadQueue.cancelAllOperations()
        operation.cancel()
    }
    
    func pauseTaskProcess() {
        imageDownloadQueue.progress.pause()
    }
}
