//
//  DetailVC.swift
//
//  Created by Romit Patel on 6/14/21.
//

import UIKit

class DetailVC: UIViewController {

    @IBOutlet weak var imgViewProfile: UIImageView!
    @IBOutlet weak var lblDesc: UILabel!
    
    @IBOutlet weak var lblTitleMain: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var lbltitle: UILabel!
    var relatedTopics : [String:Any] = [:]
//    var relatedTopics : [[String:Any]] = []

    var arraySelected : [Int] = []
    var strTitle : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Details"
        let dataVanue = relatedTopics["venue"] as? [String:Any]
     
        self.lblTitleMain.text = dataVanue?["name"] as? String
        self.lblDesc.text = "\(dataVanue?["city"] as? String ?? ""), \(dataVanue?["country"] as? String ?? "")"
//        self.lblDesc.text = relatedTopics["datetime_utc"] as? String
       
        let date = relatedTopics["datetime_utc"] as? String ?? "12:00:00T00:00:00"
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "EEEE, dd MMMM yyyy h:mm a"
        dateFormatterPrint.amSymbol = "AM"
        dateFormatterPrint.pmSymbol = "PM"

        if let date = dateFormatterGet.date(from: date) {
            print(dateFormatterPrint.string(from: date))
            self.lbltitle.text = dateFormatterPrint.string(from: date)
        } else {
           print("There was an error decoding the string")
        }
        if let icon = relatedTopics["performers"] as? [[String:Any]]{
            let data = icon[0]
            let url = data["image"] as? String
            if(url != ""){
                self.imgViewProfile.downloaded(from: "\(url ?? "")")
            }else{
                self.imgViewProfile.image = #imageLiteral(resourceName: "user.png")
            }
            
        }
        self.imgViewProfile.layer.cornerRadius = 10
        
        btnLike.setImage(#imageLiteral(resourceName: "heart_nfill.png"), for: .normal)
        btnLike.setImage(#imageLiteral(resourceName: "heart_fill"), for: .selected)

        let defaults = UserDefaults.standard
        arraySelected = defaults.object(forKey: "array_selected") as? [Int] ?? []
        if let id = dataVanue?["id"] as? Int{
            if arraySelected .contains(id)
            {
                btnLike.isSelected = true
            }else{
                btnLike.isSelected = false
            }

        }else{
            btnLike.isSelected = false
        }
        print(arraySelected)
        print(relatedTopics)
        
    }
    
    func splitAtFirst(str: String, delimiter: String) -> (a: String, b: String)? {
       guard let upperIndex = (str.range(of: delimiter)?.upperBound), let lowerIndex = (str.range(of: delimiter)?.lowerBound) else { return nil }
       let firstPart: String = .init(str.prefix(upTo: lowerIndex))
       let lastPart: String = .init(str.suffix(from: upperIndex))
       return (firstPart, lastPart)
    }
    @IBAction func btnLikePressed(_ sender: UIButton) {
       
        let dataVanue = relatedTopics["venue"] as? [String:Any]
        if let id = dataVanue?["id"] as? Int{
            if arraySelected .contains(id)
            {
                if let index = arraySelected.firstIndex(of: id) {
                    arraySelected.remove(at: index)
                    btnLike.isSelected = false

                }
            }else{
                arraySelected.append(id)
                btnLike.isSelected = true
            }
            let defaults = UserDefaults.standard
            defaults.set(arraySelected, forKey: "array_selected")

        }

        
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
