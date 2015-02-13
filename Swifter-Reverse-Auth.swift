// Swifter-Reverse-Auth.swift
//
// Copyright (c) 2015 Gurpartap Singh (http://github,com/Gurpartap)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// Usage:
//
// let TWITTER_CONSUMER_KEY = ""
// let TWITTER_CONSUMER_SECRET_KEY = ""
// 
// let twitterAccount = ... // An ACAccount instance.
// let swifter = Swifter(consumerKey: TWITTER_CONSUMER_KEY, consumerSecret: TWITTER_CONSUMER_SECRET_KEY)
//
// // Step 1
// swifter.postReverseOAuthTokenRequest({ (authenticationHeader) -> Void in
//     let swifterAPIOS = Swifter(account: twitterAccount)
//
//     // Step 2
//     swifterAPIOS.getAccountVerifyCredentials(false, skipStatus: false, success: { (myInfo) -> Void in
//
//         // Step 3
//         swifterAPIOS.postReverseAuthAccessTokenWithAuthenticationHeader(authenticationHeader, success: { (accessToken, response) -> Void in
//
//             println("key: \(accessToken?.key) secret: \(accessToken?.secret)")
//
//             }, failure: { (error) -> Void in
//                 println("postReverseAuthAccessTokenWithAuthenticationHeader error: \(error)")
//         })
//
//         }, failure: { (error) -> Void in
//             println("getAccountVerifyCredentials error: \(error)")
//     })
//
//
//     }, failure: { (error) -> Void in
//         println("postReverseOAuthTokenRequest error: \(error)")
// })

import Foundation

#if os(iOS)
    import SwifteriOS
#else
    import SwifterOSX
#endif


let swifterApiURL = NSURL(string: "https://api.twitter.com")!


public extension Swifter {
    
    public func postReverseOAuthTokenRequest(success: (authenticationHeader: String) -> Void, failure: FailureHandler?) {
        let path = "/oauth/request_token"
        
        var parameters =  Dictionary<String, AnyObject>()
        parameters["x_auth_mode"] = "reverse_auth"
        
        self.client.post(path, baseURL: swifterApiURL, parameters: parameters, uploadProgress: nil, downloadProgress: nil, success: { data, response in
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)!
            success(authenticationHeader: responseString)
        }, failure: failure)
    }
    
    public func postReverseAuthAccessTokenWithAuthenticationHeader(authenticationHeader: String, success: TokenSuccessHandler, failure: FailureHandler?) {
        let path =  "/oauth/access_token"
        
        let shortHeader = authenticationHeader.stringByReplacingOccurrencesOfString("OAuth ", withString: "")
        let authenticationHeaderDictionary = shortHeader.parametersDictionaryFromCommaSeparatedParametersString()
        
        let consumerKey = authenticationHeaderDictionary["oauth_consumer_key"]!
        
        var parameters = Dictionary<String, AnyObject>()
        parameters["x_reverse_auth_target"] = consumerKey
        parameters["x_reverse_auth_parameters"] = authenticationHeader
        
        self.client.post(path, baseURL: swifterApiURL, parameters: parameters, uploadProgress: nil, downloadProgress: nil, success: { data, response in
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            let accessToken = SwifterCredential.OAuthAccessToken(queryString: responseString!)
            success(accessToken: accessToken, response: response)
        }, failure: failure)
        
    }
    
}


extension String {
    
    func parametersDictionaryFromCommaSeparatedParametersString() -> Dictionary<String, String> {
        var dict = Dictionary<String, String>()
        
        for parameter in self.componentsSeparatedByString(", ") {
            // transform k="v" into {'k':'v'}
            let keyValue = parameter.componentsSeparatedByString("=")
            if keyValue.count != 2 {
                continue
            }
            
            let value = keyValue[1].stringByReplacingOccurrencesOfString("\"", withString:"")
            dict.updateValue(value, forKey: keyValue[0])
        }

        return dict
    }

}

