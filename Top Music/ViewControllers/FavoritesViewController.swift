
import UIKit
import CoreData
import Alamofire
import SwiftyJSON

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var tracks: [trackModel] = []
    let dispatchGFav = DispatchGroup()
    var coreData: [NSManagedObject] = []
    var recommendedArtistsList: [String] = []
    let dispatchGRec = DispatchGroup()
    let testDispatch = DispatchGroup()
    
    
    //OUTLETS
    @IBOutlet var tableView: UITableView!
    @IBOutlet var editButtonOutlet: UIBarButtonItem!
    @IBOutlet var collectionView: UICollectionView!
    
    //ACTIONS
    @IBAction func editBtn(_ sender: UIBarButtonItem) {
        self.tableView.isEditing = !self.tableView.isEditing
        sender.title = (self.tableView.isEditing) ? "Done" : "Edit"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        testDispatch.enter()
        getTracks()
        testDispatch.leave()
        
        testDispatch.notify(queue: .main){
            if(!self.coreData.isEmpty){
            self.getRecommendedData()
            } else {
                print("coreData empty")
            }
        }
        dispatchGFav.notify(queue: .main){
            self.tableView.reloadData()
        }
        dispatchGRec.notify(queue: .main){
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recommendedArtistsList.removeAll()
        tracks.removeAll()
        getTracks()
        if(!coreData.isEmpty){
            getRecommendedData()
        }
        dispatchGFav.notify(queue: .main){
            self.tableView.reloadData()
        }
        dispatchGRec.notify(queue: .main){
            //print(self.recommendedArtistsList[1] + "@@@@@@@@@")
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        editButtonOutlet.title = "Edit"
        tableView.isEditing = false
    }
    

    func getRecommendedData() {
        var recommendationsUrl = "https://tastedive.com/api/similar?q="
        let apiKey = "&k=351211-TopMusic-GXGOXO6X"
        let artist = coreData.randomElement()!.value(forKey: "artist") as! String
        recommendationsUrl = recommendationsUrl + artist + apiKey
       
        dispatchGRec.enter()
        Alamofire.request(recommendationsUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "", method: .get).responseJSON {
            response in
            if response.result.isSuccess{
                let json = JSON(response.value as Any)
                self.parseJSONData(json: json)
                self.recommendedArtistsList.shuffle()
                self.dispatchGRec.leave()
            } else {
                print("Error: \(String(describing: response.result.error))")
            }
        }
    }
    
  
    func parseJSONData(json: JSON){
        if let recommendedArr = json["Similar"]["Results"].array {
            for a in recommendedArr {
                guard let recommendedArtist = a["Name"].string else { return print("Error retrieving recommendation") }
                self.recommendedArtistsList.append(recommendedArtist)
            }
        }
    }

    func getTracks(){
        dispatchGFav.enter()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Track")
        
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            coreData = result as! [NSManagedObject]
            for track in result as! [NSManagedObject]{
                let parsedTrack = trackModel(
                    name: track.value(forKey: "title") as! String,
                    minutes: track.value(forKey: "minutes") as! Int,
                    seconds: track.value(forKey: "seconds") as! Int,
                    artist: track.value(forKey: "artist") as! String)
                
                tracks.append(parsedTrack)
            }
            dispatchGFav.leave()
        } catch {
            print("failed")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteTrackCell", for: indexPath) as! FavoriteTrackTableViewCell
    
        cell.setProperties(
            track: coreData[indexPath.row].value(forKey: "title") as! String,
            artist: coreData[indexPath.row].value(forKey: "artist") as! String,
            minutes: coreData[indexPath.row].value(forKey: "minutes") as! Int,
            seconds: coreData[indexPath.row].value(forKey: "seconds") as! Int)
        return cell
    }
    
    // INSPIRATION TAKEN FROM: https://www.youtube.com/watch?v=0iCZVUCTrHk
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedTrack = tracks[sourceIndexPath.item]
        tracks.remove(at: sourceIndexPath.item)
        tracks.insert(movedTrack, at: destinationIndexPath.item)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            tracks.remove(at: indexPath.item)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            context.delete(coreData[indexPath.row])
            coreData.remove(at: indexPath.row)
            do {
                try context.save()
            } catch {
                print("Error saving changes")
            }
            
            if(!coreData.isEmpty){
                recommendedArtistsList.removeAll()
                getRecommendedData()
            } else {
                collectionView.reloadData()
            }
            
            dispatchGRec.notify(queue: .main){
                self.collectionView.reloadData()
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendedArtistsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendedCell", for: indexPath) as! RecommendationCollectionViewCell
        cell.setProperties(artist: recommendedArtistsList[indexPath.row])
        cell.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0)
        cell.layer.cornerRadius = 10
        return cell
    }
}
