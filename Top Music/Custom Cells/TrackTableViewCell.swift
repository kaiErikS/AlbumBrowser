
import UIKit

class TrackTableViewCell: UITableViewCell {

    @IBOutlet var trackLabel: UILabel!
    @IBOutlet var timelabel: UILabel!

    
    func setProperties(trackName: String, minutes: Int, seconds: Int){
        trackLabel.text = trackName
        timelabel.text = parseTime(value: minutes) + ":" + parseTime(value: seconds)
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
