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

class PinCodeChallengeHandler : SecurityCheckChallengeHandler {
    
    let challengeHandlerName = "PinCodeChallengeHandler"
    let securityCheckName = "StepUpPinCode"
    var isChallenged = false
    
    override init() {
        super.init(securityCheck: securityCheckName)
        WLClient.sharedInstance().registerChallengeHandler(challengeHandler: self)
        NotificationCenter.default.addObserver(self, selector: #selector(challengeSubmitAnswer(_:)), name: NSNotification.Name(rawValue: ACTION_PINCODE_SUBMIT_ANSWER), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(challengeCanceled), name: NSNotification.Name(rawValue: ACTION_PINCODE_CHALLENGE_CANCEL), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(logout), name: NSNotification.Name(rawValue: ACTION_USERLOGIN_LOGOUT_SUCCESS), object: nil)

    }
    
    override func handleChallenge(_ challenge: [AnyHashable: Any]!) {
        print("\(self.challengeHandlerName): handleChallenge - \(challenge)")
        isChallenged = true
        var errorMsg: String
        if (challenge["errorMsg"] is NSNull) {
            errorMsg = "Enter PIN code:"
        } else{
            errorMsg = challenge["errorMsg"] as! String
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: ACTION_PINCODE_CHALLENGE_RECEIVED) , object: self, userInfo: ["errorMsg":errorMsg])
    }
    
    override func handleFailure(_ failure: [AnyHashable: Any]!) {
        print("\(self.challengeHandlerName): handleFailure - \(failure)")
        isChallenged = false
        var errorMsg: String
        if (failure["failure"] is NSNull) {
            errorMsg = "Unknown error"
        } else {
            errorMsg = failure["failure"] as! String
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: ACTION_PINCODE_CHALLENGE_FAILURE), object: self, userInfo: ["errorMsg":errorMsg])
    }
    
    override func handleSuccess(_ success: [AnyHashable: Any]!) {
        print("\(self.challengeHandlerName): handleSuccess - \(success)")
        isChallenged = false
    }
    
    @objc func challengeSubmitAnswer(_ notification: Notification){
        print("\(self.challengeHandlerName): challengeSubmitAnswer")
        self.submitChallengeAnswer(["pin": (notification.userInfo!["pinCode"] as? String)!])
    }
    
    @objc func challengeCanceled(){
        print("\(self.challengeHandlerName): challengeCanceled")
        self.cancel()
    }
    
    @objc func logout(){
        print("\(self.challengeHandlerName): logout")
        WLAuthorizationManager.sharedInstance().logout(securityCheckName) { (error) -> Void in
            if (error != nil){
                print("\(self.challengeHandlerName): logout failure - \(error.debugDescription)")
            } else {
                print("\(self.challengeHandlerName): logout success)")
            }
        }
    }
}
