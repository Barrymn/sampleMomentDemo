//
//  User.swift
//  SPMomentsSample
//
//  Created by Barry Ma on 2016-05-05.
//  Copyright © 2016 BarryMa. All rights reserved.
//

import UIKit

class User: SPModel {
    
    var userId: Int?
    var userName: String?
    
    override func update(id: Int) {
        userId = id
        userName = "TestUser" + String(id)
    }
}
