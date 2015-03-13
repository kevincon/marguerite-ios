//
//  AboutTableViewController.swift
//  A UITableViewController for displaying information about the app.
//
//  Created by Kevin Conley on 3/11/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit

class AboutTableViewController: UITableViewController {

    // MARK: - Links

    private let margueriteOfficePhoneNumber = "650-724-9339"
    private let margueriteLostAndFoundPhoneNumber = "650-724-4309"
    private let margueriteEmail = "marguerite@stanford.edu"

    private let segueIdToWebsiteLookupTable = ["MargueriteWebsite": "http://transportation.stanford.edu/marguerite",
                                               "MargueriteFeedback": "http://transportation.stanford.edu/margueritecomments/",
                                               "MargueriteTwitter": "https://twitter.com/MargueriteApp",
                                               "MargueriteGitHub": "https://github.com/cardinaldevs/marguerite-ios"]

    // MARK: - Table sections/indices

    private struct TableLinks {
        static let ContactMargueriteSectionIndex = 1
        static let CallMargueriteOfficeRowIndex = 0
        static let CallMargueriteLostAndFoundRowIndex = 1
        static let EmailMargueriteOfficeRowIndex = 2

        static let AppFeedbackSectionIndex = 5
        static let SubmitAppFeedbackRowIndex = 1
    }

    // MARK: - UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case TableLinks.ContactMargueriteSectionIndex:
            switch indexPath.row {
            case TableLinks.CallMargueriteOfficeRowIndex:
                callPhoneNumber(margueriteOfficePhoneNumber)
            case TableLinks.CallMargueriteLostAndFoundRowIndex:
                callPhoneNumber(margueriteLostAndFoundPhoneNumber)
            case TableLinks.EmailMargueriteOfficeRowIndex:
                createEmail(margueriteEmail)
            default:
                break
            }
        case TableLinks.AppFeedbackSectionIndex:
            switch indexPath.row {
            case TableLinks.SubmitAppFeedbackRowIndex:
                Instabug.invokeFeedbackSender()
            default:
                break
            }
        default:
            break
        }
    }

    // MARK: - URL Convenience Methods

    private func createEmail(emailAddress: String) {
        openURL("mailto:\(emailAddress)")
    }

    private func callPhoneNumber(telephoneUrl: String) {
        openURL("tel://\(telephoneUrl)")
    }

    private func openURL(urlString: String) {
        if let url = NSURL(string: urlString) {
            UIApplication.sharedApplication().openURL(url)
        }
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let wvc = segue.destinationViewController as? WebViewController {
            wvc.urlToLoad = NSURL(string: segueIdToWebsiteLookupTable[segue.identifier!]!)
            // We don't have to deal with issues related to split view controller
            // embedding here (like we do when segueing to WebViewController from
            // the RoutesViewController), so don't extend the layout below 
            // opaque bars
            wvc.extendedLayoutIncludesOpaqueBars = false
        }
    }
}
