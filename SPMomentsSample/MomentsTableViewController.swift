//
//  MomentsTableViewController.swift
//  SPMomentsSample
//
//  Created by Barry Ma on 2016-05-03.
//  Copyright © 2016 BarryMa. All rights reserved.
//

import UIKit
import Kingfisher
import Toucan
import SVProgressHUD
import UpRefreshControl
import UpLoadMoreControl
import LvModelWindow

class MomentsTableViewController: UITableViewController, UITextFieldDelegate, momentCellDelegate, momentCommentViewDelegate, LvModelWindowDelegate {
    
    let currentUser: User = User(data: 0)
    
    class momentsHeaderView: UIView {
        var receivedMessageCount: Int = 0 {
            didSet {
                receivedMessageCountContaintViewHeightConstraint?.constant = receivedMessageCount > 0 ?40:0
                receivedMessageCountButton?.setTitle("收到 \(receivedMessageCount) 条新消息", forState: UIControlState.Normal)
            }
        }
        private(set) var backgroundImageView:UIImageView?
        private(set) var avatarView:UIImageView?
        private var avatarContaintView:UIView?
        
        private var receivedMessageCountContaintView: UIView?
        private var receivedMessageCountButton: UIButton?
        private var receivedMessageCountContaintViewHeightConstraint: NSLayoutConstraint?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            backgroundImageView = UIImageView()
            self.addSubview(backgroundImageView!)
            backgroundImageView?.translatesAutoresizingMaskIntoConstraints = false
            
            avatarContaintView = UIView()
            self.addSubview(avatarContaintView!)
            avatarContaintView?.backgroundColor = UIColor.whiteColor()
            avatarContaintView?.translatesAutoresizingMaskIntoConstraints = false
            
            avatarView = UIImageView()
            avatarContaintView?.addSubview(avatarView!)
            avatarView?.contentMode = UIViewContentMode.ScaleAspectFit
            avatarView?.clipsToBounds = true
            avatarView?.translatesAutoresizingMaskIntoConstraints = false
            avatarView?.image = UIImage(named: "roleAvatar")
            
            receivedMessageCountContaintView = UIView()
            self.addSubview(receivedMessageCountContaintView!)
            receivedMessageCountContaintView?.translatesAutoresizingMaskIntoConstraints = false
            receivedMessageCountContaintView?.clipsToBounds = true
            
            receivedMessageCountButton = UIButton(type: UIButtonType.Custom)
            receivedMessageCountContaintView?.addSubview(receivedMessageCountButton!)
            receivedMessageCountButton?.translatesAutoresizingMaskIntoConstraints = false
            receivedMessageCountButton?.setTitleColor(UIColor(red: 0.46, green: 0.53, blue: 0.71, alpha: 1), forState: UIControlState.Normal)
            receivedMessageCountButton?.backgroundColor = UIColor.clearColor()
            receivedMessageCountButton?.addTarget(self, action: "receivedMessageCountButtonClicked", forControlEvents: UIControlEvents.TouchUpInside)
            
            let views = ["backgroundImageView":backgroundImageView!, "avatarContaintView":avatarContaintView!, "avatarView":avatarView!, "receivedMessageCountContaintView":receivedMessageCountContaintView!, "receivedMessageCountButton":receivedMessageCountButton!]
            
            let constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[backgroundImageView]-20-[receivedMessageCountContaintView(0)]|", options: [NSLayoutFormatOptions.AlignAllLeading, NSLayoutFormatOptions.AlignAllTrailing], metrics: nil, views: views)
            self.addConstraints(constraints)
            for constraint in constraints {
                if constraint.firstItem as? UIView == receivedMessageCountContaintView && constraint.firstAttribute == NSLayoutAttribute.Height {
                    receivedMessageCountContaintViewHeightConstraint = constraint
                    break
                }
            }
            
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[backgroundImageView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[avatarContaintView(80)]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[avatarContaintView(80)][receivedMessageCountContaintView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            
            avatarContaintView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[avatarView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            avatarContaintView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[avatarView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            
            receivedMessageCountContaintView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-4-[receivedMessageCountButton]-4-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            
            receivedMessageCountContaintView?.addConstraint(NSLayoutConstraint(item: receivedMessageCountButton!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: receivedMessageCountContaintView!, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
            
            receivedMessageCountButton?.addConstraint(NSLayoutConstraint(item: receivedMessageCountButton!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0, constant: 180))
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            avatarContaintView?.layer.borderColor = UIColor(white: 0.7, alpha: 1).CGColor
            avatarContaintView?.layer.borderWidth = 0.5
            
            receivedMessageCountButton?.layer.borderColor = UIColor(red: 0.46, green: 0.53, blue: 0.71, alpha: 1).CGColor
            receivedMessageCountButton?.layer.borderWidth = 0.5
            receivedMessageCountButton?.layer.cornerRadius = 4
        }
        
        @objc private func receivedMessageCountButtonClicked() {
            receivedMessageCount = 0
            // TODO: 同时发布点击通知
        }
    }
    
    
    private var momentsHeader: momentsHeaderView?
    //private var pengYQHeaderAvatarViewRetrieveImageTask: RetrieveImageTask?
    //private var avatarBarButtonRetrieveImageTask: RetrieveImageTask?
    
    private var upRefreshControl:UpRefreshControl?
    private var upLoadMoreControl:UpLoadMoreControl?
    
    private struct MomentOperateIndexPaths {
        var operateMomentIndexPath: NSIndexPath?
        var operateCommentIndexPath: NSIndexPath?
        
        init(operateMomentIndexPath: NSIndexPath, operateCommentIndexPath: NSIndexPath? = nil) {
            self.operateMomentIndexPath = operateMomentIndexPath
            self.operateCommentIndexPath = operateCommentIndexPath
        }
    }
    
    private var momentOperatingIndexPaths: MomentOperateIndexPaths?   // 正在操作的索引
    
    lazy private var momentOperateView: MomentOperateView = {
        let operateView = MomentOperateView()
        operateView.likeButton?.addTarget(self, action: "doOperateViewLike", forControlEvents: UIControlEvents.TouchUpInside)
        operateView.commentButton?.addTarget(self, action: "doOperateViewComment", forControlEvents: UIControlEvents.TouchUpInside)
        
        return operateView
    }()
    
    lazy private var MomentOperateModelWindow: LvModelWindow = {
        let modelWindow = LvModelWindow(preferStatusBarHidden: false, supportedOrientationPortrait: true, supportedOrientationPortraitUpsideDown: true, supportedOrientationLandscapeLeft: true, supportedOrientationLandscapeRight: true)
        
        modelWindow.windowRootView.userInteractionEnabled = true
        modelWindow.windowRootView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissMomentOperateModelWindow"))
        
        modelWindow.modelWindowDelegate = self
        modelWindow.windowRootView.addSubview(self.momentOperateView)
        
        return modelWindow
    }()
    
    //private var roleSelectVC: WSRoleSelectVC?
    
    var moments = [Moment]()
    
    //private var loginUser: AVUser?
    
    private var firstAppear = false
    
    // 假评论输入框
    lazy private var fakeCommentInputField: UITextField = {
        
        let fakeTextField = UITextField(frame: CGRectZero)
        fakeTextField.inputAccessoryView = self.fakeCommentInputFieldAccessoryView
        return fakeTextField
    }()
    
    lazy private var fakeCommentInputFieldAccessoryView: UIView = {
        
        let inputAccessoryView = UIView(frame: CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen().applicationFrame), 44))
        inputAccessoryView.backgroundColor = UIColor(white: 0.91, alpha: 1)
        
        let commentTextField = self.realCommentInputField
        inputAccessoryView.addSubview(commentTextField)
        
        commentTextField.translatesAutoresizingMaskIntoConstraints = false
        
        inputAccessoryView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[commentTextField]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["commentTextField" : commentTextField]))
        inputAccessoryView.addConstraint(NSLayoutConstraint(item: commentTextField, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: inputAccessoryView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        return inputAccessoryView
    }()
    
    // 真正的评论输入框
    lazy private var realCommentInputField: UITextField = {
        let commentInputField = UITextField()
        commentInputField.delegate = self
        commentInputField.returnKeyType = UIReturnKeyType.Send;
        commentInputField.spellCheckingType = UITextSpellCheckingType.No
        commentInputField.autocorrectionType = UITextAutocorrectionType.No
        commentInputField.borderStyle = UITextBorderStyle.RoundedRect
        
        return commentInputField
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(MomentsTableViewCell.self, forCellReuseIdentifier: "MomentsTableViewCell")
        
        moments.append(Moment(data: 0))
        moments.append(Moment(data: 1))
        moments.append(Moment(data: 2))
        
        self.clearsSelectionOnViewWillAppear = false
        self.navigationItem.title = "Moments"
    
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Camera, target: self, action: "toMakeAMoment")
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(white: 0.6, alpha: 1)
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        momentsHeader = momentsHeaderView(frame: CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 240))
        self.tableView.tableHeaderView = momentsHeader
        
        momentsHeader?.backgroundImageView?.userInteractionEnabled = true
        momentsHeader?.backgroundImageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapMomentsBackgroundView"))
        momentsHeader?.backgroundImageView?.image = UIImage(named: "backgroundGray")
        
        momentsHeader?.avatarView?.userInteractionEnabled = true
        momentsHeader?.avatarView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapMomentsHeaderAvatarView"))
        
        upRefreshControl = UpRefreshControl(scrollView: self.tableView, action: { [weak self] (control) -> Void in
            
            let strongSelf = self
            if strongSelf == nil {
                return
            }
            
            strongSelf!.tableView.reloadData()
            
            //Loading Simulation
            let seconds = 2.0
            let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                strongSelf!.upRefreshControl?.finishedLoadingWithStatus("", delay: 0)
            })
            
        })
        tableView.addSubview(upRefreshControl!)
        
        upLoadMoreControl = UpLoadMoreControl(scrollView: self.tableView, action: {
            
            [weak self] (control) -> Void in
            
            let strongSelf = self
            if strongSelf == nil {
                return
            }
            
            //Loading Simulation
            let seconds = 2.0
            let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                strongSelf!.upLoadMoreControl?.finishedLoadingWithStatus("", delay: 0)
            })

        })
        tableView.addSubview(upLoadMoreControl!)

        tableView.addSubview(fakeCommentInputField)
    }
    

    override func didReceiveMemoryWarning() {
        moments.removeAll(keepCapacity: false)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstAppear == false {
            firstAppear = true
            
            SVProgressHUD.showWithStatus("玩命加载ing...", maskType: SVProgressHUDMaskType.Black)
            
            //Loading Simulation
            let seconds = 3.0
            let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                SVProgressHUD.dismiss()
            })
            self.tableView.reloadData()
        }
    }

    

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moments.count
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height = MomentsTableViewCell.cellHeightWithData(buildMomentCellDataWithMoment(moments[indexPath.row]), cellWidth: CGRectGetWidth(tableView.bounds))
        return height
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MomentsTableViewCell", forIndexPath: indexPath) as! MomentsTableViewCell
        
        cell.showTopSeperator = (indexPath.row != 0)
        cell.delegate = self
        cell.configWithData(buildMomentCellDataWithMoment(moments[indexPath.row]), cellWidth: CGRectGetWidth(tableView.bounds))
        
        return cell
    }
    
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        upRefreshControl?.scrollViewDidScroll()
        upLoadMoreControl?.scrollViewDidScroll()
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        upRefreshControl?.scrollViewDidEndDragging()
        upLoadMoreControl?.scrollViewDidEndDragging()
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        commentFiledResignFirstResponder()
    }
    

    // MARK: - momentCellDelegate
    
    func momentCell(momentCell: MomentsTableViewCell, didClickMoreOprateButton: UIButton) {
        
        print("点击了操作图标，弹出操作视图")
        if let operateCellIndexPath = tableView.indexPathForRowAtPoint(tableView.convertPoint(CGPointZero, fromView: momentCell)) {
            print("操作所在索引: \(operateCellIndexPath.row)")
            
            // 记录操作所在元素的索引
            if momentOperatingIndexPaths?.operateMomentIndexPath != operateCellIndexPath {
                realCommentInputField.text = nil
            }
            
            momentOperatingIndexPaths = MomentOperateIndexPaths(operateMomentIndexPath: operateCellIndexPath)
            realCommentInputField.placeholder = "说点什么?"
            
            let buttonBounds = didClickMoreOprateButton.bounds
            let operateButnCenterYOriginPointAtRootView = tableView.window!.convertPoint(CGPointMake(CGRectGetMinX(buttonBounds), CGRectGetMidY(buttonBounds)), fromView: didClickMoreOprateButton)
            
            let operateViewIntrinsicContentSize = self.momentOperateView.intrinsicContentSize()
            self.momentOperateView.frame = CGRectMake(operateButnCenterYOriginPointAtRootView.x - operateViewIntrinsicContentSize.width, operateButnCenterYOriginPointAtRootView.y - operateViewIntrinsicContentSize.height/CGFloat(2), operateViewIntrinsicContentSize.width, operateViewIntrinsicContentSize.height)
            
            self.MomentOperateModelWindow.showWithAnimated(true)
        }
    }
    
    func momentCell(momentCell: MomentsTableViewCell, didSelectPhotoViewAtIndex: Int) {
        // TODO:
        print("点击了图片, index:\(didSelectPhotoViewAtIndex)")
    }
    
    
    
    // MARK: - momentCommentViewDelegate
    
    func momentCommentView(view: MomentCommentView, didSelectCommentIndex: Int) {
        
        // 获取点击的moment所在索引
        let momentIndexPath = tableView.indexPathForRowAtPoint(tableView.convertPoint(CGPointZero, fromView: view))
        
        if momentIndexPath != nil && moments.count > momentIndexPath?.row {
            
            var placeholder = "回复"
            
            let operateMoment = moments[momentIndexPath!.row]
            let operateMomentComments = operateMoment.comments
            
            if operateMomentComments?.count > didSelectCommentIndex {
                let operateComment = operateMomentComments![didSelectCommentIndex]
                if let commentUserName = operateComment.creator?.userName {
                    placeholder += (" " + commentUserName)
                }
            }
            placeholder += ":"
            
            realCommentInputField.text = nil
            realCommentInputField.placeholder = placeholder
            
            // 改变操作行
            momentOperatingIndexPaths = MomentOperateIndexPaths(operateMomentIndexPath: momentIndexPath!, operateCommentIndexPath: NSIndexPath(forRow: didSelectCommentIndex, inSection: 0))
            
            if (fakeCommentInputField.becomeFirstResponder()) {
                realCommentInputField.becomeFirstResponder()
            }
        }
    }
    
    func momentCommentShowView(view: MomentCommentView, didSelectCommentUserName: String) {
        // TODO:
        print("didSelectCommentUserName: \(didSelectCommentUserName)")
    }
    
    func momentCommentShowView(view: MomentCommentView, didSelectLikeUserName: String, atIndex: Int) {
        // TODO:
        print("didSelectLikeUserName: \(didSelectLikeUserName)")
    }
    
    
    // MARK: - LvModelWindowDelegate
    
    func modelWindowDidShow(modelWindow: LvModelWindow!) {
        
    }
    
    func modelWindowDidDismiss(modelWindow: LvModelWindow!) {
        
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == realCommentInputField {
            
            commentFiledResignFirstResponder()
            let comment = textField.text
            
            if comment != nil && comment!.isEmpty == false {
                
                let momentOperatingIndexPath = momentOperatingIndexPaths?.operateMomentIndexPath
                
                if momentOperatingIndexPath != nil && moments.count > momentOperatingIndexPath!.row {
                    let operateMoment = moments[momentOperatingIndexPath!.row]
                    let newComment = Comment(data: operateMoment.momentId!)
                    newComment.content = comment
                    newComment.creator = currentUser
                    
                    if let momentCommentingIndexPath = momentOperatingIndexPaths?.operateCommentIndexPath {
                        let operateMomentComments = operateMoment.comments
                        if operateMomentComments?.count > momentCommentingIndexPath.row {
                            let operateComment = operateMomentComments![momentCommentingIndexPath.row]
                            newComment.atUser = operateComment.creator
                        }
                    }
                    
                    operateMoment.comments?.append(newComment)
                    self.tableView.reloadRowsAtIndexPaths([momentOperatingIndexPath!], withRowAnimation: UITableViewRowAnimation.None)
                    
                    
                    realCommentInputField.text = nil
                }
            }
        }
        return true
    }
    
    
    private func commentFiledResignFirstResponder() {
        if realCommentInputField.isFirstResponder() {
            realCommentInputField.resignFirstResponder()
        }
        if fakeCommentInputField.isFirstResponder() {
            fakeCommentInputField.resignFirstResponder()
        }
    }
    
    
    /**
     根据动态信息创建cell需要的数据
     
     - parameter moment:
     
     - returns:
     */
    private func buildMomentCellDataWithMoment(moment: Moment) -> [String: AnyObject] {
        
        
        var cellData = [String: AnyObject]()
        
        if let mContent = moment.content {
            cellData[momentCellMomentDataKey_textContent] = mContent
        }
        
        if let mPictures = moment.pictures {
            var photoURLs = [String]()
            for str in mPictures {
                photoURLs.append(str)
            }
            cellData[momentCellMomentDataKey_photoURLs] = photoURLs
        }
        
        if let mAuthor = moment.author {
            if let authorName = mAuthor.userName {
                cellData[momentCellMomentDataKey_authorName] = authorName
                cellData[momentCellMomentDataKey_avatarURL] = "Random Avatar"
            }
        }
        
        cellData[momentCellMomentDataKey_createDate] = moment.createdDate
        
        // 设置评论
        if let comments = moment.comments {
            var commentsData = [[String: AnyObject]]()
            
            for comment in comments {
                var commentData = [String: AnyObject]()
                
                if let commentAuthorRoleName = comment.creator?.userName {
                    commentData[momentCellCommentDataKey_authorName] = commentAuthorRoleName
                }
                
                if let commentAtUserRoleName = comment.atUser?.userName {
                    commentData[momentCellCommentDataKey_atUserName] = commentAtUserRoleName
                }
                
                if let commentText = comment.content {
                    commentData[momentCellCommentDataKey_textContent] = commentText
                }
                
                commentsData.append(commentData)
            }
            
            cellData[momentCellMomentDataKey_comments] = commentsData
        }
        
        if let mLikes = moment.likedUsers {
            var likeUserRoleNames = [String]()
            
            for mLike in mLikes {
                if let roleName = mLike.userName {
                    likeUserRoleNames.append(roleName)
                }
            }
            
            cellData[momentCellMomentDataKey_likeUserNames] = likeUserRoleNames
        }
        
        return cellData
    }


    // 到发推页面
    @objc private func toMakeAMoment() {
        print("到发推页面")
        //self.presentViewController(UINavigationController(rootViewController: CreateMomentVC()), animated: true, completion: nil)
    }
    
    @objc private func tapMomentsBackgroundView() {
        print("到选取背景照片页面")
    }
    
    @objc private func tapMomentsHeaderAvatarView() {
        print("到选取头像照片页面")
    }
    
    /**
     处理点赞
     */
    @objc private func doOperateViewLike() {
        
        print("点击了赞按钮")
        
        MomentOperateModelWindow.dismissWithAnimated(true)
        
        let momentOperatingIndexPath = momentOperatingIndexPaths?.operateMomentIndexPath
        
        if momentOperatingIndexPath != nil && moments.count > momentOperatingIndexPath!.row {
            let operateMoment = moments[momentOperatingIndexPath!.row]

            operateMoment.likedUsers?.append(User(data: 0))
            self.tableView.reloadRowsAtIndexPaths([momentOperatingIndexPath!], withRowAnimation: UITableViewRowAnimation.None)

        }
    }
    
    /**
     处理评论
     */
    @objc private func doOperateViewComment() {
        
        print("点击了评论按钮")
        
        MomentOperateModelWindow.dismissWithAnimated(true)
        
        let momentOperatingIndexPath = momentOperatingIndexPaths?.operateMomentIndexPath
        
        if momentOperatingIndexPath != nil && moments.count > momentOperatingIndexPath!.row {
            if fakeCommentInputField.becomeFirstResponder() {
                realCommentInputField.becomeFirstResponder()
            }
        }
    }
    
    @objc private func dismissMomentOperateModelWindow() {
        MomentOperateModelWindow.dismissWithAnimated(true)
    }



}


let tableVCMomentPageNumber = 5