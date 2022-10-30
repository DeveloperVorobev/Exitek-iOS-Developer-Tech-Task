//
//  Solution.swift
//  Exitek iOS Developer Tech Task
//
//  Created by Владислав Воробьев on 30.10.2022.
//

import Foundation
import CoreData
import UIKit

// MARK: - MobileStorageProtocol

protocol MobileStorageProtocol {
func getAll() -> Set<Mobile>
func findByImei(_ imei: String) -> Mobile?
func save(_ mobile: Mobile) throws -> Mobile
func delete(_ product: Mobile) throws
func exists(_ product: Mobile) -> Bool
}

// MARK: - Mobile Struct

struct Mobile {
let imei: String
let model: String
}

// MARK: - Mobile storage errors + Extension description

enum MobileStorageErrors: Error {
    case productHasAlreadyBeenAdded(product: Mobile)
    case productDoesNotExist(product: Mobile)

}

extension MobileStorageErrors: CustomStringConvertible{
    var description: String{
        switch self {
        case .productHasAlreadyBeenAdded(let product):
            return "Product \(product) has already been added"
        case .productDoesNotExist(let product):
            return "Product \(product) doesn't exist"
        }
    }
}

// MARK: - MobileStorage Class

class MobileStorage: MobileStorageProtocol{
    
    private let contex = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
     var data: Set<Mobile> = []
    
    private func getAllData() {
        let request: NSFetchRequest<MobileData> = MobileData.fetchRequest()
        do{
            let mobileArray = try contex.fetch(request)
            guard mobileArray.count != 0 else { return }
            
            for element in mobileArray {
                data.insert(Mobile(imei: element.imei!, model: element.model!))
            }
            
        } catch {
            print("Error fetchig data: \(error)")
        }
    }
    
    func getAll() -> Set<Mobile> {
       return data
    }
    
    func save(_ mobile: Mobile) throws -> Mobile {
        guard !data.contains(mobile) else {
            throw MobileStorageErrors.productHasAlreadyBeenAdded(product: mobile)
        }
        data.insert(mobile)
        return mobile
    }
    
    func findByImei(_ imei: String) -> Mobile? {
        guard let index = data.firstIndex(of: Mobile(imei: imei, model: "")) else {
            return nil
        }
        return data[index]
    }

    func delete(_ product: Mobile) throws {
        guard data.contains(product) else {
            throw MobileStorageErrors.productDoesNotExist(product: product)
        }
        data.remove(product)
    }
    
    
    func exists(_ product: Mobile) -> Bool {
        return data.contains(product)
    }
    
    init(){
    getAllData()
    }
    
    deinit{
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "MobileData")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
           try contex.execute(deleteRequest)
            try contex.save()
        } catch {
            print(error)
        }
       
        for datum in data {
            let newElement = MobileData(context: contex)
            newElement.imei = datum.imei
            newElement.model = datum.model
            contex.insert(newElement)
            do {
                try contex.save()
            } catch {
                print(error)
            }
        }
    }
}

// MARK: - Equatable, Hashable extension

extension Mobile: Equatable, Hashable{
    static func == (lhs: Mobile, rhs: Mobile) -> Bool {
        return lhs.imei == rhs.imei
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(imei)
    }
}



