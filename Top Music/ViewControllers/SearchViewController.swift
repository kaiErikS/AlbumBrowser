
import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //OUTLETS
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    let url = "https://theaudiodb.com/api/v1/json/1/searchalbum.php?a="
    let noImgUrl = "http://canaanmedia.com/wp-content/uploads/2014/09/12.jpg"
    var result: [albumModel] = []
    let dispatchG = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func getData(searchWord: String) {
        dispatchG.enter()
        Alamofire.request(url + searchWord, method: .get).responseJSON {
            response in
            if response.result.isSuccess{
                let json = JSON(response.value as Any)
                
                self.parseJSONData(json: json)
                self.dispatchG.leave()
            } else {
                print("Error: \(String(describing: response.result.error))")
            }
        }
    }
    
    func parseJSONData(json: JSON){
        
        if let albumArr = json["album"].array {
            for a in albumArr {
                let album = albumModel(
                    title: a["strAlbum"].string ?? "unknown",
                    artist: a["strArtist"].string ?? "unknown",
                    coverURL: checkForImage(value: a["strAlbumThumb"].string ?? ""),
                    id: a["idAlbum"].string ?? "unknown",
                    year: a["intYearReleased"].string ?? "unknown")
                
                result.append(album)
            }
        }
        
    }
    
    func checkForImage(value: String) -> String{
        let image = "https://imgaz.staticbg.com/thumb/large/oaupload/banggood/images/25/F3/603a7df2-8561-4530-9d74-dcf198ce1b07.jpg"
        if(value == ""){
            return image
        } else {
            return value
        }
    }
    
    func getImage(url: String) -> UIImage{
        let imageNsUrl:NSURL = NSURL(string: url)!
        let imageData:NSData = NSData(contentsOf: imageNsUrl as URL)!
        let image = UIImage(data: imageData as Data)
        return image!
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        SVProgressHUD.show()
        result.removeAll()
        getData(searchWord: searchBar.text!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
        self.view.endEditing(true)
        dispatchG.notify(queue: .main){
            SVProgressHUD.dismiss()
            self.tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.view.endEditing(true)
        SVProgressHUD.dismiss()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumListCell", for: indexPath) as! SearchTableViewCell
        let coverImage = getImage(url: result[indexPath.row].coverUrl)
        cell.setProperties(album: result[indexPath.row].title, artist: result[indexPath.row].artist, image: coverImage)
        
        return cell
    }

}
