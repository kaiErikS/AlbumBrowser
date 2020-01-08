
import UIKit

class AlbumTableViewCell: UITableViewCell {

    
    @IBOutlet var albumImage: UIImageView!
    @IBOutlet var albumLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    
    func setProperties(album: String, artist: String, image: UIImage){
        albumLabel.text = album
        artistLabel.text = artist
        albumImage.image = image
    }
    
}
