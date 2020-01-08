
import UIKit
import Alamofire
import SwiftyJSON
import AlamofireImage


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    //VARIABLES
    let dgData = DispatchGroup()
    let dgImg = DispatchGroup()
    let url = "https://theaudiodb.com/api/v1/json/1/mostloved.php?format=album"
    var albums: [albumModel] = []
    var imgDict: [NSURL: UIImage] = [:]
    
    //OUTLETS
    @IBOutlet var albumCollectionView: UICollectionView!
    @IBOutlet var viewSelection: UISegmentedControl!
    @IBOutlet var albumTableView: UITableView!
    
    //ACTIONS
   
    @IBAction func viewSelectionTapped(_ sender: Any) {
        let index = viewSelection.selectedSegmentIndex
        if index == 0 {
            albumCollectionView.isHidden = false
            albumTableView.isHidden = true
        } else {
            albumCollectionView.isHidden = true
            albumTableView.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //albums.append(test)
        getData()
        albumCollectionView.delegate = self
        albumCollectionView.dataSource = self
        albumTableView.delegate = self
        albumTableView.dataSource = self
        albumTableView.isHidden = true
        albumCollectionView.register(UINib(nibName: "CustomAlbumCell", bundle: nil), forCellWithReuseIdentifier: "albumCell")
        dgData.notify(queue: .main){
            self.albumCollectionView.reloadData()
            self.albumTableView.reloadData()
        }
    }
    
    func getImage(url: String) -> UIImage{
        let imageNsUrl:NSURL = NSURL(string: url)!
        let imageData:NSData = NSData(contentsOf: imageNsUrl as URL)!
        let image = UIImage(data: imageData as Data)
        return image!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumListItem", for: indexPath) as! AlbumTableViewCell
        let coverImage = getImage(url: albums[indexPath.row].coverUrl)
        
        cell.setProperties(album: albums[indexPath.row].title, artist: albums[indexPath.row].artist, image: coverImage)
        cell.albumLabel.sizeToFit()
        cell.artistLabel.sizeToFit()
        
        return cell
    }
    
    //PUSH DETAIL VC
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AlbumDetailViewController") as? AlbumDetailViewController
        let album = albums[indexPath.row]
        let url = album.coverUrl
        vc?.imageUrl = url
        vc?.albumId = album.id
        vc?.albumYear = album.year
        vc?.albumName = album.title
        vc?.artist = album.artist
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150.0, height: 200.0)
    }
    
    //PUSH DETAIL VC
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
       let vc = storyboard?.instantiateViewController(withIdentifier: "AlbumDetailViewController") as? AlbumDetailViewController
        let album = albums[indexPath.row]
        let url = album.coverUrl
        vc?.imageUrl = url
        vc?.albumId = album.id
        vc?.albumYear = album.year
        vc?.albumName = album.title
        vc?.artist = album.artist
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //***TEST DICTIONARY FOR STORAGE
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumCell", for: indexPath) as! CustomAlbumCell
        cell.layoutMargins.top = 8.00
        cell.albumTitle.text = albums[indexPath.row].title
        cell.artist.text = albums[indexPath.row].artist
        cell.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0)
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        
        let imageUrl:NSURL = NSURL(string: albums[indexPath.row].coverUrl)!
        let keyExists = imgDict[imageUrl] != nil
        if keyExists{
            cell.albumImage.image = imgDict[imageUrl]
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                
                let imageData:NSData = NSData(contentsOf: imageUrl as URL)!
                
                DispatchQueue.main.async {
                    let image = UIImage(data: imageData as Data)
                    cell.albumImage.image = image
                    self.imgDict.updateValue(image ?? UIImage(named: "loadIcon")!, forKey: imageUrl)
                }
            }
        }
        return cell
    }
 
    
    func getData() {
        dgData.enter()
        Alamofire.request(url, method: .get).responseJSON {
            response in
            if response.result.isSuccess{
                let json = JSON(response.value as Any)
                self.parseJSONData(json: json)
                self.dgData.leave()
            } else {
                print("Error: \(String(describing: response.result.error))")
            }
        }
    }
    
    func parseJSONData(json: JSON){
        
        if let albumArr = json["loved"].array {
            for a in albumArr {
                let album = albumModel(title: a["strAlbum"].string ?? "unknown",
                                       artist: a["strArtist"].string ?? "unknown",
                                       coverURL: a["strAlbumThumb"].string ?? "unknown",
                                       id: a["idAlbum"].string ?? "unknown",
                                       year: a["intYearReleased"].string ?? "unknown")
               
                albums.append(album)
                
            }

        }
   
    }
}
