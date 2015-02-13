## Twitter Reverse Auth extension for [Swifter](https://github.com/mattdonnelly/Swifter)

Swifter provides comprehensive interaction with Twitter API. Twitter's reverse authentication (`x_auth_mode = reverse_auth`) is useful when the application needs external access to Twitter API on the user's behalf.

Swifter-Reverse-Auth works on iOS as well as OS X.

##### Usage

```Swift
let TWITTER_CONSUMER_KEY = ""
let TWITTER_CONSUMER_SECRET_KEY = ""

let twitterAccount = ... // An ACAccount instance obtained from ACAccountStore.
let swifter = Swifter(consumerKey: TWITTER_CONSUMER_KEY, consumerSecret: TWITTER_CONSUMER_SECRET_KEY)

// Step 1
swifter.postReverseOAuthTokenRequest({ (authenticationHeader) -> Void in
    let swifterAPIOS = Swifter(account: twitterAccount)

    // Step 2
    swifterAPIOS.getAccountVerifyCredentials(false, skipStatus: false, success: { (myInfo) -> Void in

        // Step 3
        swifterAPIOS.postReverseAuthAccessTokenWithAuthenticationHeader(authenticationHeader, success: { (accessToken, response) -> Void in

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

##### Creator

* [Gurpartap Singh](http://gurpartap.com/) ([@Gurpartap](http://twitter.com/Gurpartap))

Inspired by [Nicolas Seriot](https://github.com/nst)'s work on reverse auth in [STTwitter](https://github.com/nst/STTwitter).

##### License

Swifter-Reverse-Auth is licensed under MIT license. See LICENSE for details.
