//
//  IGStoryPreviewBottomView.swift
//  NeverSlake
//
//  Created by Conver on 30/9/2020.
//  Copyright © 2020 SORI. All rights reserved.
//

import Foundation
import PinLayout
import RxCocoa
import RxSwift
import Photos
import Kingfisher
import UIKit

class IGStoryPreviewBottomView: UIView {
    
    var disposeBag = DisposeBag()
    
    let download = UIButton()
        .image("ic_download_userprofile")
    let downloadVip = UIImageView()
        .image("ic_pro_color")
        .isUserInteractionEnabled(false)
    let share = UIButton()
        .image("ic_repost_userprofile")
    let bgView = UIView()
    
    public var snap: IGSnap? {
        didSet {
            
        }
    }
    
    var willShow: (() -> Void)?
    var willHide: (() -> Void)?
    
    func observer() {
        
        PurchaseManager.default.statusDriver
            .drive(downloadVip.rx.isHidden)
            .disposed(by: disposeBag)
        
        share.rx
            .tap
            .bind(onNext: { [weak self] in
                guard let `self` = self else { return }
                guard let url = self.snap?.url else { return }
                
                switch self.snap?.kind {
                case .image:
                    guard let url = url.url else { return }
                    HUD.show()
                    KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: url)) { result in
                        HUD.hide()
                        switch result {
                        case let .success(response):
                            let visibleVC = UIApplication.rootController?.visibleVC
                            let vc = UIActivityViewController(activityItems: [response.image], applicationActivities: nil)
                            vc.excludedActivityTypes = [.saveToCameraRoll]
                            if let popOver = vc.popoverPresentationController {
                                popOver.sourceView = visibleVC?.view
                                popOver.sourceRect = visibleVC?.view.convert(self.share.frame, from: self.share.superview ?? self.share) ?? self.share.bounds
                            }
                            visibleVC?.present(vc, animated: true, completion: nil)
                        case let .failure(error):
                            HUD.error(error.localizedDescription)
                        }
                    }
                case .video:
                    
                    HUD.show()
                    IGVideoCacheManager.shared.getFile(for: url) { result in
                        HUD.hide()
                        switch result {
                        case let .success(response):
                            let visibleVC = UIApplication.rootController?.visibleVC
                            let vc = UIActivityViewController(activityItems: [response], applicationActivities: nil)
                            vc.excludedActivityTypes = [.saveToCameraRoll]
                            if let popOver = vc.popoverPresentationController {
                                popOver.sourceView = visibleVC?.view
                                popOver.sourceRect = visibleVC?.view.convert(self.share.frame, from: self.share.superview ?? self.share) ?? self.share.bounds
                            }
                            UIApplication.rootController?.visibleVC?.present(vc, animated: true, completion: nil)
                        case let .failure(error):
                            HUD.error(error.localizedDescription)
                        }
                    }
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        download.rx
            .tap
            .bind(onNext: { [weak self] in
                guard let `self` = self else { return }
                guard PurchaseManager.default.checkBoost() else { return }
                guard let url = self.snap?.url else { return }
                
                UIApplication.rootController?.visibleVC?.photoPermission(block: { allow in
                    guard allow else { return }
                    
                    switch self.snap?.kind {
                    case .image:
                        guard let url = url.url else { return }
                        HUD.show()
                        KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: url)) { result in
                            switch result {
                            case let .success(response):
                                PHPhotoLibrary.shared().performChanges({
                                    PHAssetChangeRequest.creationRequestForAsset(from: response.image)
                                }) { success, _ in
                                    DispatchQueue.main.async {
                                        if success {
                                            HUD.success(NSLocalizedString("Successfully saved", comment: ""))
                                        } else {
                                            HUD.error(NSLocalizedString("Save failed", comment: ""))
                                        }
                                    }
                                }
                            case let .failure(error):
                                HUD.error(error.localizedDescription)
                            }
                        }
                    case .video:
                        HUD.show()
                        IGVideoCacheManager.shared.getFile(for: url) { result in
                            switch result {
                            case let .success(response):
                                PHPhotoLibrary.shared().performChanges({
                                    PHAssetChangeRequest
                                        .creationRequestForAssetFromVideo(atFileURL: response)
                                }) { success, _ in
                                    DispatchQueue.main.async {
                                        if success {
                                            HUD.success(NSLocalizedString("Successfully saved", comment: ""))
                                        } else {
                                            HUD.error(NSLocalizedString("Save failed", comment: ""))
                                        }
                                    }
                                }
                            case let .failure(error):
                                HUD.error(error.localizedDescription)
                            }
                        }
                    default:
                        break
                    }
                })
            })
            .disposed(by: disposeBag)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        [bgView, download, downloadVip, share]
            .forEach { $0.adhere(toSuperview: self) }
        observer()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bgView.pin.left().right().bottom().height(44 + (UIApplication.rootController?.rootVC?.view.safeArea.bottom ?? 0))
        
        share.pin.right(8).bottom(8 + (UIApplication.rootController?.rootVC?.view.safeArea.bottom ?? 0)).size(44)
        download.pin.before(of: share, aligned: .center).size(44).marginRight(8)
        downloadVip.pin.sizeToFit().before(of: share, aligned: .top).marginRight(-6)
        
        bgView.gradientVertical(.clear, UIColor.black.withAlphaComponent(0.5))
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
