//
//  MomentsTableViewCell.swift
//  SPMomentsSample
//
//  Created by Barry Ma on 2016-05-09.
//  Copyright © 2016 BarryMa. All rights reserved.
//

import UIKit
import Kingfisher
import MHPrettyDate

class MomentsTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: protocol<momentCellDelegate, momentCommentViewDelegate>? {
        didSet {
            commentView.delegate = delegate
        }
    }
    
    var showTopSeperator: Bool = false {
        didSet {
            topSeperator.hidden = !showTopSeperator
        }
    }
    
    var topSeperator: UIView = UIView()
    var avatarView: UIImageView = UIImageView()
    var momentTextView: UITextView = UITextView()
    var photosCollectionView: UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    var createDateLabel: UILabel = UILabel()
    var moreOperateButton: UIButton = UIButton()
    var commentView: MomentCommentView = MomentCommentView()

    var momentTextViewHeightConstraint: NSLayoutConstraint?
    var photosCollectionViewTopConstraint: NSLayoutConstraint?
    var photosCollectionViewHeightConstraint: NSLayoutConstraint?
    var commentShowViewTopConstraint: NSLayoutConstraint?
    var commentShowViewHeightConstraint: NSLayoutConstraint?
    
    
//    private var avatarViewRetrieveImageTask: RetrieveImageTask?
    private var photos: [String]?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupMomentCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupMomentCell() {
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        //Topseperator
        self.contentView.addSubview(topSeperator)
        topSeperator.translatesAutoresizingMaskIntoConstraints = false
        topSeperator.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        topSeperator.addConstraint(NSLayoutConstraint(item: topSeperator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 1))
        contentView.addConstraint(NSLayoutConstraint(item: topSeperator, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .Leading, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: topSeperator, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 0))
        
        
        //AvatarView
        self.contentView.addSubview(avatarView)
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.addConstraint(NSLayoutConstraint(item: avatarView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 48))
        avatarView.addConstraint(NSLayoutConstraint(item: avatarView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 48))
        contentView.addConstraint(NSLayoutConstraint(item: avatarView, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 12))
        contentView.addConstraint(NSLayoutConstraint(item: avatarView, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .Leading, multiplier: 1, constant: 8))
        
        
        //MomentTextView
        self.contentView.addSubview(momentTextView)
        momentTextView.translatesAutoresizingMaskIntoConstraints = false
        //momentTextView.backgroundColor = UIColor.greenColor()
        momentTextView.backgroundColor = UIColor.clearColor()
        momentTextView.scrollEnabled = false
        momentTextView.showsVerticalScrollIndicator = false
        momentTextView.showsHorizontalScrollIndicator = false
        momentTextView.editable = false
        momentTextView.selectable = false
        momentTextView.userInteractionEnabled = false
        momentTextViewHeightConstraint = NSLayoutConstraint(item: momentTextView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 59)
        momentTextView.addConstraint(momentTextViewHeightConstraint!)
        contentView.addConstraint(NSLayoutConstraint(item: momentTextView, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 6))
        contentView.addConstraint(NSLayoutConstraint(item: momentTextView, attribute: .Leading, relatedBy: .Equal, toItem: avatarView, attribute: .Trailing, multiplier: 1, constant: 8))
        contentView.addConstraint(NSLayoutConstraint(item: momentTextView, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: 1, constant: -8))
        
        
        //PhotosCollectionView
        self.contentView.addSubview(photosCollectionView)
        photosCollectionView.translatesAutoresizingMaskIntoConstraints = false
        //photosCollectionView.backgroundColor = UIColor.yellowColor()
        photosCollectionView.backgroundColor = UIColor.clearColor()
        photosCollectionView.registerClass(MomentPhotoCell.self, forCellWithReuseIdentifier: "MomentPhotoCell")
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        photosCollectionViewHeightConstraint = NSLayoutConstraint(item: photosCollectionView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 84)
        photosCollectionView.addConstraint(photosCollectionViewHeightConstraint!)
        contentView.addConstraint(NSLayoutConstraint(item: photosCollectionView, attribute: .Top, relatedBy: .Equal, toItem: momentTextView, attribute: .Bottom, multiplier: 1, constant: 8))
        contentView.addConstraint(NSLayoutConstraint(item: photosCollectionView, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: 1, constant: -8))
        contentView.addConstraint(NSLayoutConstraint(item: photosCollectionView, attribute: .Leading, relatedBy: .Equal, toItem: momentTextView, attribute: .Leading, multiplier: 1, constant: 0))
        
        
        //CreateDateLabel
        self.contentView.addSubview(createDateLabel)
        createDateLabel.translatesAutoresizingMaskIntoConstraints = false
        //createDateLabel.backgroundColor = UIColor.lightGrayColor()
        createDateLabel.backgroundColor = UIColor.clearColor()
        createDateLabel.addConstraint(NSLayoutConstraint(item: createDateLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 18))
        createDateLabel.addConstraint(NSLayoutConstraint(item: createDateLabel, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 175))
        contentView.addConstraint(NSLayoutConstraint(item: createDateLabel, attribute: .Top, relatedBy: .Equal, toItem: photosCollectionView, attribute: .Bottom, multiplier: 1, constant: 8))
        contentView.addConstraint(NSLayoutConstraint(item: createDateLabel, attribute: .Leading, relatedBy: .Equal, toItem: photosCollectionView, attribute: .Leading, multiplier: 1, constant: 0))
        
        
        //MoreOperateButton
        self.contentView.addSubview(moreOperateButton)
        moreOperateButton.translatesAutoresizingMaskIntoConstraints = false
        moreOperateButton.setImage(UIImage(named: "AlbumOperateMore"), forState: UIControlState.Normal)
        moreOperateButton.addTarget(self, action: "clickMoreOperateButton:", forControlEvents: UIControlEvents.TouchUpInside)
        moreOperateButton.addConstraint(NSLayoutConstraint(item: moreOperateButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 25))
        moreOperateButton.addConstraint(NSLayoutConstraint(item: moreOperateButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 25))
        contentView.addConstraint(NSLayoutConstraint(item: moreOperateButton, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: 1, constant: -8))
        contentView.addConstraint(NSLayoutConstraint(item: moreOperateButton, attribute: .CenterY, relatedBy: .Equal, toItem: createDateLabel, attribute: .CenterY, multiplier: 1, constant: 0))
        
        
        //CommentView
        self.contentView.addSubview(commentView)
        commentView.translatesAutoresizingMaskIntoConstraints = false
        //commentView.backgroundColor = UIColor.grayColor()
        commentView.backgroundColor = UIColor.clearColor()
        commentShowViewHeightConstraint = NSLayoutConstraint(item: commentView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 60)
        commentView.addConstraint(commentShowViewHeightConstraint!)
        contentView.addConstraint(NSLayoutConstraint(item: commentView, attribute: .Top, relatedBy: .Equal, toItem: createDateLabel, attribute: .Bottom, multiplier: 1, constant: 8))
        contentView.addConstraint(NSLayoutConstraint(item: commentView, attribute: .Leading, relatedBy: .Equal, toItem: createDateLabel, attribute: .Leading, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: commentView, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: 1, constant: -8))
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if photos != nil {
            return photos!.count
        }
        return 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MomentPhotoCell", forIndexPath: indexPath) as! MomentPhotoCell
        
        //cell.configWithPhotoURL(photoURLs![indexPath.row])
        cell.photoView?.image = UIImage(named: "momentPhoto")
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        delegate?.momentCell?(self, didSelectPhotoViewAtIndex:indexPath.row)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let collectionViewWidth = CGRectGetWidth(collectionView.bounds)
        let columns = Int((collectionViewWidth + momentPhotoMinimumInteritemSpacing)/(momentPhotoSize + momentPhotoMinimumInteritemSpacing))
        
        var itemWidth: CGFloat = 0
        if columns == 0 {
            itemWidth = collectionViewWidth
        } else {
            itemWidth = (collectionViewWidth - CGFloat(columns - 1)*momentPhotoMinimumInteritemSpacing)/CGFloat(columns)
        }
        
        return CGSizeMake(itemWidth, momentPhotoSize)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return momentPhotoMinimumLineSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return momentPhotoMinimumInteritemSpacing
    }

    
    func configWithData(data: [String: AnyObject]? = nil, cellWidth: CGFloat = 0) {
        
        let avatarURL = data?[momentCellMomentDataKey_avatarURL] as? NSURL
        let authorName = data?[momentCellMomentDataKey_authorName] as? String
        let textContent = data?[momentCellMomentDataKey_textContent] as? String
        let photos = data?[momentCellMomentDataKey_photoURLs] as? [String]
        let createDate = data?[momentCellMomentDataKey_createDate]  as? NSDate
        let comments = data?[momentCellMomentDataKey_comments] as? [[String: AnyObject]]
        let likes = data?[momentCellMomentDataKey_likeUserNames] as? [String]
        
        let momentTextViewWidth = cellWidth - momentTextViewLittleThanCellWidth
        
        // 设置头像
//        if avatarURL != nil {
//            avatarViewRetrieveImageTask = avatarView?.kf_setImageWithURL(avatarURL!, placeholderImage: UIImage(named: "RoleAvatar"))
//        } else {
//            avatarViewRetrieveImageTask?.cancel()
//            avatarView?.image = UIImage(named: "RoleAvatar")
//        }
        
        avatarView.image = UIImage(named: "roleAvatar")
        
        // 设置文字内容
        let momentAttributedText = MomentsTableViewCell.buildMomentTextViewAttributedTextWithAuthorName(authorName, momentTextContent:textContent)
        momentTextView.attributedText = momentAttributedText
        
        momentTextViewHeightConstraint?.constant = MomentsTableViewCell.momentTextViewHeightWithAttributedText(momentAttributedText, momentTextViewWidth:momentTextViewWidth)
        
        // 设置图片
        self.photos = photos
        photosCollectionView.reloadData()
        
        if let photoCount = photos?.count {
            photosCollectionViewTopConstraint?.constant = momentPhotosCollectionViewTopMargin
            
            photosCollectionViewHeightConstraint?.constant = MomentsTableViewCell.caculatePhotosCollectionViewHeightWithPhotoNumber(photoCount, collectionViewWidth: momentTextViewWidth)
        } else {
            photosCollectionViewTopConstraint?.constant = 0
            photosCollectionViewHeightConstraint?.constant = 0
        }
        
        // 设置时间
        if createDate != nil {
            createDateLabel.text = MHPrettyDate.prettyDateFromDate(createDate, withFormat: MHPrettyDateFormatWithTime)
        } else {
            createDateLabel.text = nil
        }
        
        // 设置评论视图
        var commentViewData = [String: AnyObject]()
        if likes != nil {
            commentViewData[MomentCommentViewMomentDataKey_likeUserNames] = likes!
        }
        
        if comments != nil {
            var commentViewComments = [[String:AnyObject]]()
            for comment in comments! {
                commentViewComments.append(MomentsTableViewCell.buildCommentShowViewCommentDataWithMomentComment(comment))
            }
            commentViewData[MomentCommentViewMomentDataKey_comments] = commentViewComments
        }
        
        commentView.configWithData(commentViewData, viewWidth: momentTextViewWidth)
        
        if commentViewData.count > 0 {
            commentShowViewTopConstraint?.constant = momentCommentShowViewTopMargin
            commentShowViewHeightConstraint?.constant = MomentCommentView.caculateHeightWithData(commentViewData, viewWidth: momentTextViewWidth)
        } else {
            commentShowViewTopConstraint?.constant = 0
            commentShowViewHeightConstraint?.constant = 0
        }
    }
    
    static func buildCommentShowViewCommentDataWithMomentComment(momentComments: [String: AnyObject]) -> [String: AnyObject] {
        var commentViewComments = [String:AnyObject]()
        
        if let commentAuthorRoleName: AnyObject = momentComments[momentCellCommentDataKey_authorName] {
            commentViewComments[MomentCommentViewCommentDataKey_authorName] = commentAuthorRoleName
        }
        
        if let commentAtUserRoleName: AnyObject = momentComments[momentCellCommentDataKey_atUserName] {
            commentViewComments[MomentCommentViewCommentDataKey_atUserName] = commentAtUserRoleName
        }
        
        if let commentText: AnyObject = momentComments[momentCellCommentDataKey_textContent] {
            commentViewComments[MomentCommentViewCommentDataKey_textContent] = commentText
        }
        
        return commentViewComments
    }
    
    
    static func cellHeightWithData(data: [String: AnyObject]? = nil, cellWidth: CGFloat = 0) -> CGFloat {
        
        var cellHeight: CGFloat = 0
        
        let authorName = data?[momentCellMomentDataKey_authorName] as? String
        let textContent = data?[momentCellMomentDataKey_textContent] as? String
        let photos = data?[momentCellMomentDataKey_photoURLs] as? [String]
        let createDate = data?[momentCellMomentDataKey_createDate]  as? NSDate
        let comments = data?[momentCellMomentDataKey_comments] as? [[String: AnyObject]]
        let likes = data?[momentCellMomentDataKey_likeUserNames] as? [String]
        
        let momentTextViewWidth = cellWidth - momentTextViewLittleThanCellWidth
        
        // 计算cell顶部padding
        cellHeight += momentCellTopPadding
        
        // 计算文字内容视图高度
        
        let momentAttributedText = MomentsTableViewCell.buildMomentTextViewAttributedTextWithAuthorName(authorName, momentTextContent:textContent)
        cellHeight += MomentsTableViewCell.momentTextViewHeightWithAttributedText(momentAttributedText, momentTextViewWidth: momentTextViewWidth)
        
        // 计算图片显示视图高度
        if let photoCount = photos?.count {
            cellHeight += (momentPhotosCollectionViewTopMargin +
                caculatePhotosCollectionViewHeightWithPhotoNumber(photoCount, collectionViewWidth: momentTextViewWidth))
        }
        
        // 计算时间视图高度
        cellHeight += (momentCreateDateLabelTopMargin + momentCreateDateLabelHeight)
        
        // 计算评论视图高度
        var commentViewData = [String: AnyObject]()
        if likes != nil {
            commentViewData[MomentCommentViewMomentDataKey_likeUserNames] = likes!
        }
        
        if comments != nil {
            var commentViewComments = [[String:AnyObject]]()
            for comment in comments! {
                commentViewComments.append(MomentsTableViewCell.buildCommentShowViewCommentDataWithMomentComment(comment))
            }
            commentViewData[MomentCommentViewMomentDataKey_comments] = commentViewComments
        }
        
        if commentViewData.count > 0 {
            let commentViewHeight = MomentCommentView.caculateHeightWithData(commentViewData, viewWidth: momentTextViewWidth)
            cellHeight += (momentCommentShowViewTopMargin + commentViewHeight)
        }
        
        // 计算cell底部padding
        cellHeight += momentCellBottomPadding
        
        return cellHeight > momentCellMinHeight ? cellHeight:momentCellMinHeight
    }
    
    
    static private func buildMomentTextViewAttributedTextWithAuthorName(authorName: String?, momentTextContent: String?) -> NSAttributedString? {
        let attributedText = NSMutableAttributedString()
        
        // 动态发布者名字
        if authorName?.isEmpty == false {
            let namePS = NSMutableParagraphStyle()
            namePS.lineSpacing = 2
            namePS.paragraphSpacing = 8
            attributedText.appendAttributedString(NSAttributedString(string:authorName!, attributes:[NSFontAttributeName:UIFont.systemFontOfSize(18), NSForegroundColorAttributeName:UIColor.blackColor(), NSParagraphStyleAttributeName:namePS]))
        }
        
        // 角色描述
        if momentTextContent?.isEmpty == false {
            if attributedText.length > 0 {
                attributedText.appendAttributedString(NSAttributedString(string: "\n"))
            }
            
            let contentPS = NSMutableParagraphStyle()
            contentPS.lineSpacing = 2
            contentPS.paragraphSpacing = 4
            attributedText.appendAttributedString(NSAttributedString(string:momentTextContent!, attributes:[NSFontAttributeName:UIFont.systemFontOfSize(14), NSForegroundColorAttributeName:UIColor.grayColor(), NSParagraphStyleAttributeName:contentPS]))
        }
        
        return attributedText
    }

    
    static private func momentTextViewHeightWithAttributedText(attributedText:NSAttributedString?, momentTextViewWidth:CGFloat? = 0) -> CGFloat {
        
        if attributedText == nil {
            return 0
        }
        
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var sizingTextView : UITextView? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.sizingTextView = UITextView()
        }
        
        Static.sizingTextView?.attributedText = attributedText
        let sizingTextViewSize = Static.sizingTextView?.sizeThatFits(CGSizeMake(momentTextViewWidth!, CGFloat(MAXFLOAT)))
        
        return sizingTextViewSize!.height
    }
    
    
    static private func caculatePhotosCollectionViewHeightWithPhotoNumber(photoNumber: Int = 0, collectionViewWidth: CGFloat = 0) -> CGFloat {
        
        if photoNumber <= 0 {
            return 0
        }
        
        let columns = Int((collectionViewWidth + momentPhotoMinimumInteritemSpacing)/(momentPhotoSize + momentPhotoMinimumInteritemSpacing))
        if columns <= 0 {
            return 0
        } else {
            let rows = Int(ceilf(Float(photoNumber)/Float(columns)))
            if rows <= 0 {
                return 0
            } else {
                return (CGFloat(rows) * momentPhotoSize + CGFloat(rows - 1)*momentPhotoMinimumLineSpacing)
            }
        }
    }
    
    
    @objc private func clickMoreOperateButton(button: UIButton) {
        delegate?.momentCell?(self, didClickMoreOprateButton: button)
    }

    
    class MomentPhotoCell: UICollectionViewCell {
        private var photoView: UIImageView?
        //private var retrievePhotoViewImageTask: RetrieveImageTask?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupMomentPhotoCell()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupMomentPhotoCell() {
            
            photoView = UIImageView()
            self.contentView.addSubview(photoView!)
            
            photoView?.translatesAutoresizingMaskIntoConstraints = false
            photoView?.contentMode = UIViewContentMode.ScaleAspectFill
            photoView?.clipsToBounds = true
            
            // 设置约束
            let views = ["photoView":photoView!]
            
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[photoView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[photoView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        }
    }

}

@objc protocol momentCellDelegate {
    
    optional func momentCell(momentCell: MomentsTableViewCell, didClickMoreOprateButton: UIButton)
    
    optional func momentCell(momentCell: MomentsTableViewCell, didSelectPhotoViewAtIndex: Int)
}


let momentCellMinHeight: CGFloat = 64
let momentCellTopPadding: CGFloat = 6
let momentCellBottomPadding: CGFloat = 8

let momentTextViewLittleThanCellWidth: CGFloat = 72

let momentPhotosCollectionViewTopMargin: CGFloat = 8
let momentPhotoSize: CGFloat = 84
let momentPhotoMinimumLineSpacing: CGFloat = 4
let momentPhotoMinimumInteritemSpacing: CGFloat = 4
let momentPhotoCellReuseIdentifier = "momentPhotoCell"

let momentCreateDateLabelTopMargin: CGFloat = 8
let momentCreateDateLabelHeight: CGFloat = 18

let momentCommentShowViewTopMargin: CGFloat = 8

/// 动态的数据key
let momentCellMomentDataKey_avatarURL = "momentCellMomentDataKey_avatarURL"
let momentCellMomentDataKey_authorName = "momentCellMomentDataKey_authorName"
let momentCellMomentDataKey_textContent = "momentCellMomentDataKey_textContent"
let momentCellMomentDataKey_photoURLs = "momentCellMomentDataKey_photoURLs"
let momentCellMomentDataKey_createDate = "momentCellMomentDataKey_createDate"
// 动态的评论数据，每条评论的具体信息再通过评论的数据key获取
let momentCellMomentDataKey_comments = "momentCellMomentDataKey_comments"
// 动态的点赞用户
let momentCellMomentDataKey_likeUserNames = "momentCellMomentDataKey_likeUserNames"

// 评论的数据key
let momentCellCommentDataKey_authorName = "momentCellCommentDataKey_authorName"
let momentCellCommentDataKey_atUserName = "momentCellCommentDataKey_atUserName"
let momentCellCommentDataKey_textContent = "momentCellCommentDataKey_textContent"
