//
//  QRView.swift
//  Picker
//
//  Created by Nao Sasaki on 2019/05/27.
//  Copyright © 2019 Nao Sasaki. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import FloatingPanel
import CoreLocation

class QRView: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var FireStore: Firestore!
    var handle: AuthStateDidChangeListenerHandle?
    let ButtonTitle: [String] = ["SignOut"]
    let ButtonImage: [UIImage] = [UIImage(named: "_i_icon_14419_icon_144191_512")!]
    
    
    var timer: Timer!
    
    var floatingPanelController: FloatingPanelController = FloatingPanelController()
    var hamburgerMenu: UIBarButtonItem = UIBarButtonItem()
    var menuTab: UIView = UIView()
    var accountButton: UIButton = AccountButton(type: .custom)
    var MenuTable: UITableView = UITableView()
    var shadow: UIView = UIView()
    var bgImage: UIImageView = UIImageView()
    var label1: UILabel = UILabel()
    
    
    
    
    func acsess(classPass: String, className: String) {
        FireStore = Firestore.firestore()
        print(className)
        FireStore.collection("classes").document(className).getDocument{(document, error) in
            if let document = document {
                let data = document.data()!
                let classAuthPass: String = data["ClassPass"]! as! String
                self.FireStore.collection("class").document("rt3").getDocument{(document, error) in
                    if let document = document, document.exists {
                        let dataDescription = document.data()!
                        let dicArray = (dataDescription as Dictionary)[className]! as! Array<Any>
                        print(dicArray)
                        let classFinish: Int = Int(String(describing: dicArray[0]))!
                        let instructor: String = String(describing: dicArray[1])
                        print(classFinish)
                        print(instructor)
                        
                        let hourFmt = DateFormatter()
                        hourFmt.dateFormat = "HH:mm"
                        let timeArray = hourFmt.string(from: Date()).components(separatedBy: ":")
                        let hour = Int(timeArray[0])! * 60
                        let min = Int(timeArray[1])!
                        
                        if ((classAuthPass) == classPass && classFinish >= (hour + min)) || (classPass == "123456789" && classFinish >= (hour + min)) {
                            let alert: UIAlertController = UIAlertController(title: "\(className)", message: "本当に\(className)に出席しますか？\n※授業時間内は他の授業に出席できません", preferredStyle:  UIAlertController.Style.alert)
                            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) -> Void in
                                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.compare), userInfo: nil, repeats: true)
                                self.attention(className, classFinish, instructor)
                            })
                            let cancelAction: UIAlertAction = UIAlertAction(title: "cancel", style: UIAlertAction.Style.cancel, handler:{(action: UIAlertAction!) -> Void in
                                self.session.startRunning()
                            })
                            alert.addAction(defaultAction)
                            alert.addAction(cancelAction)
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            let alert: UIAlertController = UIAlertController(title: "Error", message: "出席に失敗しました。\n読み込みに失敗したか、授業の開始時間を超過しています。", preferredStyle:  UIAlertController.Style.alert)
                            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) -> Void in
                                self.session.startRunning()
                            })
                            alert.addAction(defaultAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                    } else { print("Document does not exist") }
                }
            }else{
                print("Document does not exist")
            }
        }
    }
    func attention(_ className: String, _ classFinish: Int, _ instructor: String) {
        FireStore = Firestore.firestore()
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                let uid = user.displayName!
                self.FireStore.collection("class").document("rt3").getDocument{(document, error) in
                    if let document = document, document.exists {
                        let dataDescription = document.data()!
                        let dicArray = (dataDescription as Dictionary)[className]! as! Array<Any>
                        print(dicArray)
                        let weekday = Date().weekday
                        if (dataDescription as Dictionary)["Monday"] != nil {
                            let weekdayData = (dataDescription as Dictionary)["Monday"]! as! Array<String>
                            print(weekdayData)
                            UserDefaults.standard.set(weekdayData, forKey: "classSchedule")
                        } else {
                            UserDefaults.standard.set(nil, forKey: "classSchedule")
                        }
                        print(classFinish)
                        print(instructor)
                        print(weekday)
                        
                        UserDefaults.standard.set(classFinish, forKey: "classFinish")
                        UserDefaults.standard.set(instructor, forKey: "instructor")
                    } else { print("Document does not exist") }
                }
                self.FireStore.collection("classes").document(className).updateData([
                    uid: true
                ]){ err in
                    if let err = err { print("Error adding document: \(err)") } else { return }
                }
                self.FireStore.collection("students").document(uid).getDocument{(document, error) in
                    if let document = document, document.exists {
                        let dataDescription = document.data()! as! Dictionary<String, Int>
                        let count = dataDescription[className]! + 1
                        print(count)
                        self.FireStore.collection("students").document(uid).updateData([
                            className: count
                        ]){ err in
                            if let err = err { print("Error adding document: \(err)") } else { return }
                        }
                    } else { print("Document does not exist") }
                }
            }
        }
        let semiModalViewController = CertificateView()
        self.floatingPanelController.surfaceView.cornerRadius = 24.0
        self.floatingPanelController.set(contentViewController: semiModalViewController)
        self.floatingPanelController.addPanel(toParent: self, belowView: nil, animated: false)
        self.floatingPanelController.move(to: .half, animated: true)
        
        UserDefaults.standard.set(true, forKey: "Attendance")
        UserDefaults.standard.set(className, forKey: "AttendingClassPass")
        semiModalViewController.CNLabel.text = className
        self.session.stopRunning()
    }
    @objc func compare(){
        let hourFmt = DateFormatter()
        hourFmt.dateFormat = "HH:mm"
        let timeArray = hourFmt.string(from: Date()).components(separatedBy: ":")
        let hour = Int(timeArray[0])! * 60
        let min = Int(timeArray[1])!
        print(UserDefaults.standard.integer(forKey: "classFinish"))
        print(hour + min)
        let arr = UserDefaults.standard.array(forKey: "classSchedule") as! Array<String>
        let txt = UserDefaults.standard.string(forKey: "AttendingClassPass")!
        let cnt = arr.firstIndex(of: txt)
        if (hour + min) >= UserDefaults.standard.integer(forKey: "classFinish") {
            floatingPanelController.removePanelFromParent(animated: true)
            timer.invalidate()
            if cnt! != (arr.count - 1) {
                let alert: UIAlertController = UIAlertController(title: "連続出席", message: "本当に\(arr[cnt! + 1])に出席しますか？\n※授業時間内は他の授業に出席できません", preferredStyle:  UIAlertController.Style.alert)
                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) -> Void in
                    self.acsess(classPass: "123456789", className: arr[cnt! + 1])
                })
                let cancelAction: UIAlertAction = UIAlertAction(title: "cancel", style: UIAlertAction.Style.cancel, handler:{(action: UIAlertAction!) -> Void in
                    self.session.startRunning()
                })
                alert.addAction(defaultAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            } else { print("最後の授業だった") }
            UserDefaults.standard.set(false, forKey: "Attendance")
            UserDefaults.standard.removeObject(forKey: "AttendingClassPass")
            UserDefaults.standard.removeObject(forKey: "classFinish")
            UserDefaults.standard.removeObject(forKey: "instructor")
            self.session.startRunning()
        } else { print("出席中") }
    }
        
    private let session = AVCaptureSession()
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            if metadata.type != .qr { continue }
            if metadata.stringValue == nil { continue }
            self.session.stopRunning()
            let qrData: String = metadata.stringValue!
            let qrDataArray: Array = qrData.components(separatedBy: "/")
            let className: String = qrDataArray[0]
            acsess(classPass: qrData, className: className)
        }
    }
    @objc func viewOwnData() {
        if shadow.alpha > 0.5 {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                self.shadow.alpha = 0
                self.menuTab.frame = CGRect(x: -((self.view.frame.width / 3) * 2), y: ((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.minY)!), width: (self.view.frame.width / 3) * 2, height: (self.view.frame.height - ((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.minY)!)))
            }, completion: nil)
            self.session.startRunning()
        } else {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                self.shadow.alpha = 0.7
                self.menuTab.frame = CGRect(x: 0, y: ((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.minY)!), width: (self.view.frame.width / 3) * 2, height: (self.view.frame.height - ((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.minY)!)))
            }, completion: nil)
            self.session.stopRunning()
        }
    }
    @objc func swipeLabel(_ sender: UISwipeGestureRecognizer) {
        self.view.bringSubviewToFront(shadow)
        self.view.bringSubviewToFront(menuTab)
        
        switch(sender.direction){
        case UISwipeGestureRecognizer.Direction.right:
            print("right")
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                self.shadow.alpha = 0.7
                self.menuTab.frame = CGRect(x: 0, y: ((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.minY)!), width: (self.view.frame.width / 3) * 2, height: (self.view.frame.height - ((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.minY)!)))
            }, completion: nil)
            self.session.stopRunning()
            break
        case UISwipeGestureRecognizer.Direction.left:
            print("left")
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                self.shadow.alpha = 0
                self.menuTab.frame = CGRect(x: -((self.view.frame.width / 3) * 2), y: ((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.minY)!), width: (self.view.frame.width / 3) * 2, height: (self.view.frame.height - ((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.minY)!)))
            }, completion: nil)
            if UserDefaults.standard.bool(forKey: "Attendance") == false {
                self.session.startRunning()
            } else { break }
        default: break
        }
    }
    @objc func ToAccountView() {
        self.present(AccountView(), animated: true, completion: nil)
    }
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let directionList: [UISwipeGestureRecognizer.Direction] = [.right, .left]
        for direction in directionList {
            let swipeRecognizer = UISwipeGestureRecognizer(target:self, action: #selector(swipeLabel(_:)))
            swipeRecognizer.direction = direction
            self.view.addGestureRecognizer(swipeRecognizer)
        }
        // カメラやマイクのデバイスそのものを管理するオブジェクトを生成（ここではワイドアングルカメラ・ビデオ・背面カメラを指定）
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                mediaType: .video,
                                                                position: .back)
        // ワイドアングルカメラ・ビデオ・背面カメラに該当するデバイスを取得
        let devices = discoverySession.devices
        //　該当するデバイスのうち最初に取得したものを利用する
        if let backCamera = devices.first {
            do {
                // QRコードの読み取りに背面カメラの映像を利用するための設定
                let deviceInput = try AVCaptureDeviceInput(device: backCamera)
                if self.session.canAddInput(deviceInput) {
                    self.session.addInput(deviceInput)
                    // 背面カメラの映像からQRコードを検出するための設定
                    let metadataOutput = AVCaptureMetadataOutput()
                    if self.session.canAddOutput(metadataOutput) {
                        self.session.addOutput(metadataOutput)
                        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                        metadataOutput.metadataObjectTypes = [.qr]
                        // 背面カメラの映像を画面に表示するためのレイヤーを生成
                        let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                        previewLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                        previewLayer.videoGravity = .resizeAspectFill
                        self.view.layer.addSublayer(previewLayer)
                        if UserDefaults.standard.bool(forKey: "Attendance") {
                            self.session.stopRunning()
                            let semiModalViewController = CertificateView()
                            self.floatingPanelController.surfaceView.cornerRadius = 24.0
                            self.floatingPanelController.set(contentViewController: semiModalViewController)
                            self.floatingPanelController.addPanel(toParent: self, belowView: nil, animated: false)
                            self.floatingPanelController.move(to: .half, animated: true)
                            
                            UserDefaults.standard.set(true, forKey: "Attendance")
                            semiModalViewController.CNLabel.text = UserDefaults.standard.string(forKey: "AttendingClassPass")
                        } else {
                            self.session.startRunning()
                        }
                    }
                }
            } catch {
                print("Error occured while creating video device input: \(error)")
            }
        }
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                let uid = user.displayName!
                let email = user.email!
                print(uid, email)
            } else {
                let authView = AuthView()
                authView.modalPresentationStyle = .fullScreen
                self.present(authView, animated: true, completion: nil)
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "QRコード読取"
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        if UserDefaults.standard.bool(forKey: "Attendance") == true {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(compare), userInfo: nil, repeats: true)
        }
        floatingPanelController.delegate = self
        MenuTable.delegate = self
        MenuTable.dataSource = self
        
        bgImage.frame = CGRect(x: 0, y: (self.view.frame.height - self.view.frame.width) / 2, width: self.view.frame.width, height: self.view.frame.width)
        bgImage.image = UIImage(named: "youAllCaughtUp")
        bgImage.backgroundColor = .clear
        self.view.addSubview(bgImage)
        self.view.sendSubviewToBack(bgImage)
        
        label1.frame = CGRect(x: 20, y: bgImage.frame.height / 5 * 4, width: self.view.frame.width - 40, height: 50)
        label1.text = "You've Attended Class Already."
        label1.font = UIFont(name: "HiraginoSans-W6", size: 21)
        label1.textAlignment = .center
        label1.textColor = .darkGray
        self.bgImage.addSubview(label1)
        self.bgImage.sendSubviewToBack(label1)
        
        hamburgerMenu = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(viewOwnData))
        hamburgerMenu.tintColor = .black
        self.navigationItem.rightBarButtonItem = hamburgerMenu
        
        menuTab.frame = CGRect(x: -((self.view.frame.width / 3) * 2), y: ((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.minY)!), width: (self.view.frame.width / 3) * 2, height: (self.view.frame.height - ((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.minY)!)))
        menuTab.backgroundColor = .white
        self.view.addSubview(menuTab)
        
        accountButton.frame = CGRect(x: 0, y: 0, width: menuTab.frame.width, height: 120)
        accountButton.addTarget(self, action: #selector(ToAccountView), for: .touchUpInside)
        self.menuTab.addSubview(accountButton)
        
        MenuTable.frame = CGRect(x: 0, y: 120, width: self.menuTab.frame.width, height: self.menuTab.frame.height - 120)
        MenuTable.rowHeight = menuTab.frame.height / 12
        MenuTable.delegate = self
        MenuTable.dataSource  =  self
        MenuTable.isScrollEnabled = false
        MenuTable.separatorStyle = .none
        MenuTable.tag = 0
        MenuTable.backgroundColor = .white
        MenuTable.register(MenuTableCell.self, forCellReuseIdentifier: NSStringFromClass(MenuTableCell.self))
        self.menuTab.addSubview(MenuTable)
        
        shadow.frame = CGRect(x: 0, y: ((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.minY)!), width: self.view.frame.width, height: (self.view.frame.height - ((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.minY)!)))
        shadow.backgroundColor = .black
        shadow.alpha = 0
        self.view.addSubview(shadow)
    }
}
extension Date {
    var weekday: String {
        let calendar = Calendar(identifier: .gregorian)
        let component = calendar.component(.weekday, from: self)
        let weekday = component - 1
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        return formatter.weekdaySymbols[weekday]
    }
}
extension QRView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ButtonTitle.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(MenuTableCell.self), for: indexPath) as! MenuTableCell
        cell.MenuTitleLabel.text = ButtonTitle[indexPath.row]
        cell.MenuTitleImage.image = ButtonImage[indexPath.row].withRenderingMode(.alwaysTemplate)
        cell.MenuTitleImage.tintColor = .darkGray
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
        self.MenuTable.setContentOffset(CGPoint(x: 0, y: -(MenuTable.contentInset.top)), animated: true)
        let identifier: String = ButtonTitle[indexPath.row]
        pushViews(identifier)
    }
    func pushViews(_ viewID: String) {
        switch viewID {
        case "SignOut":
            let alert: UIAlertController = UIAlertController(title: "Sign out", message: "本当にサインアウトしますか？\n※機能を利用するには再度ログインが必要です", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) -> Void in
                GIDSignIn.sharedInstance()?.signOut()
                do{ try Auth.auth().signOut()} catch let signOutError as NSError{print ("Error signing out: %@", signOutError)}
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: "cancel", style: UIAlertAction.Style.destructive, handler:{(action: UIAlertAction!) -> Void in
            })
            alert.addAction(defaultAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        default:
            let alert: UIAlertController = UIAlertController(title: "Sorry.", message: "開発中です", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) -> Void in
            })
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
extension QRView: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return CustomFloatingPanelLayout()
    }
}
class MenuTableCell: UITableViewCell {
    var MenuTitleLabel: UILabel = UILabel()
    var MenuTitleImage: UIImageView = UIImageView()
    var separator: CALayer = CALayer()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        MenuTitleLabel.textColor = .darkGray
        MenuTitleLabel.textAlignment = .left
        MenuTitleLabel.font = UIFont(name: "PingFangSC-Regular", size: 15)
        self.addSubview(MenuTitleLabel)
        
        MenuTitleImage.backgroundColor = .clear
        MenuTitleImage.tintAdjustmentMode = .normal
        self.addSubview(MenuTitleImage)
        
        self.backgroundColor = .white
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        MenuTitleLabel.frame = CGRect(x: 50, y: 0, width: self.frame.width, height: self.frame.height)
        MenuTitleImage.frame = CGRect(x: 10, y: (self.frame.height - 25) / 2, width: 25, height: 25)
    }
}
class CustomFloatingPanelLayout: FloatingPanelLayout {
    var initialPosition: FloatingPanelPosition {
        return .tip
    }
    var topInteractionBuffer: CGFloat { return 0.0 }
    var bottomInteractionBuffer: CGFloat { return 0.0 }
    // セミモーダルビューの各表示パターンの高さを決定するためのInset
    func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
            case .full: return 56.0
            case .half: return 262.0
            case .tip: return 100.0
            case .hidden: return 0.0
        }
    }
    // セミモーダルビューの背景Viewの透明度
    func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
        return 0.0
    }
}
class AccountButton: UIButton {
    var handle: AuthStateDidChangeListenerHandle?
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                let uid = user.displayName!
            }
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}





