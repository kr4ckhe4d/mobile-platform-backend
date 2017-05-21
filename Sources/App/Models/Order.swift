//
//  Order.swift
//  Hello
//
//  Created by Dihara Wijetunga on 5/21/17.
//
//

import Vapor
import Fluent

final class Order: Model {
    
    var id:Node?
    var amount: Int
    var date: String
    var status: Int
    var store_id: Node?
    var user_id: Node?
    
    init(amount: Int,
         date: String,
         status: Int) {
        self.amount = amount
        self.date   = date
        self.status = status
    }
    
    init(node: Node, in context: Context) throws {
        self.id             = try node.extract("id")
        self.amount         = try node.extract("amount")
        self.date           = try node.extract("date")
        self.status         = try node.extract("status")
        self.store_id       = try node.extract("store_id")
        self.user_id        = try node.extract("user_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id"           : id,
            "amount"       : amount,
            "date"         : date,
            "status"       : status,
            "store_id"     : store_id,
            "user_id"      : user_id
            ])
    }
    
    static func seed() throws {
        let products = try Product.all()
        
        if let user = try User.all().first, let store = try Store.all().first {
            for index in 1...5 {
                var order = Order(amount: 23423 * index, date: "04/12/2017", status: 0)
                order.store_id = store.id!
                order.user_id = user.id!
                try order.save()
                
                for itemIndex in 1...5 {
                    var item = OrderItem(qty: itemIndex)
                    item.order_id = order.id!
                    item.product_id = products[itemIndex].id!
                    
                    try item.save()
                }
            }
        }
    }
    
    static func findByUser(user: User) throws -> Query<Order> {
        return try query().filter("user_id", user.id!)
    }
}

extension Order: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create("orders") { deal in
            deal.id()
            deal.int("amount")
            deal.string("date")
            deal.int("status")
            deal.parent(Store.self, optional: false)
            deal.parent(User.self, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("orders")
    }
    
    func store() throws -> Parent<Store> {
        return try parent(store_id)
    }
    
    func user() throws -> Parent<User> {
        return try parent(user_id)
    }
}

