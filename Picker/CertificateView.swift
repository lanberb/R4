//
//  CertificateView.swift
//  Picker
//
//  Created by Nao Sasaki on 2019/09/11.
//  Copyright © 2019 Nao Sasaki. All rights reserved.
//

import UIKit

class CertificateView: UIViewController {
    var CNViewer: UIView = UIView()
    var CNLabel: UILabel = UILabel()
    var CNText: UILabel = UILabel()
    
    func colorPicker() -> UIColor {
        let num1 = CGFloat.random(in: 0...200) / 255.0
        let num2 = CGFloat.random(in: 0...200) / 255.0
        let num3 = CGFloat.random(in: 0...200) / 255.0
        let color = UIColor(red: CGFloat(num1), green: CGFloat(num2), blue: CGFloat(num3), alpha: 1)
        return color
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print("CertificateView issued")
        self.view.backgroundColor = UIColor(red: 30/255.0, green: 30/255.0, blue: 30/255.0, alpha: 1)
        self.view.frame = CGRect(x: 0, y: self.view.frame.height / 5, width: self.view.frame.width, height: self.view.frame.height / 5 * 4)
        
        CNViewer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height / 5)
        CNViewer.backgroundColor = colorPicker()
        self.view.addSubview(CNViewer)
        
        CNText.frame = CGRect(x: 20, y: 15, width: self.view.frame.width - 20, height: 20)
        CNText.textColor = .white
        CNText.font = UIFont(name: "HiraginoSans-W3", size: 16)
        CNText.textAlignment = .left
        CNText.text = "Now you're attending:"
        self.CNViewer.addSubview(CNText)
        
        CNLabel.frame = CGRect(x: 15, y: CNText.frame.minY + CNText.frame.height + 10, width: self.view.frame.width - 15, height: CNViewer.frame.height / 2 - 25)
        CNLabel.textColor = .white
        CNLabel.font = UIFont(name: "HiraginoSans-W6", size: 40)
        CNLabel.textAlignment = .left
        CNLabel.text = UserDefaults.standard.string(forKey: "AttendingClassPass")
        self.CNViewer.addSubview(CNLabel)
        
        let InformationTable: UICollectionView = {
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
            layout.scrollDirection = .horizontal
            let InformationTable: UICollectionView = UICollectionView(frame:  CGRect(x: 0, y: (self.view.frame.height - self.view.frame.height / 15) - 50, width: self.view.frame.width, height: self.view.frame.height / 5 - 50), collectionViewLayout: layout)
            InformationTable.backgroundColor = .clear
            InformationTable.delegate = self
            InformationTable.dataSource = self
            InformationTable.register(InformationTableCell.self, forCellWithReuseIdentifier: NSStringFromClass(InformationTableCell.self))
            return InformationTable
        }()
        self.view.addSubview(InformationTable)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { InformationTable.reloadData() }
    }
}
extension CertificateView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let arr =  UserDefaults.standard.array(forKey: "classSchedule")
        if arr != nil {
            let classSchedule = UserDefaults.standard.array(forKey: "classSchedule")!
            return classSchedule.count
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(InformationTableCell.self), for: indexPath) as! InformationTableCell
        let classSchedule = UserDefaults.standard.array(forKey: "classSchedule")!
        cell.cellTitle.text = "\(indexPath.row + 1)時間目: " + "\((classSchedule[indexPath.row] as? String)!)"
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth: CGFloat = (collectionView.frame.width / 1.2) - 40
        let cellHeight: CGFloat = collectionView.frame.height - 20
        return CGSize(width: cellWidth, height: cellHeight)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
}




class InformationTableCell: UICollectionViewCell {
    var label1: UILabel = UILabel()
    var bgView: UIView = UIView()
    var cellTitle: UILabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bgView.backgroundColor = .black
        bgView.alpha = 0
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 20
        
        cellTitle.font = UIFont(name: "HiraginoSans-W6", size: 21)
        cellTitle.textColor = .white
        cellTitle.backgroundColor = .clear
        self.addSubview(cellTitle)
        
        
        self.backgroundColor = .clear
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 20
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        cellTitle.frame = CGRect(x: 10, y: self.frame.height / 2 - 25, width: self.frame.width - 20, height: 50)
    }
}
