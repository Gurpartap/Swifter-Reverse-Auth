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
    let swifterAPIOS = Swifter(account: twitterAccount)

    // Step 2
    swifterAPIOS.getAccountVerifyCredentials(false, skipStatus: false, success: { (myInfo) -> Void in

        // Step 3
        swifterAPIOS.postReverseAuthAccessTokenWithAuthenticationHeader(authenticationHeader, success: { (accessToken, response) -> Void in

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

### Creator

* [Gurpartap Singh](http://gurpartap.com/) ([@Gurpartap](http://twitter.com/Gurpartap))

Inspired by [Nicolas Seriot](https://github.com/nst)'s work on reverse auth in [STTwitter](https://github.com/nst/STTwitter).

### License

Swifter-Reverse-Auth is licensed under MIT license. See LICENSE for details.
