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
import Foundation

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
        
        if let items = request.json!["items"]?.array {
            
            var qtyArray: [Int] = []
            var productArray: [Product] = []
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            
            var amount = 0
            let status = 0 // not shipped
            let date = formatter.string(from: Date())
            
            for item in items {
                if let jsonItem = item as? JSON {
                    if let pid = jsonItem["product_id"]?.string, let qty = jsonItem["qty"]?.int {
                        if let product = try Product.find(pid) {
                            amount = amount + product.price * qty
                            
                            qtyArray.append(qty)
                            productArray.append(product)
                        }
                    }
                }
            }
            
            var order = Order(amount: amount, date: date, status: status)
            order.user_id = user?.id!
            try order.save()
            
            for index in 0...(qtyArray.count - 1) {
                var item = OrderItem(qty: qtyArray[index])
                item.order_id = order.id!
                item.product_id = productArray[index].id!
                
                try item.save()
            }
            
            return try Response(status: .ok, json: JSON(["message" : "Successfully Checked Out!"]))
        }
        
        throw Abort.badRequest
    }
}
