
import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet var coverImage: UIImageView!
    @IBOutlet var albumName: UILabel!
    @IBOutlet var artistName: UILabel!
    

    
    func setProperties(album: String, artist: String, image: UIImage){
        albumName.text = album
        artistName.text = artist
        coverImage.image = image
    }
    
}
