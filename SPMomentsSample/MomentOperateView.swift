//
//  MomentOperateView.swift
//  SPMomentsSample
//
//  Created by Barry Ma on 2016-05-10.
//  Copyright © 2016 BarryMa. All rights reserved.
//

import UIKit

class MomentOperateView: UIView {

    private var bkgImageView: UIImageView?
    private(set) var likeButton: UIButton?
    private var seperatorView: UIView?
    private(set) var commentButton: UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupMomentOperateView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupMomentOperateView()
    }
    
    override func intrinsicContentSize() -> CGSize {
        // 返回视图natural尺寸
        return CGSizeMake(190, 36)
    }
    
    private func setupMomentOperateView() {
        
        bkgImageView = UIImageView(image: UIImage(named: "AlbumOperateViewBkg")?.resizableImageWithCapInsets(UIEdgeInsetsMake(6, 6, 6, 6)))
        self.addSubview(bkgImageView!)
        
        bkgImageView?.translatesAutoresizingMaskIntoConstraints = false
        var views: [String: UIView] = ["bkgImageView":bkgImageView!]
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[bkgImageView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bkgImageView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        
        likeButton = UIButton(type: UIButtonType.Custom) as? UIButton
        self.addSubview(likeButton!)
        
        let likeIcon = UIImage(named: "AlbumLikeWhite")
        likeButton?.translatesAutoresizingMaskIntoConstraints = false
        likeButton?.setImage(likeIcon, forState: UIControlState.Normal)
        likeButton?.setImage(likeIcon, forState: UIControlState.Highlighted)
        likeButton?.setTitle("Like", forState: UIControlState.Normal)
        likeButton?.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        
        seperatorView = UIView()
        self.addSubview(seperatorView!)
        
        seperatorView?.translatesAutoresizingMaskIntoConstraints = false
        seperatorView?.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8)
        
        
        commentButton = UIButton(type: UIButtonType.Custom) as? UIButton
        self.addSubview(commentButton!)
        
        let commentIcon = UIImage(named: "AlbumCommentWhite")
        commentButton?.translatesAutoresizingMaskIntoConstraints = false
        commentButton?.setImage(commentIcon, forState: UIControlState.Normal)
        commentButton?.setImage(commentIcon, forState: UIControlState.Highlighted)
        commentButton?.setTitle("Comment", forState: UIControlState.Normal)
        commentButton?.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        
        views = ["likeButton": likeButton!, "seperatorView": seperatorView!, "commentButton": commentButton!]
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-3-[likeButton(65)]-3-[seperatorView(1)]-3-[commentButton(112)]-3-|", options: [NSLayoutFormatOptions.AlignAllTop, NSLayoutFormatOptions.AlignAllBottom], metrics: nil, views: views))
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-4-[likeButton]-4-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
    }


}
