# Top-Music-IOS

My comments to the project:

The search page is missing a feature, which is pushing the detail page when pressing the cells.
I sadly discovered this a little late so it has not been implemented, but i am unsure if it is a requirement or not since it is not stated in the exam text. But i naturally would prefer to have implemented it.

Cocoapods used:

SVProgressHUD:

This was implemented to provide a visualization of the application doing async tasks. I preferred this over just using a "Loading..." label, as it provides a better looking and smoother experience.

Alamofire:

I decided to use Alamofire mainly because the assignment did not require complex network calls, but rather simple ones that Alamofire could handle well. That resulted in less boilerplate, since it is built on the other alternative, which was NSURLSession.
This leads to less code, and a cleaner project which is something i appreciate.

SwiftyJSON:

SwiftyJSON was my choice for parsing the JSON data, this is because the alternatives such as JSONDecoder requires a bit more "work" to handle types. This is something SwityJSON handles for me, which makes the code cleaner and easier to debug during the development process.



Sources:

The icons used are downloaded from: https://icons8.com/

These videos have provided some lines of code and inspiration which i have implemented. Where they have been used has been commented in the code.
https://www.youtube.com/watch?v=dIXkR-2rdvM
https://www.youtube.com/watch?v=0iCZVUCTrHk

Cocoapods:
https://cocoapods.org/pods/SVProgressHUD
https://cocoapods.org/pods/SwiftyJSON
https://cocoapods.org/pods/Alamofire

