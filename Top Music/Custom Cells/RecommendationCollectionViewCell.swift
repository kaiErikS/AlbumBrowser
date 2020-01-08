
import UIKit

class RecommendationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var artistLabel: UILabel!
    
    func setProperties(artist: String){
       artistLabel.text = artist
    }
}
