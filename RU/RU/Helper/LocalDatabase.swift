//
//  LocalDatabase.swift
//  RU
//
//  Created by Ehtisham Khalid on 11.10.22.
//

import Foundation
import CoreData
import UIKit

class LocalDatabase {
    
    static let instance = LocalDatabase()
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "RU")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    //MARK: Functions
    
    /// This function is used to store the Api Data into Local database
    /// single entity Save into Coredata.
    func saveDataInLocalStorage(instance: Result) {
        let context = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "LocalUserStorage", in: context)
        let newUser = NSManagedObject(entity: entity!, insertInto: context)
        newUser.setValue(instance.id.value, forKey: "id")
        newUser.setValue(instance.name.first, forKey: "firstName")
        newUser.setValue(instance.name.last, forKey: "lastName")
        newUser.setValue(instance.email, forKey: "email")
        newUser.setValue(instance.picture.thumbnail, forKey: "thumbnail")
        newUser.setValue(instance.picture.large, forKey: "pictureLarge")
        newUser.setValue(instance.phone, forKey: "phone")
        newUser.setValue(instance.dob.age, forKey: "age")
        newUser.setValue(instance.location.street.name, forKey: "streetName")
        newUser.setValue(instance.location.street.number, forKey: "streetNumber")
        newUser.setValue(instance.location.city, forKey: "city")
        newUser.setValue(instance.location.country, forKey: "country")
        newUser.setValue(instance.login.uuid, forKey: "uuid")
        do {
            try context.save()
        } catch(let err) {
            print("Data not save into the localdatabse because of the following Error: \(err.localizedDescription)")
        }
    }
    
    ///Fetch Data from Local Database and show the data into the main class if found.
    func fetchResultFromLocalStorage(completion: @escaping (Swift.Result<Users, Error>) -> Void) {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LocalUserStorage")
        do {
            let result = try context.fetch(fetchRequest)
            var resultArray = [Result]()
            
            for data in result as! [NSManagedObject] {
                let id = data.value(forKey: "id") as? String ?? ""
                let firstName = data.value(forKey: "firstName") as? String ?? ""
                let lastName = data.value(forKey: "lastName") as? String ?? ""
                let name = Name.init(title: "", first: firstName, last: lastName)
                let email = data.value(forKey: "email") as? String ?? ""
                let thumbnail = data.value(forKey: "thumbnail") as? String ?? ""
                let pictureLarge = data.value(forKey: "pictureLarge") as? String ?? ""
                let phone = data.value(forKey: "phone") as? String ?? ""
                let age = data.value(forKey: "age") as? Int ?? -1
                let streetName = data.value(forKey: "streetName") as? String ?? ""
                let streetNumber = data.value(forKey: "streetNumber") as? Int ?? -1
                let street = Street.init(number: streetNumber, name: streetName)
                let city = data.value(forKey: "city") as? String ?? ""
                let country = data.value(forKey: "country") as? String ?? ""
                let uuid = data.value(forKey: "uuid") as? String ?? ""
                let location = Location.init(street: street, city: city, state: "", country: country, postcode: Postcode.string(""), coordinates: Coordinates(latitude: "", longitude: ""), timezone: Timezone.init(offset: "", timezoneDescription: ""))
                let object = Result.init(gender: Gender.male, name: name, location: location, email: email, login: Login(uuid: uuid, username: "", password: "", salt: "", md5: "", sha1: "", sha256: ""), dob: Dob(date: "", age: age), registered: Dob(date: "", age: age), phone: phone, cell: "", id: ID(name: "", value: id), picture: Picture(large: pictureLarge, medium: "", thumbnail: thumbnail), nat: "")
                resultArray.append(object)
            }
            
            let data = Users.init(results: resultArray, info: Info(seed: "", results: 0, page: 0, version: ""))
            completion(.success(data))
        } catch (let err) {
            print("Data not fetched because of the following Error: \(err.localizedDescription)")
            completion(.failure(err))
        }
    }
    
    ///For Deletion of all the records from database
    func resetAllRecords(completion: @escaping (Swift.Result<Bool, Error>) -> Void){
        let context = persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "LocalUserStorage")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do{
            try context.execute(deleteRequest)
            try context.save()
            completion(.success(true))
        }
        catch(let err){
            completion(.failure(err))
            print("Data could not be deleted because of the following Error: \(err.localizedDescription)")
        }
    }
    
    
    ///Delete single object from Local database
    func deleteSingleObject(userId : String, completion: @escaping (Bool) -> Void){
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LocalUserStorage")
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", userId)
        do {
            let result = try context.fetch(fetchRequest)
            if result.count > 0 {
                let objectToDelete = result[0] as! NSManagedObject
                context.delete(objectToDelete)
            }else {
                completion(false)
                print("uuid does not match")
            }
            do {
                try context.save()
                completion(true)
            } catch(let err) {
                print("object could not be deleted because of the following Error: \(err.localizedDescription)")
                completion(false)
            }
        } catch(let err) {
            print("request could not proceed because of the following Error: \(err.localizedDescription)")
            completion(false)
        }
    }
    
    
}
