//
//  WebViewController.swift
//  AutomaticWriter
//
//  Created by Raphael on 13.01.15.
//  Copyright (c) 2015 HEAD Geneva. All rights reserved.
//

import Cocoa
import WebKit

// =============
// I tried to use a WKWebView, but couldn't load a simple request.
// =============

class WebViewController: NSViewController {
    
    // TODO: clean the class by deleting the old webView
    @IBOutlet weak var webView: WebView!
    
    var wkWebView:WKWebView?
    
    // TODO: plus besoin de ça
    var hasUrl = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        wkWebView = WKWebView()
        view = wkWebView!
        
        print("web view controller did load\n");
    }
    
    func loadFile(path:String) {
        // make it a valid url
        var urlPath = path.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        if let actualUrlPath = urlPath {
            // the contructor doesn't add "file://" so we do it manually
            let url = NSURL(string:"file://\(actualUrlPath)")
            if let tempUrl = url {
                let req = NSURLRequest(URL: tempUrl)
                //webView.mainFrame.loadRequest(req)
                wkWebView!.loadRequest(req)
                hasUrl = true
            }
        }
    }
    
    func reload() {
        if !hasUrl {
            return
        }
        wkWebView!.reload()
        //webView.mainFrame.reload()
    }
    
}
