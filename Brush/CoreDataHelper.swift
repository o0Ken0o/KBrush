//
//  CoreDataHelper.swift
//  Brush
//
//  Created by Ken Siu on 5/12/2016.
//  Copyright © 2016 Ken Siu. All rights reserved.
//

import UIKit
import CoreData

class CoreDataHelper {
    static let sharedInstance = CoreDataHelper()
    
    var masterpieces = [Masterpiece]()
    
    private init() {
        
    }
    
    func getAllMasterpieces() -> [Masterpiece] {
        do {
            masterpieces = [Masterpiece]()
            let context = getContext()
            masterpieces = try context.fetch(Masterpiece.fetchRequest())
            
            return masterpieces
        } catch {
            
        }
        
        return [Masterpiece]()
    }
    
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return (appDelegate?.persistentContainer.viewContext)!
    }
    
    func createAMasterpiece(image: UIImage, name: String) -> Masterpiece? {
        let context = getContext()
        let masterpiece = Masterpiece(context: context)
        
        masterpiece.image = NSData(data: UIImagePNGRepresentation(image)!)
        masterpiece.name = name
        
        do {
            try context.save()
            return masterpiece
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
        
        return nil
        
    }
    
    func retrieveAMasterpiece() {
        
    }
    
    func updateAMasterpiece(masterpiece: Masterpiece, newImage: UIImage, newName: String) -> Masterpiece {
        let context = getContext()
        masterpiece.image = NSData(data: UIImagePNGRepresentation(newImage)!)
        masterpiece.name = newName
        
        do {
            try context.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {}
        
        return masterpiece
    }
    
    func deleteAMasterpiece(masterpiece: Masterpiece) {
        let context = getContext()
        context.delete(masterpiece)
        
        do {
            try context.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {}
    }
    
}
