## Twitter Reverse Auth extension for [Swifter](https://github.com/mattdonnelly/Swifter)

Swifter provides comprehensive interaction with Twitter API but lacks the ability to request OAuth access token and secret (when using `ACAccount`) without user intervention. Twitter provides the reverse authentication mechanism (`x_auth_mode = reverse_auth`) for this. Reverse authentication eliminates the need to repeat authorization request to the user (via regular OAuth workflow), after they have already authorized your app to use Twitter accounts serviced by iOS (or OS X).

You may not need to implement reverse auth if you are only going to use Twitter API within the app itself. Having access to OAuth access token and secret is useful when the application needs query Twitter API on the user's behalf on a third party machine, like a server.

If you are looking to implement this using [STTwitter](https://github.com/nst/STTwitter) in a Swift project, [this gist](https://gist.github.com/Gurpartap/557660f1f3d09cbf420e) is for you.

### Troubleshooting

##### xAuth

Twitter restricts the xAuth authentication process to xAuth-enabled consumer tokens only. So, if you get an error like `The consumer tokens are probably not xAuth enabled.` while accessing `https://api.twitter.com/oauth/access_token`, see Twitter's website [https://dev.twitter.com/docs/oauth/xauth](https://dev.twitter.com/docs/oauth/xauth) and ask Twitter to enable the xAuth authentication process for your consumer tokens.

### Usage

```Swift
let TWITTER_CONSUMER_KEY = ""
let TWITTER_CONSUMER_SECRET_KEY = ""

let twitterAccount = ... // An ACAccount instance obtained from ACAccountStore.
let swifter = Swifter(consumerKey: TWITTER_CONSUMER_KEY, consumerSecret: TWITTER_CONSUMER_SECRET_KEY)

// Step 1
swifter.postReverseOAuthTokenRequest({ (authenticationHeader) -> Void in
    let swifterOSAccount = Swifter(account: twitterAccount)

    // Step 2
    swifterOSAccount.getAccountVerifyCredentials(false, skipStatus: false, success: { (myInfo) -> Void in

        // Step 3
        swifterOSAccount.postReverseAuthAccessTokenWithAuthenticationHeader(authenticationHeader, success: { (accessToken, response) -> Void in

        	// This is what you're looking for.
            println("key: \(accessToken?.key) secret: \(accessToken?.secret)")

        }, failure: { (error) -> Void in
            println("postReverseAuthAccessTokenWithAuthenticationHeader error: \(error)")
        })

    }, failure: { (error) -> Void in
        println("getAccountVerifyCredentials error: \(error)")
    })


}, failure: { (error) -> Void in
    println("postReverseOAuthTokenRequest error: \(error)")
})
```

##### ReactiveCocoa

Here's how I use it with [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa):

```Swift
let twitterAccount = ... // An ACAccount instance obtained from ACAccountStore.
TwitterAPI.sharedInstance.requestReverseAuthenticationSignalForAccount(twitterAccount)
.deliverOn(RACScheduler.mainThreadScheduler())
.subscribeNext({ (accessToken: AnyObject!) -> Void in
    println("accessToken: \(accessToken)")
}, error: { (error) -> Void in
    println("error: \(error)")
})
```

```Swift
class TwitterAPI {
    let swifter: Swifter

    init() ... // Setup Swifter with consumer keys

    func requestReverseAuthenticationSignalForAccount(account: ACAccount) -> RACSignal {
        return RACSignal.createSignal { subscriber -> RACDisposable! in
            self.swifter.postReverseOAuthTokenRequest({ (authenticationHeader) -> Void in
                let swifterXAuth = Swifter(account: account)
                swifterXAuth.getAccountVerifyCredentials(false, skipStatus: false, success: { (myInfo) -> Void in
                    swifterXAuth.postReverseAuthAccessTokenWithAuthenticationHeader(authenticationHeader, success: { (accessToken, response) -> Void in
                        // TODO: Ascertain that accessToken is not .None
                        subscriber.sendNext([ "key": accessToken!.key, "secret": accessToken!.secret ])
                        subscriber.sendCompleted()
                        
                    }, failure: { (error) -> Void in
                        subscriber.sendError(error)
                    })
                    
                }, failure: { (error) -> Void in
                    subscriber.sendError(error)
                })
                
                
            }, failure: { (error) -> Void in
                subscriber.sendError(error)
            })
            return nil
        }
    }
}
```

### Creator

* [Gurpartap Singh](http://gurpartap.com/) ([@Gurpartap](http://twitter.com/Gurpartap))

Inspired by [Nicolas Seriot](https://github.com/nst)'s work on reverse auth in [STTwitter](https://github.com/nst/STTwitter).

### License

Swifter-Reverse-Auth is licensed under MIT license. See LICENSE for details.
