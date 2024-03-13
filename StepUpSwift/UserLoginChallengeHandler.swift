/**
 * Copyright 2016 IBM Corp.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import IBMMobileFirstPlatformFoundation

class UserLoginChallengeHandler : SecurityCheckChallengeHandler {
    let challengeHandlerName = "UserLoginChallengeHandler"
    let securityCheckName = "StepUpUserLogin"
    var isChallenged = false
    
    override init() {
        super.init(securityCheck: securityCheckName)
        WLClient.sharedInstance().registerChallengeHandler(challengeHandler: self)
        NotificationCenter.default.addObserver(self, selector: #selector(login(_:)), name: NSNotification.Name(rawValue: ACTION_USERLOGIN_LOGIN_REQUIRED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(logout), name: NSNotification.Name(rawValue: ACTION_LOGOUT), object: nil)
    }
    
    override func handleChallenge(_ challenge: [AnyHashable: Any]!) {
        print("\(self.challengeHandlerName): handleChallenge - \(challenge)")
        self.isChallenged = true
        var errorMsg = ""
        if (challenge["errorMsg"] is NSNull) {
            errorMsg = ""
        } else{
            errorMsg = challenge["errorMsg"] as! String
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: ACTION_USERLOGIN_CHALLENGE_RECEIVED) , object: self, userInfo: ["errorMsg":errorMsg])
    }
    
    override func handleSuccess(_ success: [AnyHashable: Any]!) {
        print("\(self.challengeHandlerName): handleSuccess - \(success)")
        self.isChallenged = false
        let user = success["user"]  as! [String:Any]
        let displayName = user["displayName"] as! String

        UserDefaults.standard.set(displayName, forKey: "displayName")
        NotificationCenter.default.post(name: Notification.Name(rawValue: ACTION_USERLOGIN_CHALLENGE_SUCCESS) , object: self)
    }
    
    override func handleFailure(_ failure: [AnyHashable: Any]!) {
        print("\(self.challengeHandlerName): \(failure)")
        self.isChallenged = false
    }
    
    @objc func login(_ notification: Notification){
        let username = notification.userInfo!["username"] as! String
        let password = notification.userInfo!["password"] as! String
        if(!self.isChallenged){
            print("\(self.challengeHandlerName): login")
            WLAuthorizationManager.sharedInstance().login(self.securityCheckName, withCredentials: ["username": username, "password": password]) { (error) -> Void in
                if(error != nil){
                    print("\(self.challengeHandlerName): login failure - \(error.debugDescription)")
                } else {
                    print("\(self.challengeHandlerName): login success")
                }
            }
        } else {
            print("\(self.challengeHandlerName): submitChallengeAnswer")
            self.submitChallengeAnswer(["username": username, "password": password])
        }
    }
    
    @objc func logout(){
        print("\(self.challengeHandlerName): logout")
        WLAuthorizationManager.sharedInstance().logout(securityCheckName) { (error) -> Void in
            if (error != nil){
                print("\(self.challengeHandlerName): logout failure - \(error.debugDescription)")
            } else {
                NotificationCenter.default.post(name: Notification.Name(rawValue: ACTION_USERLOGIN_LOGOUT_SUCCESS) , object: self)
                self.isChallenged = false
                
            }
        }
    }

}
