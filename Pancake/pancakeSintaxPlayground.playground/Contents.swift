//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


let spotifySession = NSUserDefaults.standardUserDefaults()

if let sessionObj:AnyObject = spotifySession.objectForKey("userLoggedIn") {
    dashboardViewController
} else {

}
