> 现在的app基本上都有定位功能,又得是获取左边和城市信息,又得是地图展示,这里介绍获取简单的地理位置信息功能,包括坐标,所在城市等基本信息.

## 添加依赖库 导入头文件
```
CoreLocation.framework

import CoreLocation

// 别忘了在plist中添加隐私权限
Privacy - Location Always Usage Description
Privacy - Location When In Use Usage Description
都是String类型 后面描述: 我们需要通过您的地理位置信息获取您周边的相关数据
```

> 为了方便返回数据以后好扩展,采用Model形式返回,后期想继续喜欢返回信息,可直接在model中进行添加 不用修改调用类里面的方法
```
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

```
> 采用单利的形式进行封装

## 初始化相关对象
```
// 初始化locationManager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //定位精准度
        locationManager.distanceFilter = 100 // 超出范围更新位置信息
        locationManager.requestWhenInUseAuthorization() // 使用期间
        // 初始化geocoder
        geocoder = CLGeocoder()
```
## 开始/结束定位
```
// 定位功能开启
    private func startLocation() {
        locationManager.startUpdatingLocation()
    }
    // 结束定位
    private func stopLocation() {
        locationManager.stopUpdatingLocation()
    }
```
## 实现代理并回调定位到的信息
```
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
 
```

## 权限判断 并引导用户去开启
```
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
```
[源码下载](https://github.com/wjncode/DNLocationManager)
