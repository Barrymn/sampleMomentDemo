//
//  MomentCommentView.swift
//  SPMomentsSample
//
//  Created by Barry Ma on 2016-05-09.
//  Copyright © 2016 BarryMa. All rights reserved.
//

import UIKit
import DWTagList
import TTTAttributedLabel

@objc protocol momentCommentViewDelegate {
    
    optional func momentCommentView(view: MomentCommentView, didSelectCommentIndex: Int)
    
    optional func momentCommentView(view: MomentCommentView, didSelectCommentUserName: String)
    
    optional func momentCommentView(view: MomentCommentView, didSelectLikeUserName: String, atIndex: Int)
}



class MomentCommentView: UIView, UITableViewDelegate, UITableViewDataSource, MomentCommentCellDelegate, DWTagListDelegate {

    weak var delegate: momentCommentViewDelegate?
    
    private var backgroundBoxImageView: UIImageView?
    private var likesTagView: DWTagList?
    private var likeIconView: UIImageView?
    private var likesCommentsSeperatorView: UIView?
    private var commentsTable: UITableView?
    
    private var likesTagViewHeightConstraint: NSLayoutConstraint?
    private var likesCommentsSeperatorViewTopConstraint: NSLayoutConstraint?
    private var likesCommentsSeperatorViewHeightConstraint: NSLayoutConstraint?
    private var commentsTableTopConstraint: NSLayoutConstraint?
    private var commentsTableHeightConstraint: NSLayoutConstraint?
    
    private var comments: [[String: AnyObject]!]?
    private var likeUserNames: [String]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupMomentCommentView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupMomentCommentView()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if comments != nil {
            return comments!.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return MomentCommentCell.cellHeightWithData(comments![indexPath.row], cellWidth: CGRectGetWidth(tableView.bounds))
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MomentCommentCell", forIndexPath: indexPath) as! MomentCommentCell
        
        cell.delegate = self
        cell.configWithData(comments![indexPath.row], cellWidth: CGRectGetWidth(tableView.bounds))
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        delegate?.momentCommentView?(self, didSelectCommentIndex: indexPath.row)
    }
    
    // MARK: - momentCommentCellDelegate
    
    func momentCommentCell(cell: MomentCommentCell!, didSelectUserName: String!) {
        delegate?.momentCommentView?(self, didSelectCommentUserName: didSelectUserName)
    }
    
    // MARK: - DWTagListDelegate
    
    func selectedTag(tagName: String!, tagIndex: Int) {
        print("selectedTag:\(tagName), tagIndex:\(tagIndex)")
        if tagName != momentLikeTagSeperatorString && likeUserNames != nil {
            
            // FIXME: 获取真正的index，升级到swift2.0 使用indexOf方法
            var realIndex = 0
            
            for (index, value) in (likeUserNames!).enumerate() {
                if value == tagName {
                    realIndex = index
                    delegate?.momentCommentView?(self, didSelectLikeUserName: tagName, atIndex:realIndex)
                    break
                }
            }
        }
    }
    
    func configWithData(data: [String: AnyObject]? = nil, viewWidth: CGFloat = 0) {
        
        let likeUserNames = data?[MomentCommentViewMomentDataKey_likeUserNames] as? [String]
        let comments = data?[MomentCommentViewMomentDataKey_comments] as? [[String:AnyObject]!]
        
        // 设置赞视图
        self.likeUserNames = likeUserNames
        
        let builedTags = MomentCommentView.buildTagsWithLikeNames(likeUserNames, seperateString:momentLikeTagSeperatorString)
        if builedTags == nil {
            likesTagView?.setTags([String]())
            likesTagViewHeightConstraint?.constant = 0
            likeIconView?.hidden = true
        } else {
            likesTagView?.setTags(builedTags)
            likesTagViewHeightConstraint?.constant = MomentCommentView.caculateLikesTagViewHeightWithLikeUserNames(likeUserNames, likesTagViewWidth: (viewWidth - MomentCommentView_likesTagViewLittleThanShowView))
            likeIconView?.hidden = false
        }
        
        // 设置分割线
        if likeUserNames?.count > 0 && comments?.count > 0 {
            likesCommentsSeperatorViewTopConstraint?.constant = MomentCommentView_seperatorTopMargin
            likesCommentsSeperatorViewHeightConstraint?.constant = MomentCommentView_seperatorViewHeight
        } else {
            likesCommentsSeperatorViewTopConstraint?.constant = 0
            likesCommentsSeperatorViewHeightConstraint?.constant = 0
        }
        
        // 设置评论视图
        
        self.comments = comments
        commentsTable?.reloadData()
        
        if comments?.count > 0 {
            let commentsTableHeight = MomentCommentView.caculateCommentsTableHeightWithComments(comments!, commentsTableWidth: viewWidth)
            commentsTableHeightConstraint?.constant = commentsTableHeight
            if commentsTableHeight > 0 {
                commentsTableTopConstraint?.constant = MomentCommentView_commentsTableTopMargin
            }
        } else {
            commentsTableHeightConstraint?.constant = 0
            commentsTableTopConstraint?.constant = 0
        }
    }
    
    
    /**
     计算视图高度
     
     - parameter data:
     - parameter viewWidth:
     
     - returns: 计算出的高度
     */
    static func caculateHeightWithData(data: [String: AnyObject]? = nil, viewWidth: CGFloat = 0) -> CGFloat {
        
        // 返回计算的高度
        
        var height: CGFloat = 0
        
        let likeUserNames = data?[MomentCommentViewMomentDataKey_likeUserNames] as? [String]
        let comments = data?[MomentCommentViewMomentDataKey_comments] as? [[String:AnyObject]!]
        
        // 计算topPadding
        height += MomentCommentView_likesTagViewTopMargin
        
        // 计算赞相关视图的高度
        if likeUserNames?.count > 0 {
            let likesTagViewHeight = caculateLikesTagViewHeightWithLikeUserNames(likeUserNames, likesTagViewWidth: (viewWidth - MomentCommentView_likesTagViewLittleThanShowView))
            height += likesTagViewHeight
        }
        
        // 计算分割线的高度
        if likeUserNames?.count > 0 && comments?.count > 0 {
            height += (MomentCommentView_seperatorTopMargin + MomentCommentView_seperatorViewHeight)
        }
        
        // 计算评论相关的高度
        if comments?.count > 0 {
            let commentsTableHeight = caculateCommentsTableHeightWithComments(comments!, commentsTableWidth: viewWidth)
            if commentsTableHeight > 0 {
                height += (MomentCommentView_commentsTableTopMargin + commentsTableHeight)
            }
        }
        
        if height > 0 {
            height += MomentCommentView_commentsTableBottomMargin
        }
        
        return height
    }
    
    static private func customLikesTagView(tagView:DWTagList!) {
        tagView.automaticResize = true
        tagView.labelMargin = 0
        tagView.horizontalPadding = 0
        tagView.verticalPadding = 0
        tagView.bottomMargin = 0
        tagView.textShadowColor = UIColor.clearColor()
        tagView.setTagBackgroundColor(UIColor.clearColor())
        tagView.setTagHighlightColor(UIColor(white: 0.7, alpha: 1))
        tagView.textColor = UIColor(red: 0.46, green: 0.53, blue: 0.71, alpha: 1)
        tagView.font = UIFont.systemFontOfSize(12)
        tagView.borderWidth = 0
        tagView.cornerRadius = 0
    }
    
    /**
     构建赞视图需要的tag集合
     
     - parameter tagView:
     - parameter placeLikeNames:
     - parameter seperateString: 各个tag的分割字符
     - returns: 返回创建的
     */
    static private func buildTagsWithLikeNames(likeNames: [String]?, seperateString: String? = ",") -> [String]? {
        
        if likeNames?.count > 0 {
            
            var likeNameTags = [String]()
            
            var index = 0
            for likeName in likeNames! {
                likeNameTags.append(likeName)
                if seperateString?.isEmpty == false && index < likeNames!.count - 1{
                    likeNameTags.append(seperateString!)
                }
                index += 1
            }
            return likeNameTags
        }
        
        return nil
    }

    /**
     计算liketagView的高度
     
     - parameter names:             赞的用户名称列表
     - parameter likesTagViewWidth: 赞的视图的宽度
     
     - returns: 计算结果
     */
    static private func caculateLikesTagViewHeightWithLikeUserNames(names: [String]? = nil, likesTagViewWidth: CGFloat? = 0) -> CGFloat {
        if names?.count > 0 {
            struct Static {
                static var onceToken : dispatch_once_t = 0
                static var sizingLikesTagView : DWTagList? = nil
            }
            dispatch_once(&Static.onceToken) {
                Static.sizingLikesTagView = DWTagList(frame: CGRectMake(0, 0, 100, 13))
                self.customLikesTagView(Static.sizingLikesTagView!)
            }
            
            var sizingTagViewFrame = Static.sizingLikesTagView!.frame
            if sizingTagViewFrame.size.width != likesTagViewWidth {
                sizingTagViewFrame.size.width = likesTagViewWidth!
                Static.sizingLikesTagView?.frame = sizingTagViewFrame
            }
            
            let builedTags = MomentCommentView.buildTagsWithLikeNames(names, seperateString:momentLikeTagSeperatorString)
            if builedTags == nil {
                Static.sizingLikesTagView?.setTags([String]())
            } else {
                Static.sizingLikesTagView?.setTags(builedTags)
            }
            
            return Static.sizingLikesTagView!.fittedSize().height
        }
        return 0
    }
    
    /**
     计算评论表格的高度
     
     - parameter comments:           评论列表
     - parameter commentsTableWidth: 评论表格的宽度
     
     - returns: 计算结果
     */
    static private func caculateCommentsTableHeightWithComments(comments: [[String: AnyObject]!]? = nil, commentsTableWidth: CGFloat = 0) -> CGFloat {
        
        if comments?.count > 0 {
            var height: CGFloat = 0
            
            for comment in comments! {
                height += MomentCommentCell.cellHeightWithData(comment, cellWidth: commentsTableWidth)
            }
            
            return height
        }
        return 0
    }
    
    
    private func setupMomentCommentView() {
        
        backgroundBoxImageView = UIImageView()
        self.addSubview(backgroundBoxImageView!)
        backgroundBoxImageView?.translatesAutoresizingMaskIntoConstraints = false
        backgroundBoxImageView?.image = UIImage(named: "Album_likes_comments_background")?.resizableImageWithCapInsets(UIEdgeInsetsMake(6, 15, 1, 1))
        
        likeIconView = UIImageView(image: UIImage(named: "AlbumLikeDarkGray"))
        self.addSubview(likeIconView!)
        likeIconView?.translatesAutoresizingMaskIntoConstraints = false
        
        likesTagView = DWTagList(frame: CGRectMake(0, 0, 100, 13))
        self.addSubview(likesTagView!)
        likesTagView!.translatesAutoresizingMaskIntoConstraints = false
        MomentCommentView.customLikesTagView(likesTagView!)
        likesTagView?.tagDelegate = self
        
        likesCommentsSeperatorView = UIView()
        self.addSubview(likesCommentsSeperatorView!)
        
        likesCommentsSeperatorView?.translatesAutoresizingMaskIntoConstraints = false
        likesCommentsSeperatorView?.backgroundColor = UIColor(white: 0.9, alpha: 1)
        
        commentsTable = UITableView(frame: CGRectZero, style: UITableViewStyle.Plain)
        self.addSubview(commentsTable!)
        
        commentsTable?.backgroundColor = UIColor.clearColor()
        commentsTable?.translatesAutoresizingMaskIntoConstraints = false
        commentsTable?.separatorStyle = UITableViewCellSeparatorStyle.None
        commentsTable?.showsVerticalScrollIndicator = false
        commentsTable?.scrollEnabled = false
        commentsTable?.registerClass(MomentCommentCell.self, forCellReuseIdentifier: "MomentCommentCell")
        commentsTable?.delegate = self
        commentsTable?.dataSource = self
        
        // 设置约束
        let views = ["backgroundBoxImageView":backgroundBoxImageView!, "likeIconView":likeIconView!, "likesTagView":likesTagView!, "likesCommentsSeperatorView":likesCommentsSeperatorView!, "commentsTable":commentsTable!]
        
        // 设置backgroundBoxImageView的约束
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[backgroundBoxImageView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[backgroundBoxImageView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        // 设置likeIconView和likesTagView的约束
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-4-[likeIconView]-2-[likesTagView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        self.addConstraint(NSLayoutConstraint(item: likeIconView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: MomentCommentView_likeIconTopMargin))
        
        self.addConstraint(NSLayoutConstraint(item: likesTagView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: MomentCommentView_likesTagViewTopMargin))
        
        likesTagViewHeightConstraint = NSLayoutConstraint(item: likesTagView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0, constant: 0)
        likesTagView?.addConstraint(likesTagViewHeightConstraint!)
        
        
        // 设置likesCommentsSeperatorView的约束
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-4-[likesCommentsSeperatorView]-4-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: views))
        
        likesCommentsSeperatorViewTopConstraint = NSLayoutConstraint(item: likesCommentsSeperatorView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: likesTagView!, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        self.addConstraint(likesCommentsSeperatorViewTopConstraint!)
        
        likesCommentsSeperatorViewHeightConstraint = NSLayoutConstraint(item: likesCommentsSeperatorView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0, constant: 0)
        likesCommentsSeperatorView?.addConstraint(likesCommentsSeperatorViewHeightConstraint!)
        
        // 设置commentsTable的约束
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[commentsTable]|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: views))
        
        commentsTableTopConstraint = NSLayoutConstraint(item: commentsTable!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: likesCommentsSeperatorView!, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 2)
        self.addConstraint(commentsTableTopConstraint!)
        
        commentsTableHeightConstraint = NSLayoutConstraint(item: commentsTable!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0, constant: 0)
        commentsTable?.addConstraint(commentsTableHeightConstraint!)
        
    }




}


let MomentCommentView_likesTagViewLittleThanShowView: CGFloat = 21
let MomentCommentView_likesTagViewTopMargin: CGFloat = 8
let MomentCommentView_likeIconTopMargin: CGFloat = 8
let MomentCommentView_likeIconLeftMargin: CGFloat = 4
let MomentCommentView_seperatorTopMargin: CGFloat = 0
let MomentCommentView_seperatorViewHeight: CGFloat = 0.5

let MomentCommentView_commentsTableTopMargin: CGFloat = 2
let MomentCommentView_commentsTableBottomMargin: CGFloat = 2

// 赞tag的分割字符
let momentLikeTagSeperatorString = ","

/**
 *  评论cell的代理协议
 */
@objc protocol MomentCommentCellDelegate {
    
    /**
     选中用户名字
     
     - parameter cell:
     - parameter didSelectUserName:
     */
    optional func momentCommentCell(cell: MomentCommentCell!, didSelectUserName: String!)
}

/**
 *  评论cell
 */
class MomentCommentCell: UITableViewCell, TTTAttributedLabelDelegate {
    
    static private let MomentCommentLabelFontSize: CGFloat = 12
    private let CustomDetectUserNameURLProtocol = "http://www.justdoit.com/"
    
    weak var delegate: MomentCommentCellDelegate?
    
    private var commentLabel: TTTAttributedLabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupMomentCommentCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     配置视图
     
     - parameter data:        数据
     - parameter cellWidth:   cell宽度
     */
    func configWithData(data: [String: AnyObject]? = nil, cellWidth: CGFloat? = 0) {
        
        let authorName = data?[MomentCommentViewCommentDataKey_authorName] as? String
        let atUserName = data?[MomentCommentViewCommentDataKey_atUserName] as? String
        
        let buildResult = MomentCommentCell.buildCommentTextWithData(data)
        let authorNameRange = buildResult.authorNameRange
        let atUserNameRange = buildResult.atUserNameRange
        let builedCommentText = buildResult.builedCommentText
        
        if builedCommentText.isEmpty == false {
            let attributedText = NSMutableAttributedString(string: builedCommentText, attributes: nil)
            attributedText.setAttributes([NSForegroundColorAttributeName: UIColor.blueColor()], range: authorNameRange)
            attributedText.setAttributes([NSForegroundColorAttributeName: UIColor.blueColor()], range: atUserNameRange)
            commentLabel?.setText(attributedText, afterInheritingLabelAttributesAndConfiguringWithBlock: { (mutableAttributedString) -> NSMutableAttributedString! in
                return mutableAttributedString
            })
            
            if authorNameRange.location != NSNotFound {
                let linkUrl = (CustomDetectUserNameURLProtocol + authorName!).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
                let link = NSURL(string:linkUrl!)
                commentLabel?.addLinkToURL(link!, withRange: authorNameRange)
            }
            
            if atUserNameRange.location != NSNotFound {
                commentLabel?.addLinkToURL(NSURL(string: ("\(CustomDetectUserNameURLProtocol)" + "\(atUserName)")), withRange: atUserNameRange)
            }
            
        } else {
            commentLabel?.setText(nil)
        }
    }
    
    static private func customCommentLabel(commentLabel:TTTAttributedLabel?) {
        commentLabel?.font = UIFont.systemFontOfSize(MomentCommentLabelFontSize)
        commentLabel?.textColor = UIColor.darkGrayColor()
        commentLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        commentLabel?.numberOfLines = 0
    }
    
    
    /**
     计算高度
     
     - parameter data:      评论数据
     - parameter cellWidth: cell宽度
     */
    static func cellHeightWithData(data: [String: AnyObject]? = nil, cellWidth: CGFloat = 0) -> CGFloat {
        
        var height: CGFloat = 0
        let commentLabelWidth = cellWidth - MomentCommentCellLeftpadding - MomentCommentCellRightpadding
        
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var sizingLabel : TTTAttributedLabel? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.sizingLabel = TTTAttributedLabel(frame: CGRectMake(0, 0, 200, MomentCommentCellMinHeight))
            self.customCommentLabel(Static.sizingLabel)
        }
        
        var sizingLabelFrame = Static.sizingLabel!.frame
        if sizingLabelFrame.size.width != commentLabelWidth || sizingLabelFrame.size.height != CGFloat.max {
            sizingLabelFrame.size.width = commentLabelWidth
            sizingLabelFrame.size.height = CGFloat.max
            Static.sizingLabel?.frame = sizingLabelFrame
        }
        
        Static.sizingLabel?.text = buildCommentTextWithData(data).builedCommentText
        Static.sizingLabel?.sizeToFit()
        
        let labelHeight = Static.sizingLabel!.frame.height
        
        if labelHeight > 0 {
            height += (labelHeight + MomentCommentCellTopPadding + MomentCommentCellBottomPadding)
        }
        
        return height > MomentCommentCellMinHeight ? height:MomentCommentCellMinHeight
    }
    
    /**
     构建评论内容，返回包含评论者名字的range、@用户名字的range和构建的内容的元组
     
     - parameter data:
     
     - returns: 包含评论者名字的range、@用户名字的range和构建的内容的元组
     */
    static private func buildCommentTextWithData(data: [String: AnyObject]?) -> (authorNameRange:NSRange, atUserNameRange:NSRange, builedCommentText:String) {
        
        let authorName = data?[MomentCommentViewCommentDataKey_authorName] as? String
        let atUserName = data?[MomentCommentViewCommentDataKey_atUserName] as? String
        let textContent = data?[MomentCommentViewCommentDataKey_textContent] as? String
        
        var builedCommentText = ""
        
        var authorNameRange = NSMakeRange(NSNotFound, 0)
        if authorName?.isEmpty == false {
            builedCommentText += authorName!
            authorNameRange.location = 0
            authorNameRange.length = (authorName!).characters.count
        }
        
        var atUserNameRange = NSMakeRange(NSNotFound, 0)
        if atUserName?.isEmpty == false {
            builedCommentText += "回复"
            
            atUserNameRange.location = builedCommentText.characters.count
            atUserNameRange.length = (atUserName!).characters.count
            
            builedCommentText += atUserName!
        }
        
        if builedCommentText.isEmpty == false {
            builedCommentText += ":"
        }
        
        if textContent?.isEmpty == false {
            builedCommentText += textContent!
        }
        
        return (authorNameRange, atUserNameRange, builedCommentText)
    }
    
    
    private func setupMomentCommentCell() {
        self.backgroundColor = UIColor.clearColor()
        
        commentLabel = TTTAttributedLabel(frame: self.contentView.bounds)
        self.contentView.addSubview(commentLabel!)
        
        commentLabel?.backgroundColor = UIColor.clearColor()
        MomentCommentCell.customCommentLabel(commentLabel)
        
        commentLabel?.delegate = self
        commentLabel?.linkAttributes = [NSUnderlineStyleAttributeName:false, kCTForegroundColorAttributeName: UIColor(red: 0.46, green: 0.53, blue: 0.71, alpha: 1).CGColor]
        commentLabel?.activeLinkAttributes = [kTTTBackgroundFillColorAttributeName:UIColor(white: 0.7, alpha: 1).CGColor, NSUnderlineStyleAttributeName:false]
        
        commentLabel!.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["commentLabel":commentLabel!]
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-4-[commentLabel]-4-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[commentLabel]|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: views))
    }
    
    // MARK: - TTTAttributedLabelDelegate
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        if let urlString = url.absoluteString.stringByRemovingPercentEncoding {
            let selectUserName = urlString.substringFromIndex(urlString.startIndex.advancedBy(CustomDetectUserNameURLProtocol.characters.count))
            if selectUserName.isEmpty == false {
                delegate?.momentCommentCell?(self, didSelectUserName: selectUserName)
            }
        }
    }
}



let MomentCommentCellTopPadding: CGFloat = 2
let MomentCommentCellBottomPadding: CGFloat = 2
let MomentCommentCellLeftpadding: CGFloat = 4
let MomentCommentCellRightpadding: CGFloat = 4
let MomentCommentCellMinHeight: CGFloat = 16



// 动态的评论数据，每条评论的具体信息再通过评论的数据key获取
let MomentCommentViewMomentDataKey_comments = "MomentCommentViewMomentDataKey_comments"
// 动态的点赞用户
let MomentCommentViewMomentDataKey_likeUserNames = "MomentCommentViewMomentDataKey_likeUserNames"

// 评论的数据key
let MomentCommentViewCommentDataKey_authorName = "MomentCommentViewCommentDataKey_authorName"
let MomentCommentViewCommentDataKey_atUserName = "MomentCommentViewCommentDataKey_atUserName"
let MomentCommentViewCommentDataKey_textContent = "MomentCommentViewCommentDataKey_textContent"


