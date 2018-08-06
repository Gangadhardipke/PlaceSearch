//
//  PlaceDetailModel.swift
//  GooglePlacePicker
//
//  Created by king on 8/5/18.
//  Copyright © 2018 gangadhar. All rights reserved.
//

import UIKit

class PlaceDetailModel: NSObject {
    var icon : String!
    var id : String!
    var international_phone_number : String!
    var name : String!
    var place_id : String!
    var url : String!
    var reference : String!
    var reviews = [Reviews]()
    var scope : String!
    var types : [String] = []
    var formatted_address : String!
    var website : String!
}
class Reviews : NSObject{
    var author_name : String!
    var author_url : String!
    var profile_photo_url : String!
    var rating : String!
    var relative_time_description : String!
    var text : String!
    var time : String!
}
