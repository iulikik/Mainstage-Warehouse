//
//  ViewController.swift
//  Mainstage Warehouse
//
//  Created by ik_moraru on 24.10.2024.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    // MARK: - Properties
    private var webView: WKWebView!
    private var progressView: UIProgressView!
    private var shareButton: UIButton!
    
    // MARK: - Constants
    private enum Constants {
        static let initialURL = "https://mainstage.ikmoraru.com"
        static let pdfViewPath = "/pdf_view/"
        static let buttonSize: CGFloat = 44  // Following Apple's minimum touch target size([1](https://developer.apple.com/design/tips/))
        static let buttonPadding: CGFloat = 16
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupProgressView()
        setupShareButton()
        setupGestures()
        loadInitialContent()
    }
    
    // MARK: - Setup Methods
    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        webView = WKWebView(frame: view.frame, configuration: configuration)
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        // Setup webview constraints
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add observer for progress
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), 
                           options: .new, context: nil)
    }
    
    private func setupProgressView() {
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    
    private func setupShareButton() {
        shareButton = UIButton(type: .system)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        
        let shareIcon = UIImage(systemName: "square.and.arrow.up")
        shareButton.setImage(shareIcon, for: .normal)
        shareButton.isHidden = true
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        
        view.addSubview(shareButton)
        
        NSLayoutConstraint.activate([
            shareButton.topAnchor.constraint(equalTo: progressView.bottomAnchor, 
                                           constant: Constants.buttonPadding),
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, 
                                                constant: -Constants.buttonPadding),
            shareButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            shareButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize)
        ])
    }
    
    private func setupGestures() {
        setupSwipeGestures()
        setupPullToRefresh()
    }
    
    private func loadInitialContent() {
        guard let url = URL(string: Constants.initialURL) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    // MARK: - Gesture Setup
    private func setupSwipeGestures() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
    }
    
    private func setupPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshPage), for: .valueChanged)
        webView.scrollView.addSubview(refreshControl)
    }
    
    // MARK: - Observer Methods
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, 
                             change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == #keyPath(WKWebView.estimatedProgress) else { return }
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = webView.estimatedProgress >= 1.0
    }
    
    // MARK: - Action Methods
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .right where webView.canGoBack:
            webView.goBack()
        case .left where webView.canGoForward:
            webView.goForward()
        default:
            break
        }
    }
    
    @objc private func refreshPage(_ sender: UIRefreshControl) {
        webView.reload()
        sender.endRefreshing()
    }
    
    @objc private func shareButtonTapped() {
        guard let url = webView.url else { return }
        let printItem = webView.viewPrintFormatter()
        let activityVC = UIActivityViewController(
            activityItems: [url, printItem],
            applicationActivities: nil
        )
        present(activityVC, animated: true)
    }
    
    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url else { return }
        shareButton.isHidden = !url.absoluteString.contains(Constants.pdfViewPath)
    }
}
