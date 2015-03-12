//
//  WebViewController.swift
//  Marguerite
//
//  Created by Kevin Conley on 3/11/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {

    // MARK: - Public API

    var urlStringToLoad: String?

    // MARK: - Private API
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)

    // MARK: - Outlets

    @IBOutlet weak var backButton: UIBarButtonItem!

    @IBOutlet weak var forwardButton: UIBarButtonItem!

    @IBOutlet weak var webView: UIWebView! {
        didSet {
            webView.delegate = self
            if let url = NSURL(string: urlStringToLoad!) {
                let urlRequest = NSURLRequest(URL: url)
                webView.loadRequest(urlRequest)
            }
        }
    }

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        let barButton = UIBarButtonItem(customView: activityIndicatorView)
        navigationItem.rightBarButtonItem = barButton
    }

    // MARK: - Actions

    @IBAction func goBack(sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    @IBAction func goForward(sender: UIBarButtonItem) {
        webView.goForward()
    }

    // MARK: - UIWebViewDelegate

    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicatorView.startAnimating()
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicatorView.stopAnimating()
        backButton.enabled = webView.canGoBack
        forwardButton.enabled = webView.canGoForward
    }
}
