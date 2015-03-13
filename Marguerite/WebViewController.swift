//
//  WebViewController.swift
//  A UIViewController for displaying webpages in a UIWebView.
//
//  Created by Kevin Conley on 3/11/15.
//  Copyright (c) 2015 Kevin Conley. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {

    // MARK: - Public API

    var urlToLoad: NSURL?
    var hideToolbar = false

    // MARK: - Private API
    
    private let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)

    // MARK: - Outlets

    @IBOutlet private weak var errorLabel: UILabel!

    @IBOutlet private weak var toolbar: UIToolbar! {
        didSet {
            if hideToolbar {
                toolbar.removeFromSuperview()
            }
        }
    }

    @IBOutlet private weak var backButton: UIBarButtonItem!

    @IBOutlet private weak var forwardButton: UIBarButtonItem!

    @IBOutlet private weak var webView: UIWebView! {
        didSet {
            webView.delegate = self
            if urlToLoad != nil {
                let urlRequest = NSURLRequest(URL: urlToLoad!)
                webView.loadRequest(urlRequest)
            } else {
                activityIndicatorView.stopAnimating()
                showErrorLabel()
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

    @IBAction private func goBack(sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    @IBAction private func goForward(sender: UIBarButtonItem) {
        webView.goForward()
    }

    // MARK: - UIWebViewDelegate

    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicatorView.startAnimating()
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicatorView.stopAnimating()
        if !hideToolbar {
            backButton.enabled = webView.canGoBack
            forwardButton.enabled = webView.canGoForward
        }
        hideErrorLabel()
    }

    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        activityIndicatorView.stopAnimating()
        showErrorLabel()
    }

    // MARK: - Error label showing/hiding

    private func showErrorLabel() {
        errorLabel.hidden = false
        errorLabel.superview?.bringSubviewToFront(self.errorLabel)
    }

    private func hideErrorLabel() {
        errorLabel.hidden = true
    }
}
