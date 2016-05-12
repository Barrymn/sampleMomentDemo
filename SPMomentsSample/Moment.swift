//
//  Moment.swift
//  SPMomentsSample
//
//  Created by Barry Ma on 2016-05-05.
//  Copyright © 2016 BarryMa. All rights reserved.
//

import UIKit

class Moment: SPModel {

    var momentId: Int?
    var content: String?
    var pictures: [String]?
    var author: User?
    var comments: [Comment]?
    var createdDate: NSDate?
    var likedUsers: [User]?
    //var atUsers: [User]?
    
    override func update(id: Int) {
        momentId = id
        content = "Hey guys! This is the content of Moment #" + String(id) + "! "
        createdDate = NSDate()
        
        //Randomly generate comments
        let nComments = Int(arc4random_uniform(9))
        comments = []
        for _ in 0...nComments {
            self.comments?.append(Comment(data: id))
        }
        
        //Randomly generate pictures
        let nPictures = Int(arc4random_uniform(9))
        pictures = []
        for _ in 0...nPictures {
            self.pictures?.append("photo")
        }
        
        //Randomly generate content
        let temp = content
        let nContents = Int(arc4random_uniform(6))
        for _ in 0...nContents {
            self.content? += temp!
        }
        
        author = User(data: id)
        likedUsers = []
        
    }
}
