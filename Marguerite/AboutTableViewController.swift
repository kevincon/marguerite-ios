//
//  AboutTableViewController.swift
//  Marguerite
//
//  Created by Kevin Conley on 3/11/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit

class AboutTableViewController: UITableViewController {

    private let margueriteEmail = "marguerite@stanford.edu"
    private let websiteLookupTable = ["MargueriteWebsite": "http://transportation.stanford.edu/marguerite",
                                      "MargueriteFeedback": "http://transportation.stanford.edu/margueritecomments/",
                                      "MargueriteTwitter": "https://twitter.com/MargueriteApp",
                                      "MargueriteGitHub": "https://github.com/cardinaldevs/marguerite-ios"]

    func createEmail(emailAddress: String) {
        openURL("mailto:\(emailAddress)")
    }

    func callPhoneNumber(telephoneUrl: String) {
        openURL("tel://\(telephoneUrl)")
    }

    private func openURL(urlString: String) {
        if let url = NSURL(string: urlString) {
            UIApplication.sharedApplication().openURL(url)
        }
    }

    private func openWebPage(url: String) {

    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let wvc = segue.destinationViewController as? WebViewController {
            wvc.urlStringToLoad = websiteLookupTable[segue.identifier!]
        }
    }
}
