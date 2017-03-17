//
//  ArticleDetailViewController.swift
//  ManuNews
//
//  Created by MILIKET on 2/21/17.
//  Copyright © 2017 Thành Lã. All rights reserved.
//

import UIKit
import SnapKit
import PHExtensions
import MXParallaxHeader
import WebKit

class ArticleDetailViewController: GeneralViewController {
    fileprivate enum Size: CGFloat {
        case padding15 = 15, padding5 = 5, padding10 = 10, button = 44
    }
    
    var headerView: HeaderImageView!
    
    var webView: UIWebView!
    
    var article: Article!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAllSubviews()
        view.setNeedsUpdateConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func updateViewConstraints() {
        if !didSetupConstraints {
            setupAllConstraints()
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    
}

//------------------------------
//MARK: SELECTOR
//------------------------------
extension ArticleDetailViewController {
    func back(_ sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
}

//------------------------------
//MARK: PRIVATE METHOD
//------------------------------
extension ArticleDetailViewController {
    fileprivate func showLoadingIndicator(_ show: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = show
    }
}

//------------------------------
//MARK: SETUP VIEW
//------------------------------
extension ArticleDetailViewController {
    func setupAllSubviews() {
        view.backgroundColor = UIColor.white
        title = "Chi tiết"
        
        setupBarButtonItem()
        
        headerView = setupHeaderImage()
        
        webView = setupWebview(with: headerView)
        
        view.addSubview(webView)
        
    }
    
    func setupAllConstraints() {
        
        webView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let frame = view.frame
        
        
        webView.frame = frame
        
    }
    
    func setupBarButtonItem() {
        let left = setupBarButton(image: Icon.Navi.back, selector: #selector(self.back(_:)), target: self)
        navigationItem.leftBarButtonItem = left
    }
    
    
    func setupHeaderImage() -> HeaderImageView {
        let header = HeaderImageView()
        
        guard let article = article, let url = URL(string: article.avatar) else { return header }
        
        let cache = URLCache.shared
        if let data = cache.cachedResponse(for: URLRequest(url: url)) {
            if let image = UIImage(data: data.data) {
                header.imageView.image = image
                return header
            }
        }
        
        let task = URLSession.shared.dataTask(with: url) { (responseData, responseUrl, error) -> Void in
            
            guard let data = responseData else { return }
            
            DispatchQueue.main.async(execute: {
                if let responseUrl = responseUrl {
                    cache.storeCachedResponse(
                        CachedURLResponse(response: responseUrl, data: data),
                        for: URLRequest(url: url)
                    )
                    
                    if let image = UIImage(data: data) {
                        header.imageView.image = image
                    }
                }
            })
            
        }
        task.resume()
        
        return header
    }
    
    func setupWebview(with headerView: HeaderImageView) -> UIWebView {
        
        let webView = UIWebView()
        
        webView.scrollView.parallaxHeader.view = headerView
        webView.scrollView.parallaxHeader.height = 200
        webView.scrollView.parallaxHeader.mode = .fill
        webView.scrollView.parallaxHeader.minimumHeight = 0
        webView.scrollView.parallaxHeader.delegate = self
        
        guard let article = article else { return webView }
        
        webView.loadHTMLString(article.content, baseURL: nil)
        
        return webView
    }
    
    func setupHeaderTransparent() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.white.alpha(0.001)
        return view
    }
    
}

extension ArticleDetailViewController: MXParallaxHeaderDelegate {
    func parallaxHeaderDidScroll(_ parallaxHeader: MXParallaxHeader) {
        
    }
}


