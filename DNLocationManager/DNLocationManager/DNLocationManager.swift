//
//  DNLocationManager.swift
//  DNLocationManager
//
//  Created by mainone on 2018/4/4.
//  Copyright © 2018年 mainone. All rights reserved.
//

import UIKit
import CoreLocation

public class DNLocationModel: NSObject {
    // 纬度
    var latitude: CLLocationDegrees = 0.0
    // 经度
    var longitude: CLLocationDegrees = 0.0
    // 详细信息
    var placemark: CLPlacemark? = nil
    
    override init() {
        super.init()
    }
    
    func setModel(_ latitude: CLLocationDegrees ,_ longitude: CLLocationDegrees, _ placemark: CLPlacemark) {
        self.latitude = latitude
        self.longitude = longitude
        self.placemark = placemark
    }
}

public typealias locationInfo = ((_ error: NSError?, _ locationModel: DNLocationModel?) -> Void)

private let locationManagerShareInstance = DNLocationManager()

class DNLocationManager: NSObject, CLLocationManagerDelegate {
    // 创建一个单例
    open class var shared: DNLocationManager {
        return locationManagerShareInstance
    }
    
    // 定义闭包变量
    private var onLocationInfo: locationInfo?
    
    open func getLocationInfo(locationInfo: @escaping locationInfo) {
        startLocation()
        onLocationInfo = locationInfo
    }
    
    // 创建一个CLLocationManager对象
    private var locationManager: CLLocationManager!
    // 创建一个CLGeocoder对象
    private var geocoder: CLGeocoder!
    
    override init() {
        super.init()
        // 初始化locationManager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //定位精准度
        locationManager.distanceFilter = 100 // 超出范围更新位置信息
        locationManager.requestWhenInUseAuthorization() // 使用期间
        // 初始化geocoder
        geocoder = CLGeocoder()
    }
    
    // 定位功能开启
    private func startLocation() {
        locationManager.startUpdatingLocation()
    }
    // 结束定位
    private func stopLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("每当请求到位置信息时都会调用此方法")
        if let location = locations.first { // 坐标
            let locationModel = DNLocationModel()
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                let placemark = placemarks?.first
                locationModel.placemark = placemark
                locationModel.latitude = (placemark?.location?.coordinate.latitude)!
                locationModel.longitude = (placemark?.location?.coordinate.longitude)!
                if self.onLocationInfo != nil {
                    self.onLocationInfo!(error as NSError?, locationModel)
                }
            }
        }
        // 不需要定位的时候停止定位
        stopLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("定位失败: %@", error)
        if self.onLocationInfo != nil {
            self.onLocationInfo!(error as NSError?, nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("用户未决定")
        case .restricted: // 暂时没啥用
            print("访问受限")
        case .denied: // /定位关闭时和对此APP授权为never时调用
            if CLLocationManager.locationServicesEnabled() {
                print("定位开启,但被拒绝")
                if let settingUrl = URL(string: UIApplicationOpenSettingsURLString) {
                    if UIApplication.shared.canOpenURL(settingUrl) && Double(UIDevice.current.systemVersion)! >= 8.0 {
                        //iOS8可直接跳转到设置界面
                        let alertVC = UIAlertController(title: "提示", message: "定位功能被拒绝，是否前往设置开启", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
                        })
                        let okAction = UIAlertAction(title: "确定", style: .default, handler: { (action) in
                            UIApplication.shared.openURL(settingUrl)
                        })
                        alertVC.addAction(cancelAction)
                        alertVC.addAction(okAction)
                        let vc = UIApplication.shared.keyWindow?.rootViewController
                        vc?.present(alertVC, animated: true, completion: nil)
                    }
                } else {
                    let alertVC = UIAlertController(title: "提示", message: "定位功能被拒绝，请在设置中开启", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: { (action) in
                    })
                    alertVC.addAction(cancelAction)
                    let vc = UIApplication.shared.keyWindow?.rootViewController
                    vc?.present(alertVC, animated: true, completion: nil)
                }
                
            } else {
                print("定位关闭,不可用")
                if let settingUrl = URL(string: UIApplicationOpenSettingsURLString) {
                    if UIApplication.shared.canOpenURL(settingUrl) && Double(UIDevice.current.systemVersion)! >= 8.0 {
                        //iOS8可直接跳转到设置界面
                        let alertVC = UIAlertController(title: "提示", message: "定位功能被拒绝，是否前往设置开启", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
                        })
                        let okAction = UIAlertAction(title: "确定", style: .default, handler: { (action) in
                            UIApplication.shared.openURL(settingUrl)
                        })
                        alertVC.addAction(cancelAction)
                        alertVC.addAction(okAction)
                        let vc = UIApplication.shared.keyWindow?.rootViewController
                        vc?.present(alertVC, animated: true, completion: nil)
                        
                    } else {
                        let alertVC = UIAlertController(title: "提示", message: "定位服务未开启\n打开方式:设置->隐私->定位服务", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: { (action) in
                        })
                        alertVC.addAction(cancelAction)
                        let vc = UIApplication.shared.keyWindow?.rootViewController
                        vc?.present(alertVC, animated: true, completion: nil)
                    }
                    
                }
            }
            
        case .authorizedAlways:
            print("获取前后台定位授权")
        case .authorizedWhenInUse:
            print("获取前台定位授权")
        }
    }
}

