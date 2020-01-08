
import Foundation
import UIKit

    class albumModel {
        var title: String
        var artist: String
        var coverUrl: String
        var image: UIImage?
        var id: String
        var year: String
        
        init(title: String, artist: String, coverURL: String, id: String, year: String) {
            self.title = title
            self.artist = artist
            self.coverUrl = coverURL
            self.id = id
            self.year = year
        }
        
    }

    
    

