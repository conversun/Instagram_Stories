//
//  IGStoryPreviewTipView.swift
//  NeverSlake
//
//  Created by zhang on 4/1/2021.
//  Copyright © 2021 leizhang All rights reserved.
//

import Foundation
import UIKit
import PinLayout
import RxSwift

class IGStoryPreviewTipView: UIView {
    
    var disposeBag = DisposeBag()
    
    let name = UILabel()
        .font(13)
        .color(.white)
        .text(NSLocalizedString("You are viewing in private mode", comment: "story_preview_tip"))
    
    let close = UIButton()
        .image("ic_close_small")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor(UIColor.black.withAlphaComponent(0.3))
        
        name.adhere(toSuperview: self)
        close.adhere(toSuperview: self)
     
        close.rx
            .inTouch
            .bind(onNext: { [weak self] bool in
                guard let self = self else { return }
                self.close.alpha(bool ? 0.5 : 1.0)
            })
            .disposed(by: disposeBag)
        
        close.rx
            .tap
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.removeFromSuperview()
                BoolCache[.didCloseStoryPriviteTip] = true
            })
            .disposed(by: disposeBag)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        close.pin.size(46).centerRight(8)
        name.pin.sizeToFit(.width).before(of: close).centerLeft(16)
    }
    
}
