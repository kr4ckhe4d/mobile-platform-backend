//
//  DealController.swift
//  Hello
//
//  Created by Dihara Wijetunga on 5/21/17.
//
//

import Vapor
import Routing
import HTTP

final class DealController {
    
    func deals(_ request: Request) throws -> ResponseRepresentable  {
        guard let token = request.headers["access_token"]?.string else {
            return try Response(status: .unauthorized, json: JSON(["error" : "Unauthorized"]))
        }
        
        let user = try User.findByToken(token: token)
        
        if user == nil {
            return try Response(status: .unauthorized, json: JSON(["error" : "Unauthorized"]))
        }
        
        let deals = try Deal.all()
        var jsonArray: [JSON] = []
            
        for deal in deals {
            if let product = try Product.find(deal.product_id!), let store = try Store.find(deal.store_id!) {
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
