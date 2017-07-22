//
//  AppDelegate.swift
//  sponet
//
//  Created by Yusuke Kudo on 2017/07/22.
//  Copyright © 2017年 Yusuke Kudo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SPTAudioStreamingDelegate {

    var window: UIWindow?

    let CLIENT_ID = "1cec87563f47447eb8ba2b4a80213cd9"
    let REDIRECT_URL = URL(string: "sponet-login://callback/")

    var auth: SPTAuth!
    var session: SPTSession!
    var player:  SPTAudioStreamingController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.auth = SPTAuth.defaultInstance()
        
        // setup Spotify
        self.auth.clientID = CLIENT_ID
        self.auth.redirectURL = REDIRECT_URL
        self.auth.requestedScopes = [SPTAuthStreamingScope]
        
        // Setting the `sessionUserDefaultsKey` enables SPTAuth to automatically store the session object for future use.
        self.auth.sessionUserDefaultsKey  = "current session"
        
        // Get the player Instance
        self.player = SPTAudioStreamingController.sharedInstance()
        self.player.delegate = self
        
        // サブスレッドで実行
        DispatchQueue.global(qos: .default).async {
            // サブスレッド(バックグラウンド)で実行する方を書く
            self.startAuthenticationFlow(application: application)

            DispatchQueue.main.async {
                // Main Threadで実行する
            }
        }

        
        return true
    }
    
    func startAuthenticationFlow(application: UIApplication) -> Void {

        // Check if we could use the access token we already have
        if let session = self.auth.session, session.isValid() {
            
            try! self.player.start(withClientId: CLIENT_ID)
            // Login SDK before we can start playback
            print(session.accessToken)
            
            player.login(withAccessToken: session.accessToken)
        } else {
            let loginUrl = self.auth.spotifyWebAuthenticationURL
            
            application.open(loginUrl())
        }
    }
    
    // handle auth
    @objc(application:openURL:sourceApplication:annotation:) func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        print(url);
        
        if self.auth.canHandle(url) {
            self.auth.handleAuthCallback(withTriggeredAuthURL: url, callback: { error, session in
                if error != nil {
                    print("*** Auth error: \(String(describing: error))")
                }
                
                try! self.player.start(withClientId: self.CLIENT_ID)
                
                // Login SDK before we can start playback
                self.player.login(withAccessToken: session?.accessToken)
            })
            return true
        }
        
        return false
    }
    
    // MARK: SPTAudioStreamingDelegate.
    func audioStreamingDidLogin(audioStreaming: SPTAudioStreamingController!) {
        let urlStr = "spotify:track:6ZSvhLZRJredt15aJiBQqv" // track available in Japan
        player.playSpotifyURI(urlStr, startingWith: 0, startingWithPosition: 0, callback: { error in
            if error != nil {
                print("*** failed to play: \(String(describing: error))")
                return
            } else {
                print("play")
            }
        })
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        print(error);
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

