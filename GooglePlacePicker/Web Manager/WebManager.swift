//
//  WebManager.swift
//  Jiveda Doctor App
//
//  Created by eHealthCard on 11/09/17.
//  Copyright © 2017 NiboTechnologies. All rights reserved.
//

import UIKit

class WebManager: NSObject {
    let googleKey = "AIzaSyCAvBmDPvHCKWw7_B5mTXNl7y5ssgg8WEI"
    let Mainurl = "https://maps.googleapis.com/maps/api/place/"
    static let shareInstance = WebManager()
    
    func CallGetAPI(urlstring: String, delegate: AnyObject, onSuccess:Selector, onFailure:Selector ) -> Void {
        let str : String = String(format:"%@%@%@",Mainurl,urlstring,googleKey)
        let url = NSURL(string:str.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // get your json data
        let task = session.dataTask(with: request as URLRequest, completionHandler:
        {(data,response,error) in
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
                print("error")
                let json = NSDictionary.init(object: error?.localizedDescription as Any, forKey: "message" as NSCopying)
                
                delegate.performSelector(onMainThread: onFailure, with: json, waitUntilDone: true)
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: Any]
                if json != nil && ((json?["success"]) != nil) && json?["success"] as! Bool == true{
                    delegate.performSelector(onMainThread: onSuccess, with: json, waitUntilDone: true)
                }else if json != nil && ((json?["success"]) == nil) {
                    
                    delegate.performSelector(onMainThread: onSuccess, with: json, waitUntilDone: true)
                }else{
                    delegate.performSelector(onMainThread: onFailure, with:json, waitUntilDone: true)
                }
                
            } catch {
                let json = NSDictionary.init(object: error.localizedDescription as Any, forKey: "message" as NSCopying)
                
                delegate.performSelector(onMainThread: onFailure, with: json, waitUntilDone: true)
            }
        });
        
        task.resume()
    }
}
