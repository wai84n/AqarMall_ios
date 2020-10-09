//
//  AppUtils.swift
//  AqarMall
//
//  Created by Macbookpro on 12/31/18.
//  Copyright © 2018 Macbookpro. All rights reserved.
//

import UIKit
import RSLoadingView
import SwiftKeychainWrapper
import Firebase

enum AdvType : String {
    case rent = "rent"
    case sale = "sale"
    case required = "required"
    case for_exchange = "for_exchange"
    
    var getFavorateSavedName: String? {
        switch self {
        case .rent:
            return "rentFavoriteAdIDs"
        case .sale:
            return "saleFavoriteAdIDs"
        case .required:
            return "requiredFavoriteAdIDs"
        case .for_exchange:
            return "for_exchangeFavoriteAdIDs"
        }
    }
}

enum pointsActionType : Int8 {
    case viewAdv = 1
    case favorate = 2
    case search = 3
    case view_adv_from_notification = 4
    case add_requiredAdv = 5
    
}

class AppUtils: NSObject {
    static var staticProvinces = [Provinces]()
    static var staticAreas = [Areas]()
    static var callInAppMessage: Int = 0
    
    enum AppVariables : String {
        case categories_last_change = "categories_last_change"
        case provinces_last_change = "provinces_last_change"
        case areas_last_change = "areas_last_change"
        case general_pages_last_change = "general_pages_last_change"
        case banner_last_change = "banner_last_change"
        case user_id = "user_id"
        case sponsor = "sponsorData"
        case sponsorLastChange = "sponsorLastChange"
        case sms_attempts = "smsAttempts"
        case contact_us = "ContactUs"
        case device_token_info = "DeviceTokenInfo"
        case device_token_saved_on_server = "DeviceTokenSavedOnServer"
        
        case print_adv_screen_shot = "print_adv_screen_shot"
    }
    
    class func LoadData(key: AppVariables)  -> String
    {
        let userDefaults = UserDefaults.standard
        if((userDefaults.value(forKey: key.rawValue)) != nil)
        {
            let strValue = userDefaults.value(forKey: key.rawValue) as? String
            
            return strValue!
        }
        return ""
    }
    
    class func addCommasToNumber(number: Int)-> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:number)) ?? "\(number)"
    }
    
    class func getAllProvinces()  -> [Provinces]?{
        if staticProvinces.isEmpty {
            if let _provincesData = DB_Provinces.callProvinces(){
                if let _province = Provinces(_entryID: 0, _name: "جميع المحافظات"){
                    staticProvinces.append(_province)
                }
                for obj in _provincesData {
                    if let _province = Provinces(_entryID: obj.entryID, _name: obj.name ?? ""){
                        staticProvinces.append(_province)
                    }
                }
                return staticProvinces
            }
        }else{
            return staticProvinces
        }
        
        return nil
    }
    
//    class func topBarHeight(){
//        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
//            (self.navigationController?.navigationBar.frame.height ?? 0.0)
//    }
    
    class func getProvince(provinceId: Int32)  -> Provinces?
    {
        if let _staticProvinces = getAllProvinces() {
        
            if let foo = _staticProvinces.first(where: {$0.entryID == provinceId}) {
                // do something with foo
                return foo
            } else {
                return nil
            }
        }
        return nil
    }
    
    
    class func getAllAreas()  -> [Areas]?{
        if staticAreas.isEmpty {
            if let _areasData = DB_Areas.callAllAreas(){
                if let _area = Areas(_entryID: 0, _name: "جميع المناطق"){
                    staticAreas.append(_area)
                }
                for obj in _areasData {
                    if let _area = Areas(_entryID: obj.entryID, _name: obj.name ?? ""){
                        staticAreas.append(_area)
                    }
                }
                return staticAreas
            }
        }else{
            return staticAreas
        }
        
        return nil
    }
    
    class func postPointsToServer(actionType: pointsActionType, areaID:Int32, catID:Int32, provinceID:Int32, sectionID:Int8){
        let userInfo = DB_UserInfo.callRecords()
        var userId : Int32 = 0
        if let _userInfo = userInfo {
            userId = _userInfo.entryID
        }
        
        if let user_uuid = KeychainWrapper.standard.string(forKey: "user_uuid"){
            print(user_uuid)
            
            APIs.shared.postPoints(_actionType: actionType.rawValue, _areaID: areaID, _catID: catID, _points: actionType.rawValue, _provinceID: provinceID, _sectionID: sectionID, _userID: userId, _deviceUDID: user_uuid) { (result, error) in
                guard error == nil else {
                    print(error ?? "")
                    return
                }
            }
        }
    }
    
    class func getArea(areaId: Int32)  -> Areas?
    {
        if getAllAreas() != nil {
            
            if let foo = staticAreas.first(where: {$0.entryID == areaId}) {
                // do something with foo
                return foo
            } else {
                return nil
            }
        }
        return nil
    }
    
    class func getUuid()-> String{
        if let user_uuid = KeychainWrapper.standard.string(forKey: "user_uuid"){
            print(user_uuid)
            return user_uuid
        }else{
            let uuid = UIDevice.current.identifierForVendor?.uuidString
            if let _uuid = uuid {
                print("uuid \(_uuid)")
                if KeychainWrapper.standard.set(_uuid, forKey: "user_uuid"){
                    return _uuid
                }
            }
        }
        return ""
    }
    
    class func SaveData(key:AppVariables ,value:String)
    {
        print(key.rawValue)
        UserDefaults.standard.set(value, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    class func SaveDictionary(key:AppVariables ,value:NSDictionary)
    {
        UserDefaults.standard.set(value, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    class func removeData(key:AppVariables)
    {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    class func LoadDictionaryData(key: AppVariables )  -> NSDictionary?
    {
        let userDefaults = UserDefaults.standard
        if((userDefaults.value(forKey: key.rawValue)) != nil)
        {
            let strValue = userDefaults.value(forKey: key.rawValue) as? NSDictionary
            
            return strValue!
        }
        return nil
    }
    
    static var loadingView = RSLoadingView()
    class func ShowLoading(){
        loadingView = RSLoadingView()
        
        loadingView.shouldTapToDismiss = false
        // loadingView.variantKey = "inAndOut"
        loadingView.speedFactor = 1.5
        loadingView.lifeSpanFactor = 1.5
        loadingView.mainColor = UIColor.lightGray
        loadingView.dimBackgroundColor = UIColor.clear
        loadingView.showOnKeyWindow()
    }
    
    class func HideLoading()
    {
        loadingView.hide()
    }
    
    class func markAdAsFavorite(entryID: Int, advType : AdvType) -> Bool {
        print(advType.getFavorateSavedName!)
        guard let name = advType.getFavorateSavedName else{return false}
        
        let IDs = UserDefaults.standard.value(forKey: name) as? String
        var arrayIDs:[String] = []
        if IDs != nil {
            //Convert String to array. Example: "1,2,3,4" to ["1","2","3","4"]
            arrayIDs = IDs!.components(separatedBy: ",")
        }
        
        //Check for array contains value
        if arrayIDs.contains("\(entryID )") {
            // ID found remove... and make it as UnFavorite
            arrayIDs = arrayIDs.filter{$0 != "\(entryID )"}
            //Convert Array to String. Example: ["1","2","3"] to "1,2,3"
            let finalStringIDs = arrayIDs.joined(separator: ",")
            //Save IDs
            UserDefaults.standard.setValue(finalStringIDs, forKey: name)
            return false
        }
        else {
            //Appen new value to array
            arrayIDs.insert("\(entryID)", at: 0)
            //Convert Array to String. Example: ["1","2","3"] to "1,2,3"
            let finalStringIDs = arrayIDs.joined(separator: ",")
            //Save IDs
            UserDefaults.standard.setValue(finalStringIDs, forKey: name)
            
            return true
        }
    }
    
//    class func markAdAsFavorite(ad: AdvertisementInfo) -> Bool {
//        let IDs = UserDefaults.standard.value(forKey: "FavoriteAdIDs") as? String
//        var arrayIDs:[String] = []
//        if IDs != nil {
//            //Convert String to array. Example: "1,2,3,4" to ["1","2","3","4"]
//            arrayIDs = IDs!.components(separatedBy: ",")
//        }
//        //Check for array contains value
//        if arrayIDs.contains("\(ad.entryID ?? 0)") {
//            // ID found remove... and make it as UnFavorite
//            arrayIDs = arrayIDs.filter{$0 != "\(ad.entryID ?? 0)"}
//            //Convert Array to String. Example: ["1","2","3"] to "1,2,3"
//            let finalStringIDs = arrayIDs.joined(separator: ",")
//            //Save IDs
//            UserDefaults.standard.setValue(finalStringIDs, forKey: "FavoriteAdIDs")
//            return false
//        }
//        else {
//            //Appen new value to array
//            arrayIDs.insert("\(ad.entryID ?? 0)", at: 0)
//            //Convert Array to String. Example: ["1","2","3"] to "1,2,3"
//            let finalStringIDs = arrayIDs.joined(separator: ",")
//            //Save IDs
//            UserDefaults.standard.setValue(finalStringIDs, forKey: "FavoriteAdIDs")
//
//            return true
//        }
//    }
    
    class func checkIsFavorite(entryID: Int, advType : AdvType) -> Bool {
        let IDs = UserDefaults.standard.value(forKey: advType.getFavorateSavedName!) as? String
        var arrayIDs:[String] = []
        if IDs != nil {
            //Convert String to array. Example: "1,2,3,4" to ["1","2","3","4"]
            arrayIDs = IDs!.components(separatedBy: ",")
        }
        //Check for array contains value
        if arrayIDs.contains("\(entryID)") {
            // ID found, set this Ad as favorite
            return true
        }
        else {
            // ID not found, set this Ad as UnFavorite
            return false
        }
    }
    
//    class func SendGAIScreenName(screenName : String){
//        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
//        tracker.set(kGAIScreenName, value: screenName)
//        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
//        tracker.send(builder.build() as [NSObject : AnyObject])
//    }
//    
//    class func SendGAIEventTrack(category: String, actionName: String? = "-", _label: String? = "-") {
//        //Google Analytics Event Click name
//        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
//        
//        let eventTracker: NSObject = GAIDictionaryBuilder.createEvent(
//            withCategory: category,
//            action: actionName,
//            label: _label,
//            value: nil).build()
//        tracker.send((eventTracker as! [AnyHashable: Any]))
//    }
    
    class func addEventToFireBase(eventName: String, _parameters: [String : Any]){
        Analytics.logEvent(eventName, parameters: _parameters)
    }

}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
