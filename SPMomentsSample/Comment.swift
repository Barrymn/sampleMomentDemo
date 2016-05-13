//
//  Comment.swift
//  SPMomentsSample
//
//  Created by Barry Ma on 2016-05-05.
//  Copyright © 2016 BarryMa. All rights reserved.
//

import UIKit

class Comment: SPModel {
    
    var momentId: Int?
    var content: String?
    var creator: User?
    var atUser: User?
    
    override func update(id: Int) {
        momentId = id
        content = "Hey guys! This is a comment of this moment!"
        
        //Randomly generate a creator
        creator = User(data: Int(arc4random_uniform(9)))
        
//        if(Int(arc4random_uniform(3)) == 1){
//            atUser = User(data: Int(arc4random_uniform(10) + 1))
//        }
        
        //Randomly generate content
        let temp = content
        let nContent = Int(arc4random_uniform(3))
        for _ in 0...nContent {
            content? += temp!
        }
    }

}
