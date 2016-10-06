//
//  HTTP.swift
//  whplue07InAppPerchaseDemo
//
//  Created by Chieh-Chun Li on 2016/10/5.
//  Copyright © 2016年 Daniel.LeeJJingLee. All rights reserved.
//

import Foundation

class HTTPAction: NSObject, NSURLSessionDelegate {
    
    
    
    var serverURL : String? = "https://192.168.0.186:9988";
    
    func setURL(url : String)
    {
        serverURL = url;
    }
    
    func httpPostToSever(Data : NSData, callBack : (NSData, NSURLResponse, NSError)->Void) {
        
        
        
        
        let receiptdata: NSString = Data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        //println(receiptdata)
        
        print("In post server. string : \(receiptdata)");
        
        let request = NSMutableURLRequest(URL: NSURL(string: serverURL!)!)
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil);//NSURLSession.sharedSession()
        
        let bodyJSON = ["receipt" : receiptdata];
        var bodyData:NSData = NSData(); //NSKeyedArchiver.archivedDataWithRootObject(bodyJSON);
        
        do{
            bodyData = try NSJSONSerialization.dataWithJSONObject(bodyJSON, options: NSJSONWritingOptions.PrettyPrinted);
        }catch let err as  NSError
        {
            print(err);
        }
        
        request.HTTPMethod = "POST";
        
        //var err: NSError?
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type");
        request.addValue("application/json",forHTTPHeaderField: "Accept")
        
        request.HTTPBody = bodyData;
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            //let err: NSError?
            
            //callBack(data!, response!, error!);
            print("back : \(data)");
            
        })
        
        task.resume()
    }
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        print("success");
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential = NSURLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, credential)
        }
    }
    
    
}