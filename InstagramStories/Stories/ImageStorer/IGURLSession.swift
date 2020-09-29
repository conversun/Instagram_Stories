//
//  IGURLSession.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 02/04/19.
//  Copyright © 2019 DrawRect. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

public typealias ImageResponse = (IGResult<UIImage, Error>) -> Void

class IGURLSession: URLSession {
    static let `default` = IGURLSession()
}
extension IGURLSession {
    func cancelAllPendingTasks() {
        ImageDownloader.default.cancelAll()
    }

    func downloadImage(using urlString: String, completionBlock: @escaping ImageResponse) {
        guard let url = URL(string: urlString) else {
            return completionBlock(.failure(IGError.invalidImageURL))
        }
        ImageDownloader.default.downloadImage(with: url, options: [], completionHandler:  { result in
            switch result {
            case let .success(response):
                completionBlock(.success(response.image))
            case let .failure(error):
                completionBlock(.failure(error))
            }
        })
    }
}
