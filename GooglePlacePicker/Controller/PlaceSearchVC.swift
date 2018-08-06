//
//  PlaceSearchVC.swift
//  GooglePlacePicker
//
//  Created by king on 8/5/18.
//  Copyright © 2018 gangadhar. All rights reserved.
//

import UIKit
class PlaceSearchVC: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var searchTxt: UITextField!
    @IBOutlet weak var placeTableview: UITableView!
    var searchArray = [SearchListModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Search"
        self.searchTxt.delegate = self
        self.placeTableview.delegate = self
        self.placeTableview.dataSource = self
        self.placeTableview.estimatedRowHeight = 44
        self.placeTableview.rowHeight = UITableViewAutomaticDimension
        self.placeTableview.tableFooterView = UIView.init(frame: .zero)
        self.placeTableview.isHidden = true
    }
    // API result Method
    @objc func getSuccessResponce(dict:Dictionary<String,Any>) {
        
        guard let resultArray: Array<Any> = dict["results"] as? Array else { return  }
        if resultArray.count > 0 {
            
            for i in 0...resultArray.count-1 {
                let di = resultArray[i] as! Dictionary<String,Any>
                let searchDict = SearchListModel()
                searchDict.name = di["name"] as? String
                searchDict.address = di["formatted_address"] as? String
                searchDict.placeID = di["place_id"] as? String
                searchArray.append(searchDict)
            }
            
        }
        self.placeTableview.reloadData()
    }
    @objc func getFailResponce(dict:Dictionary<String,Any>) {
        
        self.placeTableview.reloadData()
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
        //noDataView.addSubview(imagvieww)
        return noDataView
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // Tableview Delegate and Datasource method
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchArray.count == 0 {
            self.placeTableview.backgroundView = self.NoRecordView()
        }else{
            self.placeTableview.backgroundView = nil
        }
        return searchArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell", for: indexPath)
        let listDict = searchArray[indexPath.row]
        cell.textLabel?.text = listDict.name
        cell.detailTextLabel?.text = listDict.address
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        let listDict = searchArray[indexPath.row]
        let vc = storyboard?.instantiateViewController(withIdentifier: "SearchDetailsVC") as! SearchDetailsVC
        vc.placeID = listDict.placeID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
        self.placeTableview.isHidden = true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.placeTableview.isHidden = false
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = self.searchTxt.text! + string
        self.callSeach(str: str)
        return true
    }
    func callSeach(str:String) {
        
        searchArray.removeAll()
        self.placeTableview.reloadData()
        let urlString = "textsearch/json?query="
        let parameter = urlString + "\(str)&key="
        WebManager.shareInstance.CallGetAPI(urlstring: parameter, delegate: self, onSuccess: #selector(self.getSuccessResponce(dict:)), onFailure: #selector(self.getFailResponce(dict:)))
    }
}
