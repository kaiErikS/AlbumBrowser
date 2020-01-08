
import UIKit

class FavoriteTrackTableViewCell: UITableViewCell {

    @IBOutlet var trackLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    
    func setProperties(track: String, artist: String, minutes: Int, seconds: Int){
        let stringMin = parseTime(value: minutes)
        let stringSec = parseTime(value: seconds)
        trackLabel.text = track
        artistLabel.text = artist
        durationLabel.text = stringMin + ":" + stringSec
    }
    
    func parseTime(value: Int) -> String {
        var parsedTime = ""
        if(value < 10){
            parsedTime = "0" + String(value)
        } else {
            parsedTime = String(value)
        }
        
        return parsedTime
    }
    
}
