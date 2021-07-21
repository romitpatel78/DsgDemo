//
//  ViewController.swift
//
//  Created by Romit Patel on 6/14/21.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var filteredData: [String]!
    var arrrelatedTopics : [[String:Any]] = []
    var arrCharName : [String] = []
    var arraySelected : [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getData()
        self.tblView.estimatedRowHeight = 44.0
        self.tblView.rowHeight = UITableView.automaticDimension
        searchBar.delegate = self
        tblView.estimatedRowHeight = 50.0  //Give an approximation here
        tblView.rowHeight = UITableView.automaticDimension
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tblView.reloadData()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! custCell
        //   let dataDict = arrCharName[indexPath.row]
        let data = arrrelatedTopics[indexPath.row]
        let dataVanue = data["venue"] as? [String:Any]
        cell.lblText.text = dataVanue?["name"] as? String
        cell.lblDetail1.text = "\(dataVanue?["city"] as? String ?? ""), \(dataVanue?["country"] as? String ?? "")"
        
        let date = data["datetime_utc"] as? String ?? "12:00:00T00:00:00"
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "EEEE, dd MMMM yyyy h:mm a"
        dateFormatterPrint.amSymbol = "AM"
        dateFormatterPrint.pmSymbol = "PM"

        if let date = dateFormatterGet.date(from: date) {
            print(dateFormatterPrint.string(from: date))
            cell.lblDetail2.text = dateFormatterPrint.string(from: date)
        } else {
           print("There was an error decoding the string")
        }
        
        let defaults = UserDefaults.standard
        arraySelected = defaults.object(forKey: "array_selected") as? [Int] ?? []
        cell.imgheartView.isHidden = true
        if let id = dataVanue?["id"] as? Int{
            if arraySelected .contains(id)
            {
                cell.imgheartView.image = #imageLiteral(resourceName: "heart_fill")
                cell.imgheartView.isHidden = false
            }else{
                cell.imgheartView.image = #imageLiteral(resourceName: "heart_nfill")
                cell.imgheartView.isHidden = true
            }

        }else{
            cell.imgheartView.image = #imageLiteral(resourceName: "heart_nfill")
            cell.imgheartView.isHidden = true
        }

//        imgheartView
//        let performar = data["performers"]
        if let icon = data["performers"] as? [[String:Any]]{
            let data = icon[0]
            let url = data["image"] as? String
            if(url != ""){
                cell.imgView.downloaded(from: "\(url ?? "")")
            }else{
                cell.imgView.image = #imageLiteral(resourceName: "user.png")
            }
            
        }
        cell.imgView.layer.cornerRadius = 10
            //        cell.lblText.layoutIfNeeded()
            return cell
            
        }
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
        }
        var request : URLRequest!
        func getData(){
            //     var url : String = "http://api.duckduckgo.com/?q=simpsons+characters&format=json"
            
            
            let bundleID = Bundle.main.bundleIdentifier ?? ""
            request = URLRequest(url: URL(string: "https://api.seatgeek.com/2/events?client_id=MjI0NzA2Nzd8MTYyNTgxNTMxNy4xMDEwNDU&q=swift")!)
            
            request.httpMethod = "GET"
            
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                print(response!)
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                    
                    if let data = json["events"] as? [[String:Any]]{
                        self.arrrelatedTopics = data
                        for data in self.arrrelatedTopics{
                            
                            if let text = data["title"] as? String{
                                let value = self.splitAtFirst(str: text, delimiter: " -")
                                self.arrCharName.append(value?.a ?? "")
                                
                                print(value?.a ?? "")
                            }
                        }
                        self.filteredData = self.arrCharName
                        print(self.arrCharName)
                        print(self.arrrelatedTopics)
                        DispatchQueue.main.async {
                            self.tblView.dataSource = self
                            self.tblView.delegate = self
                            self.tblView.reloadData()
                        }
                        
                        
                    }
                    print(json)
                } catch {
                    print("error")
                }
            })
            
            task.resume()
            
        }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            let data = arrrelatedTopics[indexPath.row]
            let vc = self.storyboard?.instantiateViewController(identifier: "DetailVC") as!
                DetailVC
            vc.relatedTopics = data
            self.navigationController?.pushViewController(vc, animated: true)
            
            
        }
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            // When there is no text, filteredData is the same as the original data
            // When user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            filteredData = searchText.isEmpty ? arrCharName : arrCharName.filter { (item: String) -> Bool in
                // If dataItem matches the searchText, return true to include it
                return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
            
            tblView.reloadData()
        }
        
        func splitAtFirst(str: String, delimiter: String) -> (a: String, b: String)? {
            guard let upperIndex = (str.range(of: delimiter)?.upperBound), let lowerIndex = (str.range(of: delimiter)?.lowerBound) else { return nil }
            let firstPart: String = .init(str.prefix(upTo: lowerIndex))
            let lastPart: String = .init(str.suffix(from: upperIndex))
            return (firstPart, lastPart)
        }
        
    }
    
    
    class custCell:UITableViewCell{
        
        @IBOutlet weak var imgheartView: UIImageView!
        @IBOutlet weak var lblText: UILabel!
        @IBOutlet weak var lblDetail1: UILabel!
        @IBOutlet weak var lblDetail2: UILabel!
        @IBOutlet weak var imgView: UIImageView!
    }
