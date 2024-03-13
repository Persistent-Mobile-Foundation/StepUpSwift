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
import IBMMobileFirstPlatformFoundation

class SecuredViewController: UIViewController {
    @IBOutlet weak var copyrightText: UILabel!
    @IBOutlet weak var helloUserLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    //var isChallenged = false
    //var showPinCodePopupNotification: NSNotification

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "StepUp"
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        let logoutBtn = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.plain, target: self, action: #selector(logout))
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.copyrightText.text = "©\(appDelegate.currentYear) Persistent System"
        self.navigationItem.rightBarButtonItem = logoutBtn
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let userName = UserDefaults.standard.string(forKey: "displayName"){
            self.helloUserLabel.text = "Hello, " + userName
        }
        NotificationCenter.default.addObserver(self, selector: #selector(showPinCodePopup(_:)), name: NSNotification.Name(rawValue: ACTION_PINCODE_CHALLENGE_RECEIVED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showErrorPopup(_:)), name: NSNotification.Name(rawValue: ACTION_PINCODE_CHALLENGE_FAILURE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showLoginPage(_:)), name: NSNotification.Name(rawValue: ACTION_USERLOGIN_CHALLENGE_RECEIVED), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func getBalance(_ sender: AnyObject) {
        let request = WLResourceRequest(url: URL(string: "/adapters/ResourceAdapter/balance"), method: WLHttpMethodGet)
        request?.send { (response, error) -> Void in
            if (error != nil){
                NSLog("getBalanceError: " + error.debugDescription)
                self.resultLabel.text = "Failed to get balance"
            } else {
                NSLog("getBalance = " + (response?.responseText)!)
                self.resultLabel.text = "Balance = " + (response?.responseText)!
            }
        }
    }
    
    @IBAction func transferFunds(_ sender: AnyObject) {
        self.resultLabel.text = ""
        
        WLAuthorizationManager.sharedInstance().obtainAccessToken(forScope: "StepUpUserLogin") { (token, error) -> Void in
            if (error != nil){
                print("obtainAccessToken failure")
            } else {
                print("obtainAccessToken success")
                let alert = UIAlertController(title: "Tranfer funds", message: "Enter amount:", preferredStyle: .alert)
                alert.addTextField { (textField) -> Void in
                    textField.placeholder = "Amount"
                    textField.keyboardType = .numberPad
                }
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                    let pinTextField = alert.textFields![0] as UITextField
                    self.transfer(pinTextField.text!)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
                    //
                }))
                self.present(alert,
                                           animated: true,
                                           completion: nil)
            }
        }
    }
    
    @objc func logout(){
        self.resultLabel.text = ""
        self.performSegue(withIdentifier: "showLoginPage", sender: self)
        NotificationCenter.default.post(name: Notification.Name(rawValue: ACTION_LOGOUT) , object: self)
    }
    
    func transfer(_ amount: String){
        let request = WLResourceRequest(url: URL(string: "/adapters/ResourceAdapter/transfer"), method: WLHttpMethodPost)
        let formParams = ["amount":amount]
        request?.send(withFormParameters: formParams) { (response, error) -> Void in
            if (error != nil){
                print("transferFounds Error: \(error.debugDescription)")
                DispatchQueue.main.async {
                    self.resultLabel.text = "Faild to transfer funds"
                }
            } else {
                print("transferFounds Success with status: \(String(describing: response?.status))")
                DispatchQueue.main.async {
                    self.resultLabel.text = "Transfer funds successfully."
                }
            }
        }
    }
    
    @objc func showPinCodePopup(_ notification: Notification){
        let alert = UIAlertController(title: "Pin Code",
            message: notification.userInfo!["errorMsg"] as? String,
            preferredStyle: .alert)
        alert.addTextField { (textField) -> Void in
            textField.placeholder = "PIN CODE"
            textField.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            let pinTextField = alert.textFields![0] as UITextField
            NotificationCenter.default.post(name: Notification.Name(rawValue: ACTION_PINCODE_SUBMIT_ANSWER) , object: self, userInfo: ["pinCode":pinTextField.text!])
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            NotificationCenter.default.post(name: Notification.Name(rawValue: ACTION_PINCODE_CHALLENGE_CANCEL) , object: self)
        }))
        
        self.present(alert,
            animated: true,
            completion: nil)
    }
    
    @objc func showErrorPopup(_ notification: Notification){
        let alert = UIAlertController(title: "Error",
            message: notification.userInfo!["errorMsg"] as? String,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert,
            animated: true,
            completion: nil)
    }
    
    @objc func showLoginPage(_ notification: Notification){
        self.performSegue(withIdentifier: "showLoginPage", sender: self)
    }

}
