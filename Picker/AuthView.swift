//
//  AuthView.swift
//  Picker
//
//  Created by Nao Sasaki on 2019/07/11.
//  Copyright © 2019 Nao Sasaki. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class AuthView: UIViewController, GIDSignInDelegate {
    
    
    
    var handle: AuthStateDidChangeListenerHandle?
    let list: [String] = ["","1-1","1-2","1-3","1-4","RT2","SE2","ME2","AD2","RT3","SE3","ME3","AD3","PE4","PS4","PM4","PA4","PE5","PS5","PM5","PA5"]
    var BgImages: [UIImage] = [UIImage(named: "IMG_1553")!, UIImage(named: "IMG_9841")!, UIImage(named: "IMG_9818")!, UIImage(named: "IMG_9848")!]
    var timer: Timer = Timer()
    var count: Int = 0
    
    
    
    
    var pickerView: UIPickerView = UIPickerView()
    var welcomeLabel: UILabel = UILabel()
    var welcomeLabel2: UILabel = UILabel()
    var button: UIButton = SignInButton(type: .custom)
    var BackGroundImage: UIImageView = UIImageView()
    var ClassSelecter: UITextField = UITextField()
    
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser, withError error: Error?) {
        if error != nil { return }
        print("Success!")
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential, completion: { (authResult, error) in
            if let error = error {
                print("Error:", error)
                return
            } else {
                print("login sucessed.")
            }
        })
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Sign off successfully")
    }
    @objc func login() {
        if ClassSelecter.text != "" {
            GIDSignIn.sharedInstance().signIn()
        } else {
            let alert: UIAlertController = UIAlertController(title: "Error", message: "所属しているクラスを選択してください。", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) -> Void in
            })
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    @objc func animationBackImage() {
        if count == BgImages.count {
            count = count - count
        }
        let bg: UIImage = BgImages[count]
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.BackGroundImage.alpha = 0
        }, completion: { finished in
            self.BackGroundImage.image = bg
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
                self.BackGroundImage.alpha = 1
            }, completion: nil)
        })
        count += 1
    }
    @objc func done() {
        ClassSelecter.endEditing(true)
        ClassSelecter.text = "\(list[pickerView.selectedRow(inComponent: 0)])"
    }
    override func viewWillAppear(_ animated: Bool) {
        GIDSignIn.sharedInstance()?.delegate = self
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                let alert: UIAlertController = UIAlertController(title: "Logged in.", message: "Name: \((user.displayName)!)\nEmail: \((user.email)!)\nでログインしました。", preferredStyle:  UIAlertController.Style.alert)
                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) -> Void in
                    UserDefaults.standard.set(self.ClassSelecter.text, forKey: "BelongingClass")
                    self.dismiss(animated: true, completion: nil)
                })
                alert.addAction(defaultAction)
                self.present(alert, animated: true, completion: nil)
            } else { return }
        }
        self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(animationBackImage), userInfo: nil, repeats: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
        timer.invalidate()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        
        BackGroundImage.frame = self.view.frame
        BackGroundImage.image = BgImages[0]
        BackGroundImage.contentMode = .scaleAspectFill
        self.view.addSubview(BackGroundImage)
        
        welcomeLabel.frame = CGRect(x: 0, y: 150, width: self.view.frame.width, height: 50)
        welcomeLabel.textColor = .white
        welcomeLabel.textAlignment = .center
        welcomeLabel.font = UIFont(name: "HiraginoSans-W6", size: 48)
        welcomeLabel.text = "Welcome"
        self.view.addSubview(welcomeLabel)
        
        welcomeLabel2.frame = CGRect(x: 0, y: welcomeLabel.frame.minY + welcomeLabel.frame.height, width: self.view.frame.width, height: 30)
        welcomeLabel2.textColor = .white
        welcomeLabel2.textAlignment = .center
        welcomeLabel2.font = UIFont(name: "HiraginoSans-W3", size: 16)
        welcomeLabel2.text = "アプリにログインして様々な機能を利用しましょう"
        self.view.addSubview(welcomeLabel2)
        
        button.frame = CGRect(x: (self.view.frame.width / 10), y: (self.view.frame.height / 8) * 7, width: (self.view.frame.width / 5) * 4, height: (self.view.frame.width / 6))
        button.layer.masksToBounds = true
        button.layer.cornerRadius = button.frame.height / 2
        button.addTarget(self, action: #selector(login), for: .touchUpInside)
        button.setTitle("SignIn with Google", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.setTitleColor(.lightGray, for: .highlighted)
        button.titleLabel?.font = UIFont(name: "HiraginoSans-W6", size: 16)
        button.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        self.view.addSubview(button)
        
        
        
        ClassSelecter.frame = CGRect(x: (self.view.frame.width / 10), y: button.frame.minY - (self.view.frame.width / 6 + 10), width: (self.view.frame.width / 5) * 4, height: (self.view.frame.width / 6))
        ClassSelecter.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        ClassSelecter.textAlignment = .center
        ClassSelecter.borderStyle = .none
        ClassSelecter.attributedPlaceholder =  NSAttributedString(string: "Select Your Class.", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        ClassSelecter.layer.cornerRadius = button.frame.height / 2
        ClassSelecter.textColor = .white
        ClassSelecter.font = UIFont(name: "HiraginoSans-W6", size: 16)
        self.view.addSubview(ClassSelecter)
        
        
        
        
        
        pickerView.delegate = self
        pickerView.dataSource = self
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 45))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        ClassSelecter.inputView = pickerView
        ClassSelecter.inputAccessoryView = toolbar
        
        
        
    }
}







extension AuthView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }
}





class SignInButton: UIButton {
    var googleImage: UIImageView = UIImageView()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        googleImage.backgroundColor = .clear
        googleImage.contentMode = .scaleAspectFill
        googleImage.image = UIImage(named: "icons8-googleã®ã­ã´-48")
        self.addSubview(googleImage)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        googleImage.frame = CGRect(x: (self.frame.width / 10), y: self.frame.height / 4, width: self.frame.height / 2, height: self.frame.height / 2)
    }
}
