
import Foundation
import UIKit

class trackModel {
    var name: String
    var minutes: Int
    var seconds: Int
    var artist: String

    
    init(name: String, minutes: Int, seconds: Int, artist: String) {
        self.name = name
        self.minutes = minutes
        self.seconds = seconds
        self.artist = artist
    }
    
}
