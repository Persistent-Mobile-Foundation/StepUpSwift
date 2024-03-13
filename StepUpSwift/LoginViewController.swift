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

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var copyrightText: UILabel!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var errorMsgLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "StepUp"
        self.navigationItem.setHidesBackButton(true, animated:true);
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.copyrightText.text = "©\(appDelegate.currentYear) Persistent System"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(showError(_:)), name: NSNotification.Name(rawValue: ACTION_USERLOGIN_CHALLENGE_RECEIVED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showSecuredPage), name: NSNotification.Name(rawValue: ACTION_USERLOGIN_CHALLENGE_SUCCESS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cancelPincodeChallenge), name: NSNotification.Name(rawValue: ACTION_PINCODE_CHALLENGE_RECEIVED), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func login(_ sender: AnyObject) {
        if(self.username.text != "" && self.password.text != ""){
            NotificationCenter.default.post(name: Notification.Name(rawValue: ACTION_USERLOGIN_LOGIN_REQUIRED), object: self, userInfo: ["username": username.text!, "password": password.text!])
        } else {
            errorMsgLabel.text = "Username and password are required"
        }
    }

    @objc func showError(_ notification: Notification){
        errorMsgLabel.text = notification.userInfo!["errorMsg"] as? String
    }
    
    @objc func showSecuredPage(){
        if (self.navigationController?.viewControllers.first == self){
            self.performSegue(withIdentifier: "showSecuredPage", sender: self)
        } else {
            _ =  self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func cancelPincodeChallenge(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: ACTION_PINCODE_CHALLENGE_CANCEL), object: self)
    }

}
