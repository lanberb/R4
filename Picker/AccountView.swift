//
//  AccountView.swift
//  Picker
//
//  Created by Nao Sasaki on 2019/07/19.
//  Copyright © 2019 Nao Sasaki. All rights reserved.
//

import UIKit
import Firebase

class AccountView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    var handle: AuthStateDidChangeListenerHandle?
    var FireStore: Firestore!
    let dataTitle: [String] = ["氏名","メールアドレス","所属"]
    let infoTitle: [String] = ["Activity1","Physics1","Japanese1"]
    let info: [String] = ["欠課数： 0/30","欠課数： 3/30","欠課数： 0/30"]
    let params = ["詳細情報", "出席確認"]
    
    
    
    var AccountImageView: UIImageView = UIImageView()
    var dataTable: UITableView = UITableView()
    
    
    
    @objc func segmentChanged(_ segment:UISegmentedControl) {
        switch segment.selectedSegmentIndex {
        case 0:
            dataTable.tag = 0
            break
        case 1:
            dataTable.tag = 1
            break
        default:
            break
        }
        dataTable.reloadData()
        dataTable.separatorStyle = .none
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 0:
            return dataTitle.count
        case 1:
            return infoTitle.count
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dataTable.dequeueReusableCell(withIdentifier: NSStringFromClass(dataTableCell.self), for: indexPath) as! dataTableCell
        switch tableView.tag {
        case 0:
            cell.title.text = self.dataTitle[indexPath.row]
            handle = Auth.auth().addStateDidChangeListener { (auth, user) in
                if let user = user {
                    switch indexPath.row {
                    case 0:
                        cell.label.text = user.displayName
                        break
                    case 1:
                        cell.label.text = user.email
                        break
                    case 2:
                        cell.label.text = "総合工学科Ⅱ類 ロボティクスコース ３年"
                        break
                    default :
                        break
                    }
                } else { return }
            }
            return cell
        case 1:
            cell.title.text = self.infoTitle[indexPath.row]
            cell.label.text = self.info[indexPath.row]
            return cell
        default:
            break
        }
        return cell
    }
    
    
    
    func getImageByUrl(url: URL?) -> UIImage{
        do {
            let data = try Data(contentsOf: url!)
            let image = UIImage(data: data)!
            return image
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        return UIImage()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.AccountImageView.image = self.getImageByUrl(url: user.photoURL)
            } else { return }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AccountImageView.frame = CGRect(x: self.view.frame.width / 6, y: self.view.frame.height / 8, width: (self.view.frame.width / 3) * 2, height: (self.view.frame.width / 3) * 2)
        dataTable.frame = CGRect(x: 0, y: AccountImageView.frame.minY + AccountImageView.frame.height + 50, width: self.view.frame.width, height: self.view.frame.height - (AccountImageView.frame.height + AccountImageView.frame.minY + 50))
        
        
        
        
        
        
        AccountImageView.layer.masksToBounds = true
        AccountImageView.layer.cornerRadius = (self.view.frame.width / 3)
        AccountImageView.backgroundColor = UIColor(red: 193/255, green: 228/255, blue: 233/255, alpha: 1)
        self.view.addSubview(AccountImageView)
        
        
        
        let dataSelecter: UISegmentedControl = UISegmentedControl(items: params)
        dataSelecter.tintColor = UIColor(red: 0.13, green: 0.61, blue: 0.93, alpha: 1.0)
        dataSelecter.backgroundColor = .white
        dataSelecter.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "HirakakuProN-W6", size: 14.0)!,
            NSAttributedString.Key.foregroundColor: UIColor.white
            ], for: .selected)
        dataSelecter.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "HiraKakuProN-W3", size: 14.0)!,
            NSAttributedString.Key.foregroundColor: UIColor(red: 0.30, green: 0.49, blue: 0.62, alpha: 1.0)
            ], for: .normal)
        dataSelecter.selectedSegmentIndex = 0
        dataSelecter.addTarget(self, action: #selector(segmentChanged(_:)), for: UIControl.Event.valueChanged)
        dataSelecter.frame = CGRect(x: 10, y: AccountImageView.frame.minY + AccountImageView.frame.height + 10, width: self.view.frame.width - 20, height: 30)
        self.view.addSubview(dataSelecter)
        
        
        
        dataTable.delegate = self
        dataTable.dataSource = self
        dataTable.backgroundColor = .white
        dataTable.separatorInset = .zero
        dataTable.separatorStyle = .none
        dataTable.isScrollEnabled = false
        dataTable.rowHeight = dataTable.frame.height / 5
        dataTable.register(dataTableCell.self, forCellReuseIdentifier: NSStringFromClass(dataTableCell.self))
        self.view.addSubview(dataTable)
        
        
        
        
        self.title = "アカウント"
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        self.view.backgroundColor = .white
    }
}



class dataTableCell: UITableViewCell {
    var title: UILabel = UILabel()
    var label: UILabel = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        title.font = UIFont(name: "HiraginoSans-W6", size: 16)
        title.textColor = .black
        title.backgroundColor = .white
        self.addSubview(title)
        
        label.font = UIFont(name: "HiraginoSans-W3", size: 18)
        label.textColor = .black
        label.backgroundColor = .white
        self.addSubview(label)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        title.frame = CGRect(x: 10, y: 0, width: self.frame.width - 10, height: (self.frame.height / 4))
        label.frame = CGRect(x: 10, y: title.frame.height, width: self.frame.width - 10, height: (self.frame.height / 4) * 3)
    }
}
