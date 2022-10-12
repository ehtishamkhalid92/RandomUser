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
    
    
    //MARK: Functions
    
    /// This function is used to store the Api Data into Local database
    /// single entity Save into Coredata.
    func saveDataInLocalStorage(instance: Result) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
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
        let context = ( UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext
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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
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
