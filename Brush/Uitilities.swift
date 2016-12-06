//
//  Uitilities.swift
//  Brush
//
//  Created by Ken Siu on 6/12/2016.
//  Copyright © 2016 Ken Siu. All rights reserved.
//

import UIKit
import Photos

class Utilities {
    static let sharedInstance = Utilities()
    
    private init() {
        
    }
    
    func popAlertView(parentVC: UIViewController, title: String?, message: String?) {
        let alertCont = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let oKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertCont.addAction(oKAction)
        
        parentVC.present(alertCont, animated: true, completion: nil)
    }
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .restricted, .denied:
            break
        case .notDetermined:
            break            
        }
    }
}
