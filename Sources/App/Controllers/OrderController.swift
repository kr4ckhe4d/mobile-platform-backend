//
//  OrderController.swift
//  Hello
//
//  Created by Dihara Wijetunga on 5/21/17.
//
//

import Vapor
import Routing
import HTTP

final class OrderController {
    
    func orders(_ request: Request) throws -> ResponseRepresentable  {
        guard let token = request.headers["access_token"]?.string else {
            return try Response(status: .unauthorized, json: JSON(["error" : "Unauthorized"]))
        }
        
        let user = try User.findByToken(token: token)
        
        if user == nil {
            return try Response(status: .unauthorized, json: JSON(["error" : "Unauthorized"]))
        }
        
        let orders = try Order.findByUser(user: user!).run()
        var orderArray: [JSON] = []
        
        for order in orders {
            var itemArray: [JSON] = []
            
            let items = try OrderItem.findByOrder(order: order).run()
            
            for item in items {
                if let product = try Product.find(item.product_id!) {
                    itemArray.append(JSON(["qty" : Node(item.qty),
                                           "product" : try product.makeNode()]))
                }
            }
            
            orderArray.append(JSON(["order_id"     : order.id!,
                                    "date"         : Node.init(order.date),
                                    "total_amount" : Node(order.amount),
                                    "items"        : try itemArray.makeNode() ]))
        }
        
        return try orderArray.makeJSON()
    }
    
    func order(_ request: Request) throws -> ResponseRepresentable  {
        guard let token = request.headers["access_token"]?.string else {
            return try Response(status: .unauthorized, json: JSON(["error" : "Unauthorized"]))
        }
        
        let user = try User.findByToken(token: token)
        
        if user == nil {
            return try Response(status: .unauthorized, json: JSON(["error" : "Unauthorized"]))
        }
        
        if let orderId = request.parameters["order_id"]?.int {
            if let order = try Order.find(orderId) {
                var itemArray: [JSON] = []
                
                let items = try OrderItem.findByOrder(order: order).run()
                
                for item in items {
                    if let product = try Product.find(item.product_id!) {
                        itemArray.append(JSON(["qty" : Node(item.qty),
                                               "product" : try product.makeNode()]))
                    }
                }
                
                return JSON(["order_id"     : order.id!,
                             "date"         : Node.init(order.date),
                             "total_amount" : Node(order.amount),
                             "items"        : try itemArray.makeNode() ])
            }
        }
        
        throw Abort.badRequest
    }
    
    func checkout(_ request: Request) throws -> ResponseRepresentable  {
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
