//
//  IGStoryPreviewHeaderView.swift
//
//  Created by Boominadha Prakash on 06/09/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit
import FlexLayout
import PinLayout
import SwiftyInsta

protocol StoryPreviewHeaderProtocol:class {func didTapCloseButton()}

fileprivate let maxSnaps = 30

//Identifiers
public let progressIndicatorViewTag = 88
public let progressViewTag = 99

final class IGStoryPreviewHeaderView: UIView {
    
    //MARK: - iVars
    public weak var delegate:StoryPreviewHeaderProtocol?
    fileprivate var snapsPerStory: Int = 0
    public var story:IGStory? {
        didSet {
            snapsPerStory  = (story?.snapsCount)! < maxSnaps ? (story?.snapsCount)! : maxSnaps
            
            forever.show(RemoteRelay.default.localConfig.wonderful
                            && story?.user.responseUser?.IGUserId != nil
                            && story?.user.responseUser?.IGUserId != LoginRelay.Current.userID)
        }
    }
    fileprivate var progressView: UIView?
    
    let snaperImageView = UIImageView()
        .crop()
        .cornerRadius(23)
    let detailView = UIView()
    
    let snaperNameLabel = UILabel()
        .font(13)
        .color(.white)
        .isUserInteractionEnabled(false)
    
    let lastUpdatedLabel = UILabel()
        .font(11)
        .color(UIColor.white.withAlphaComponent(0.5))
        .isUserInteractionEnabled(false)
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "ic_close_white"), for: .normal)
        button.addTarget(self, action: #selector(didTapClose(_:)), for: .touchUpInside)
        return button
    }()
    
    let leftControl = UIControl()
    
    let bgView = UIView()
    
    let forever = LoadingButton()
        .hidden()
        .titleColor(.white)
        .font(12)
        .cornerRadius(4)
        .backgroundColor(UIColor.white.withAlphaComponent(0.3))

    public var getProgressView: UIView {
        if let progressView = self.progressView {
            return progressView
        }
        let v = UIView()
        self.progressView = v
        self.addSubview(self.getProgressView)
        return v
    }
    
    //MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
//        applyShadowOffset()
        loadUIElements()
        installLayoutConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Private functions
    private func loadUIElements(){
        backgroundColor = .clear
        addSubview(bgView)
        addSubview(getProgressView)
        addSubview(closeButton)
        addSubview(detailView)
        
        forever.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        forever.titleLabel?.adjustsFontSizeToFitWidth = true
        
        forever.addTarget(self, action: #selector(foreverAction), for: .touchUpInside)
        leftControl.addTarget(self, action: #selector(leftControlAction), for: .touchUpInside)
        
        forever.show(RemoteRelay.default.localConfig.wonderful)
        
    }
    
    
    @objc
    func leftControlAction() {
        if let user = story?.user.responseUser {
            let vc = UserDetailVC(user, false)
            UIApplication.rootController?.visibleVC?.dismiss(animated: true, completion: {
                UIApplication.rootController?.visibleVC?.present(vc.withNavigation())
            })
        }
    }
    
    @objc
    func foreverAction() {
        forever.showLoading()
        if let user = story?.user.responseUser,
           let forevering = user.friendship?.isWatchedByYou {
            updateUserStatusSingle(user, forevering: forevering) { [weak self] status in
                self?.status = status
            }
        }
    }
    
    func updateUserStatusSingle(_ user: UserDBProtocol,
                          forevering: Bool,
                          requesting: Bool = false,
                          complete: ((Friendship?) -> Void)? = nil)
    {
        guard let userID = user.IGUserId?.int else { return }
        RefreshRelay.default.updateUserStatus(user, forevering: forevering, requesting: requesting) { result in
            switch result {
            case let .success(response):
                UserListVC.statusList[userID.string] = response.friendshipStatus
                complete?(response.friendshipStatus)
            case let .failure(error):
                error.apiError()
                complete?(nil)
            }
        }
    }
    
    var status: Friendship? {
        didSet {
            guard let status = status else { return }

            forever.show()
            
            var foreverIng = status.isWatchedByYou
            let requestIng = status.watchRequestSent

            if requestIng { foreverIng = true }

            forever.hideLoading()
            if foreverIng {
                forever.title(requestIng ? NSLocalizedString("Requested", comment: "") :
                                NSLocalizedString("Unfollow", comment: ""))
            } else {
                forever.title(NSLocalizedString("Follow", comment: ""))
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.pin.top().left().right().height(44+46)
        getProgressView.pin.top().left().right(60).height(44)
        closeButton.pin.top(0).right(8).size(44)
        detailView.pin.top(44).left().right().height(46)
        detailView.flex.layout()
        
        bgView.gradientVertical(UIColor.black.withAlphaComponent(0.5), .clear)
        
    }
    
    private func installLayoutConstraints(){
        detailView.flex.direction(.row).justifyContent(.spaceBetween).alignItems(.center)
            .paddingHorizontal(16).define {
                $0.addItem(leftControl).direction(.row).grow(1).define {
                    $0.addItem(snaperImageView).size(46)
                    $0.addItem(UIView().isUserInteractionEnabled(false))
                        .direction(.column).grow(1).justifyContent(.spaceBetween)
                        .padding(4, 16, 4, 16).define {
                            $0.addItem(snaperNameLabel)
                            $0.addItem(lastUpdatedLabel)
                        }
                }
                $0.addItem(forever).width(72).height(26)
            }
    }
    private func applyShadowOffset() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
    }
    private func applyProperties<T: UIView>(_ view: T, with tag: Int? = nil, alpha: CGFloat = 1.0) -> T {
        view.layer.cornerRadius = 1
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        if let tagValue = tag {
            view.tag = tagValue
        }
        return view
    }
    
    //MARK: - Selectors
    @objc func didTapClose(_ sender: UIButton) {
        delegate?.didTapCloseButton()
    }
    
    //MARK: - Public functions
    public func clearTheProgressorSubviews() {
        getProgressView.subviews.forEach { v in
            v.subviews.forEach{v in (v as! IGSnapProgressView).stop()}
            v.removeFromSuperview()
        }
    }
    public func clearAllProgressors() {
        clearTheProgressorSubviews()
        getProgressView.removeFromSuperview()
        self.progressView = nil
    }
    public func clearSnapProgressor(at index:Int) {
        getProgressView.subviews[index].removeFromSuperview()
    }
    public func createSnapProgressors(){
        print("Progressor count: \(getProgressView.subviews.count)")
        let padding: CGFloat = 10 //GUI-Padding
        let height: CGFloat = 3
        var pvIndicatorArray: [IGSnapProgressIndicatorView] = []
        var pvArray: [IGSnapProgressView] = []
        
        // Adding all ProgressView Indicator and ProgressView to seperate arrays
        for i in 0..<snapsPerStory{
            let pvIndicator = IGSnapProgressIndicatorView()
            pvIndicator.translatesAutoresizingMaskIntoConstraints = false
            getProgressView.addSubview(applyProperties(pvIndicator, with: i+progressIndicatorViewTag, alpha:0.2))
            pvIndicatorArray.append(pvIndicator)
            
            let pv = IGSnapProgressView()
            pv.translatesAutoresizingMaskIntoConstraints = false
            pvIndicator.addSubview(applyProperties(pv))
            pvArray.append(pv)
        }
        // Setting Constraints for all progressView indicators
        for index in 0..<pvIndicatorArray.count {
            let pvIndicator = pvIndicatorArray[index]
            if index == 0 {
                pvIndicator.leftConstraiant = pvIndicator.igLeftAnchor.constraint(equalTo: self.getProgressView.igLeftAnchor, constant: padding)
                NSLayoutConstraint.activate([
                    pvIndicator.leftConstraiant!,
                    pvIndicator.igCenterYAnchor.constraint(equalTo: self.getProgressView.igCenterYAnchor),
                    pvIndicator.heightAnchor.constraint(equalToConstant: height)
                    ])
                if pvIndicatorArray.count == 1 {
                    pvIndicator.rightConstraiant = self.getProgressView.igRightAnchor.constraint(equalTo: pvIndicator.igRightAnchor, constant: padding)
                    pvIndicator.rightConstraiant!.isActive = true
                }
            }else {
                let prePVIndicator = pvIndicatorArray[index-1]
                pvIndicator.widthConstraint = pvIndicator.widthAnchor.constraint(equalTo: prePVIndicator.widthAnchor, multiplier: 1.0)
                pvIndicator.leftConstraiant = pvIndicator.igLeftAnchor.constraint(equalTo: prePVIndicator.igRightAnchor, constant: padding)
                NSLayoutConstraint.activate([
                    pvIndicator.leftConstraiant!,
                    pvIndicator.igCenterYAnchor.constraint(equalTo: prePVIndicator.igCenterYAnchor),
                    pvIndicator.heightAnchor.constraint(equalToConstant: height),
                    pvIndicator.widthConstraint!
                    ])
                if index == pvIndicatorArray.count-1 {
                    pvIndicator.rightConstraiant = self.igRightAnchor.constraint(equalTo: pvIndicator.igRightAnchor, constant: 56)
                    pvIndicator.rightConstraiant!.isActive = true
                }
            }
        }
        // Setting Constraints for all progressViews
        for index in 0..<pvArray.count {
            let pv = pvArray[index]
            let pvIndicator = pvIndicatorArray[index]
            pv.widthConstraint = pv.widthAnchor.constraint(equalToConstant: 0)
            NSLayoutConstraint.activate([
                pv.igLeftAnchor.constraint(equalTo: pvIndicator.igLeftAnchor),
                pv.heightAnchor.constraint(equalTo: pvIndicator.heightAnchor),
                pv.igTopAnchor.constraint(equalTo: pvIndicator.igTopAnchor),
                pv.widthConstraint!
                ])
        }
        snaperNameLabel.text = story?.user.name
        if RemoteRelay.default.localConfig.wonderful,
           let user = story?.user.responseUser,
           let userID = user.IGUserId {
            self.status = UserListVC.statusList[userID] ?? user.friendship
            
        }
    }
}
