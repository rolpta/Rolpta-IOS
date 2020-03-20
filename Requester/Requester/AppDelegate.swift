//
//  AppDelegate.swift
//  Ovestt
//
//  Created by Tony on 11/11/2019.
//  Copyright © 2019 Ovestt. All rights reserved.
//

import UIKit
import GCDWebServer

import SwiftLocation
import CoreLocation
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    static let webServer = GCDWebServer()
    
    public var locationManager: CLLocationManager?
    public var current_gps = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //setupLocationManager()
        
        initWebServer();
        
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func initWebServer() {
        
        let mainBundle = Bundle.main
        let folderPath = mainBundle.path(forResource: "web", ofType: nil)
        //print("HTML base folder Path: \(String(describing: folderPath))")
        
        AppDelegate.webServer.addGETHandler(forBasePath: "/", directoryPath: folderPath!, indexFilename: "index.html", cacheAge: 0, allowRangeRequests: true)
        
        AppDelegate.webServer.start(withPort: UInt(MyConfig.port), bonjourName: "GCD Web Server")
        
        //print("Visit \(webServer.serverURL) in your web browser")
    }
    
    
    func setupLocationManager(){
        locationManager = CLLocationManager()
        //locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.distanceFilter = kCLDistanceFilterNone
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.startMonitoringSignificantLocationChanges()
        
        
        if #available(iOS 11.0, *) {
            locationManager?.showsBackgroundLocationIndicator = true
        } else {
            // Fallback on earlier versions
        }
        
        let request = LocationManager.shared.locateFromGPS(.continous, accuracy: .city) { data in
            switch data {
            case .failure(let error):
                print("Location error: \(error)")
            case .success(let location):
                let lat=location.coordinate.latitude
                let lng=location.coordinate.longitude
                self.current_gps = "\(lat),\(lng)"
                
                //self.setLocation()
                
                print("My New Locations: \(self.current_gps)")
            }
        }
        //request.dataFrequency = .fixed(minInterval: 10, minDistance: 0) // minimum 40 seconds & 100 meters since the last update.
    }
    
    // Below method will provide you current location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locationValue)")
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
    
    // Below Mehtod will print error if not able to update location.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location")
    }
    
}

