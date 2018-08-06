//
//  SearchDetailsVC.swift
//  GooglePlacePicker
//
//  Created by king on 8/5/18.
//  Copyright © 2018 gangadhar. All rights reserved.
//

import UIKit

class SearchDetailsVC: UIViewController,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource{
    var placeID = String()
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    @IBOutlet weak var slidescroller : UIScrollView!
    @IBOutlet weak var reviewtableView : UITableView!
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var iconImg : UIImageView!
    @IBOutlet weak var addressLabel : UILabel!
    var reviewArray = Array<Any>()
    var collectionArray = Array<Any>()
    var detailsDict = PlaceDetailModel()
    var imageSlideArray = Array<Any>()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Details"
        self.reviewtableView.delegate = self
        self.reviewtableView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.reviewtableView.estimatedRowHeight = 44
        self.reviewtableView.rowHeight = UITableViewAutomaticDimension
        self.reviewtableView.tableFooterView = UIView.init(frame: .zero)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.showActivityIndicator()
        activityIndicator.startAnimating()
        let urlString = "details/json?placeid="
        let parameter = urlString + "\(placeID)&key="
        WebManager.shareInstance.CallGetAPI(urlstring: parameter, delegate: self, onSuccess: #selector(self.getSuccessResponce(dict:)), onFailure: #selector(self.getFailResponce(dict:)))
    }
    //No record View
    func NoRecordView()->UIView{
        let noDataView : UIView = UIView.init(frame: CGRect(x: 8, y: (view.frame.size.height-120)/2, width: self.view.frame.size.width-16, height: 120))
        noDataView.backgroundColor = UIColor.white
        let noDataLabel : UILabel = UILabel.init(frame: CGRect(x: 8, y: noDataView.frame.origin.y, width: noDataView.frame.size.width-16, height: 40))
        noDataLabel.text = "No Data Found."
        noDataLabel.font = UIFont(name: "Arial", size: 20)
        noDataLabel.textAlignment = .center
        noDataView.addSubview(noDataLabel)
        return noDataView
    }
    // API result Method
    @objc func getSuccessResponce(dict:Dictionary<String,Any>) {
        
        activityIndicator.stopAnimating()
        guard let resultdict: Dictionary<String,Any> = dict["result"] as? Dictionary else { return  }
        if ((resultdict["formatted_address"]) != nil) {
            detailsDict.name = resultdict["name"] as! String
            detailsDict.url = resultdict["url"] as! String
            detailsDict.formatted_address = resultdict["formatted_address"] as! String
            detailsDict.website = resultdict["website"] as? String
            detailsDict.international_phone_number = resultdict["international_phone_number"] as? String
            detailsDict.icon = resultdict["icon"] as? String
            let arr = resultdict["photos"] as! Array<Any>
            if arr.count > 0{
                for i in 0...arr.count-1{
                    let di = arr[i] as! Dictionary<String,Any>
                    let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(String(format:"%@", di["width"] as! CVarArg))&photoreference=\(di["photo_reference"] as! String)&key="
                    imageSlideArray.append(urlString)
                }
                self.addScrollerImage()
            }
            if detailsDict.international_phone_number != nil{
                collectionArray.append("Call")
            }
            if detailsDict.url != nil{
                collectionArray.append("Direction")
            }
            if detailsDict.website != nil{
                collectionArray.append("Web Site")
            }
            reviewArray = (resultdict["reviews"] as? Array<Any>)!
            collectionView.reloadData()
            self.showData()
        }
    }

    func showData() {
        self.nameLabel.text = detailsDict.name
        self.addressLabel.text = detailsDict.formatted_address
        let url = URL(string:detailsDict.icon)
        if let data = try? Data(contentsOf: url!)
        {
            let image: UIImage = UIImage(data: data)!
            iconImg.image = image
        }
        self.reviewtableView.reloadData()
    }
    @objc func getFailResponce(dict:Dictionary<String,Any>) {
        activityIndicator.stopAnimating()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //add image to scrollerView
    func addScrollerImage() {
        self.slidescroller.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
        let scrollViewWidth:CGFloat = self.slidescroller.frame.width
        for i in 0...imageSlideArray.count-1 {
            let imgviews = UIImageView(frame: CGRect(x:scrollViewWidth * CGFloat(i), y:0,width:scrollViewWidth, height:54))
            let url = URL(string:imageSlideArray[i] as! String)
            if let data = try? Data(contentsOf: url!)
            {
                let image: UIImage = UIImage(data: data)!
                imgviews.image = image
            }
            imgviews.contentMode = .scaleToFill
            self.slidescroller.delegate = self
            slidescroller.addSubview(imgviews)
            self.slidescroller.contentSize = CGSize(width:self.slidescroller.frame.width * CGFloat(imageSlideArray.count), height:54)
        }
        navigationItem.backBarButtonItem?.title = ""
        Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(moveToNextPage), userInfo: nil, repeats: true)
    }
    // timer for auto slide image
    @objc func moveToNextPage (){
        let pageWidth:CGFloat = self.slidescroller.frame.width
        let maxWidth:CGFloat = pageWidth * CGFloat(imageSlideArray.count)
        let contentOffset:CGFloat = self.slidescroller.contentOffset.x
        var slideToX = contentOffset + pageWidth
        if  contentOffset + pageWidth == maxWidth
        {
            slideToX = 0
            self.slidescroller.scrollRectToVisible(CGRect(x:slideToX, y:0, width:pageWidth, height:self.slidescroller.frame.height), animated: false)
        }else{
            self.slidescroller.scrollRectToVisible(CGRect(x:slideToX, y:0, width:pageWidth, height:self.slidescroller.frame.height), animated: true)
        }
    }
    func showActivityIndicator(){
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        let transform: CGAffineTransform = CGAffineTransform(scaleX: 3, y: 3)
        activityIndicator.transform = transform
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
    }
    // Tableview Delegate and Datasource method
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Reviews"
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if reviewArray.count == 0 {
            self.reviewtableView.backgroundView = self.NoRecordView()
        }else{
            self.reviewtableView.backgroundView = nil
        }
        return reviewArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell", for: indexPath)
        let listDict = reviewArray[indexPath.row] as! Dictionary<String,Any>
        cell.textLabel?.text = (listDict["author_name"] as! String)
        cell.detailTextLabel?.text = (listDict["text"] as! String)
        return cell
    }
    // CollectionView Delegate and Datasource method
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"DetailsCell", for: indexPath) as! DetailCollectionCell
        cell.titleLabel.text = (collectionArray[indexPath.row] as! String)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let str = collectionArray[indexPath.row] as! String
        if str == "Call"{
            if let url = URL(string: "tel://\(detailsDict.international_phone_number)"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        if str == "Direction"{
            if let url = URL(string: detailsDict.url), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        if str == "Web Site"{
            if let url = URL(string: detailsDict.website), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
}
