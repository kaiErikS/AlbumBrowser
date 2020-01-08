
import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class AlbumDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var artist = ""
    var imageUrl = ""
    var albumName = ""
    var albumId = ""
    var albumYear = ""
    var url = "https://theaudiodb.com/api/v1/json/1/track.php?m="
    var tracks: [trackModel] = []
    let dg = DispatchGroup()
    
    @IBOutlet var albumImage: UIImageView!
    @IBOutlet var albumLabel: UILabel!
    @IBOutlet var yearLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getImage()
        self.title = albumName
        albumLabel.text = albumName
        yearLabel.text = albumYear
        artistLabel.text = artist
        getTracks()
        dg.notify(queue: .main){
            self.tableView.reloadData()
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackListItem", for: indexPath) as! TrackTableViewCell
        cell.setProperties(trackName: tracks[indexPath.row].name, minutes: tracks[indexPath.row].minutes, seconds: tracks[indexPath.row].seconds)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //INSPIRATION TAKEN FROM: https://www.youtube.com/watch?v=dIXkR-2rdvM
        let track = tracks[indexPath.row]
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Track", in: context)
        let newTrack = NSManagedObject(entity: entity!, insertInto: context)
        
        newTrack.setValue(track.name, forKey: "title")
        newTrack.setValue(track.artist, forKey: "artist")
        newTrack.setValue(track.minutes, forKey: "minutes")
        newTrack.setValue(track.seconds, forKey: "seconds")
        
        do {
            try context.save()
            print("Track saved")
            tableView.cellForRow(at: indexPath)?.contentView.backgroundColor = UIColor .yellow
        } catch {
            print("Error saving track")
        }
    }
    
    
    
    func getImage(){
        let imageNsUrl:NSURL = NSURL(string: imageUrl)!
        let imageData:NSData = NSData(contentsOf: imageNsUrl as URL)!
        let image = UIImage(data: imageData as Data)
        albumImage.image = image
    }
    
    func getTracks(){
        dg.enter()
        url = url + albumId
        Alamofire.request(url, method: .get).responseJSON {
            response in
            if response.result.isSuccess{
                let json = JSON(response.value as Any)
                self.parseJSONData(json: json)
                self.dg.leave()
                
            } else {
                print("Error: \(String(describing: response.result.error))")
            }
        }
    }
    
    func parseJSONData(json: JSON){
        var tMinutes: Int
        var tSeconds: Int
        var rawTime: String
        
        if let albumArr = json["track"].array {
            for a in albumArr {
                rawTime = a["intDuration"].string ?? "unknown"
                tMinutes = convertMinutes(time: rawTime)
                tSeconds = convertSeconds(time: rawTime)
                let track = trackModel(
                    name: a["strTrack"].string ?? "unknown",
                    minutes:  tMinutes, seconds: tSeconds,
                    artist: a["strArtist"].string ?? "unknown")
                tracks.append(track)
            }
        }
    }
    
    func convertMinutes(time: String) -> Int{
        let cTime: Int = Int(time)!
        let seconds: Int = cTime / 1000
        return seconds / 60
    }
    
    func convertSeconds(time: String) -> Int{
        let cTime: Int = Int(time)!
        let seconds: Int = cTime / 1000
        return seconds % 60
    }
}
