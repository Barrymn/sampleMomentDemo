//
//  SPModel.swift
//  SPMomentsSample
//
//  Created by Barry Ma on 2016-05-05.
//  Copyright © 2016 BarryMa. All rights reserved.
//

import UIKit

public class SPModel: NSObject {
    init(data: Int) {
        super.init()
        //update(data)
        update(data)
    }
    
    private convenience override init() {
        self.init()
    }
    
//    func update(data: JSON){
//        
//    }
    
    func update(id: Int) {
        
    }
    
    func toBool(datum: String?) -> Bool{
        if datum == "true" || datum == "True"{
            return true
        }else{
            return false
        }
    }
    
    //    "createdTs": "2016-02-18T21:28:48.507Z"
    //    "updatedTs": "2016-02-18T21:28:48.507Z"
    
    //    func toDate(datum: String?) -> NSDate{
    //
    //        return NSDate()
    //    }
    
    func toDate(datum: String?) -> NSDate{
        
        let dateFor: NSDateFormatter = NSDateFormatter()
        dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let myDate: NSDate = dateFor.dateFromString(datum!) {
            return myDate
        }
        else {
            return NSDate()
        }
        
    }
    
    func dateFormatted(myDate: NSDate) -> String {
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd/M/yyyy, H:mm"
        
        return formatter.stringFromDate(myDate)
    }
}

