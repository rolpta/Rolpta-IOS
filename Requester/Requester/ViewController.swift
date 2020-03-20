//
//  ViewController.swift
//  Ovestt
//
//  Created by Tony on 11/11/2019.
//  Copyright © 2019 Ovestt. All rights reserved.
//
import UIKit
import WebKit

import AVFoundation

import SwiftLocation

import SwiftySound

import CoreLocation
import MapKit

public protocol ViewControllerDelegate {
    func ViewControllerImageDidFilter(image: UIImage)
    func ViewControllerDidCancel()
}

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, CLLocationManagerDelegate {
    
    public var current_gps = ""
    
    public var authorization = ""
    public var syncapi = "https://zapi.rolpta.com/profile/location"
    
    public var busy = false
    public var last_lat = 0.0
    public var last_lng = 0.0
    
    
    public var delegate: ViewControllerDelegate?
    public var locationManager: CLLocationManager?
    
    var wkWebView: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        wkWebView = WKWebView(frame: view.bounds, configuration: WKWebViewConfiguration())
        
        wkWebView.configuration.preferences.javaScriptEnabled = true
        wkWebView.configuration.userContentController.add(self, name: "bridge") //<-
        
        wkWebView.uiDelegate = self
        wkWebView.scrollView.bounces = false
        
        wkWebView.navigationDelegate = self
        view.addSubview(wkWebView!)
        let url = URL(string: "http://localhost:"+String(MyConfig.port)+"/www/")!
        wkWebView.load(URLRequest(url: url))
        
        
        startTracking()
    }
    
    func startTracking() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        locationManager?.requestAlwaysAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.distanceFilter = kCLDistanceFilterNone
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.startMonitoringSignificantLocationChanges()
        
        let request = LocationManager.shared.locateFromGPS(.continous, accuracy: .city) { data in
            switch data {
            case .failure(let error):
                print("Location error: \(error)")
            case .success(let location):
                let lat=location.coordinate.latitude
                let lng=location.coordinate.longitude
                
                //if(self.last_lat.isEqual(to: lat) && self.last_lng.isEqual(to: lng)) {
                //    print ("Awaiting new location")
                //} else {
                self.current_gps = "\(lat),\(lng)"
                self.setLocation(lat: lat,lng: lng)
                //}
            }
        }
        //request.dataFrequency = .fixed(minInterval: 10, minDistance: 10) // minimum 40 seconds & 100 meters since the last update.
    }
    
    func setLocation(lat: Double,lng: Double) {
        print("Your new location: \(self.current_gps)")
        
        if(!authorization.isEmpty) {
            //send to server
            let url = URL(string: "\(syncapi)?Authorization=\(self.authorization)&lat=\(lat)&lng=\(lng)")!
            
            //print ("Attempting \(url)")
            
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                
                self.busy=false;
                
                guard let data = data else { return }
                
                let rdata=String(data: data, encoding: .utf8)!
                
                if(rdata.contains("updated")) {
                    self.last_lat=lat;
                    self.last_lng=lng;
                    //print ("Successful call")
                } else {
                    print ("Unable to update location")
                }
                //print("The response is : ",String(data: data, encoding: .utf8)!)
                //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue) as Any)
            }
            task.resume()
        }
        
        
        
        let gps = self.current_gps
        wkWebView.evaluateJavaScript("gps_location('\(gps)');", completionHandler: nil)
    }
    
    func processImage(image: UIImage) {
        //NSLog("Got za image")
        
        let photo: String  = self.convertImageToBase64String(image: image)
        //print(imageData,"imageString")
        
        wkWebView.evaluateJavaScript("applet.acceptPhoto('\(photo)');", completionHandler: nil)
    }
    
    public func  convertImageToBase64String(image : UIImage ) -> String
    {
        let imageData = image.jpegData(compressionQuality: 0.4)
        let base64data = imageData?.base64EncodedString()
        
        return base64data!
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    // do stuff
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- WKNavigationDelegate
    
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let title = NSLocalizedString("OK", comment: "OK Button")
        let ok = UIAlertAction(title: title, style: .default) { (action: UIAlertAction) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
        present(alert, animated: true)
        completionHandler()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish to load")
    }
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Start to load")
    }
    
    
    func send(msg: String) {
        // create the alert
        let alert = UIAlertController(title: "Message", message: msg, preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func dial_phone(num: String) {
        num.makeACall()
        //print("Dial this number: "+num)
    }
    
    func trackgps() {
        print("Tracking GPS")
        let gps = "6.3,5.0"
        
        wkWebView.evaluateJavaScript("gps_location('\(gps)');", completionHandler: nil)
        
    }
    
}



extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if message.name == "bridge" {
            let strCommand    = message.body as! String
            let commands = strCommand.components(separatedBy: ":")
            
            let cmd    = commands[0]
            let param = commands.indices.contains(1) ? commands[1] : ""
            
            switch cmd {
            case "send":
                send(msg:param)
                break;
            case "authorize":
                //store the authorization for restful api
                authorization=param
                break;
            case "dial":
                dial_phone(num: param)
                break;
            case "trackgps":
                trackgps()
                break;
            case "getPhoto":
                let picker = PickerController()
                
                picker.selectImage(self){ image in
                    DispatchQueue.main.async {
                        self.processImage(image: image)
                    }
                }
                break;
                
            case "getCamera":
                let picker = PickerController()
                
                picker.selectCamera(self){ image in
                    DispatchQueue.main.async {
                        self.processImage(image: image)
                    }
                }
                
                break;
            case "startNotification":
                if let filePath = Bundle.main.url(forResource: "sound.mp3", withExtension: nil) {
                    //print("found my file")
                } else {
                    print("file is missing")
                }
                
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                
                Sound.stopAll();
                Sound.play(file:"sound.mp3");
                
                break;
            case "stopNotification":
                Sound.stopAll();
                break;
                
            default:
                print ("No handler for: "+cmd)
                break
            }
        }
        
        /*
         switch message.name {
         case "dial":
         let phone = message.body as! String
         print("Dial: "+phone);
         break;
         
         case "mySwiftMessage":
         if let callbackName = message.body as? String {
         message.webView?.evaluateJavaScript("\(callbackName)('Hello From Swift');", completionHandler: nil)
         }
         default:
         break
         }
         */
    }
}
