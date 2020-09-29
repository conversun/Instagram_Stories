import UIKit
import Kingfisher

enum ImageStyle: Int {
    case squared,rounded
}

typealias SetImageRequester = (IGResult<Bool,Error>) -> Void

//extension UIImageView: IGImageRequestable {
extension UIImageView {
    func setImage(url: String,
                  style: ImageStyle = .rounded,
                  completion: SetImageRequester? = nil) {
        
        self.url(url.url) { result in
            switch result {
            case .success(_):
                completion?(.success(true))
            case let .failure(error):
                completion?(.failure(error))
            }
        }
        
//        image = nil
//
//        //The following stmts are in SEQUENCE. before changing the order think twice :P
//        isActivityEnabled = true
//        layer.masksToBounds = false
//        if style == .rounded {
//            layer.cornerRadius = frame.height/2
//            activityStyle = .white
//        } else if style == .squared {
//            layer.cornerRadius = 0
//            activityStyle = .whiteLarge
//        }
//
//        clipsToBounds = true
//        setImage(urlString: url) { (response) in
//            if let completion = completion {
//                switch response {
//                case .success(_):
//                    completion(IGResult.success(true))
//                case .failure(let error):
//                    completion(IGResult.failure(error))
//                }
//            }
//        }
    }
}
