//
//  OrderItem.swift
//  Hello
//
//  Created by Dihara Wijetunga on 5/21/17.
//
//

import Vapor
import Fluent

final class OrderItem: Model {
    
    var id:Node?
    var qty: Int
    var order_id: Node?
    var product_id: Node?
    
    init(qty: Int) {
        self.qty = qty
    }
    
    init(node: Node, in context: Context) throws {
        self.id             = try node.extract("id")
        self.qty            = try node.extract("qty")
        self.order_id       = try node.extract("order_id")
        self.product_id     = try node.extract("product_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id"           : id,
            "qty"          : qty,
            "order_id"     : order_id,
            "product_id"   : product_id
            ])
    }
    
    static func seed() throws {
    }
    
    static func findByOrder(order: Order) throws -> Query<OrderItem> {
        return try query().filter("order_id", order.id!)
    }
}

extension OrderItem: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create("orderitems") { deal in
            deal.id()
            deal.int("qty")
            deal.parent(Order.self, optional: false)
            deal.parent(Product.self, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("orderitems")
    }
    
    func order() throws -> Parent<Store> {
        return try parent(order_id)
    }
    
    func product() throws -> Parent<Product> {
        return try parent(product_id)
    }
}

