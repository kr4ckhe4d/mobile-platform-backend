//
//  StoreController.swift
//  Hello
//
//  Created by Dihara Wijetunga on 5/21/17.
//
//

import Vapor
import Routing
import HTTP

final class StoreController {
    
    func stores(_ request: Request) throws -> ResponseRepresentable  {
        print(request)
        guard let token = request.headers["access_token"]?.string else {
            return try Response(status: .unauthorized, json: JSON(["error" : "Unauthorized"]))
        }
        
        let user = try User.findByToken(token: token)
        
        if user == nil {
            return try Response(status: .unauthorized, json: JSON(["error" : "Unauthorized"]))
        }
        
        return try Store.all().makeJSON()
    }
    
    func store(_ request: Request) throws -> ResponseRepresentable  {
        guard let token = request.headers["access_token"]?.string else {
            return try Response(status: .unauthorized, json: JSON(["error" : "Unauthorized"]))
        }
        
        let user = try User.findByToken(token: token)
        
        if user == nil {
            return try Response(status: .unauthorized, json: JSON(["error" : "Unauthorized"]))
        }
        
        if let storeId = request.parameters["store_id"]?.int {
            if let store = try Store.find(storeId) {
                return try store.makeJSON()
            }
        }
        
        throw Abort.badRequest
    }
    
    func products(_ request: Request) throws -> ResponseRepresentable  {
        guard let token = request.headers["access_token"]?.string else {
            return try Response(status: .unauthorized, json: JSON(["error" : "Unauthorized"]))
        }
        
        let user = try User.findByToken(token: token)
        
        if user == nil {
            return try Response(status: .unauthorized, json: JSON(["error" : "Unauthorized"]))
        }
        
        if let storeId = request.parameters["store_id"]?.int {
            let store = try Store.find(storeId)
            if let products = try store?.products().all() {
                return try products.makeJSON()
            }
        }
        
        throw Abort.badRequest
    }
    
    func deals(_ request: Request) throws -> ResponseRepresentable  {
        guard let token = request.headers["access_token"]?.string else {
            return try Response(status: .unauthorized, json: JSON(["error" : "Unauthorized"]))
        }
        
        let user = try User.findByToken(token: token)
        
        if user == nil {
            return try Response(status: .unauthorized, json: JSON(["error" : "Unauthorized"]))
        }
        
        if let storeId = request.parameters["store_id"]?.int {
            if let store = try Store.find(storeId) {
                let deals = try Deal.findByStore(store: store).run()
                var jsonArray: [JSON] = []
                
                for deal in deals {
                    if let product = try Product.find(deal.product_id!),
                        let store = try Store.find(deal.store_id!) {
                        jsonArray.append(JSON(["deal_id" : deal.id!,
                                               "discount" : Node.init(deal.discount),
                                               "start_date" : Node.init(deal.start_date),
                                               "end_date" : Node.init(deal.end_date),
                                               "store" : try store.makeNode(),
                                               "product" : try product.makeNode()
                            ]))
                    }
                }
                
                return try jsonArray.makeJSON()
            }
        }
        
        return try Response(status: .badRequest, json: JSON(["error" : "Something went wrong."]))
    }
}
