import Vapor
import Fluent

final class Deal: Model {
    
    var id:Node?
    var start_date: String
    var end_date: String
    var discount: Int
    var store_id: Node?
    var product_id: Node?
    
    init(start_date: String,
         end_date: String,
         discount: Int) {
        self.start_date   = start_date
        self.end_date     = end_date
        self.discount     = discount
    }
    
    init(node: Node, in context: Context) throws {
        self.id             = try node.extract("id")
        self.start_date     = try node.extract("start_date")
        self.end_date       = try node.extract("end_date")
        self.discount       = try node.extract("discount")
        self.store_id       = try node.extract("store_id")
        self.product_id     = try node.extract("product_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id"           : id,
            "start_date"   : start_date,
            "end_date"     : end_date,
            "discount"     : discount,
            "store_id"     : store_id,
            "product_id"   : product_id
            ])
    }
    
    static func seed() throws {
        let stores = try Store.all()
        
        for store in stores {
            if let product = try Product.findByStore(store: store).first() {
                var deal = Deal(start_date: "01/01/2017", end_date: "01/20/2017", discount: 50)
                deal.store_id = store.id
                deal.product_id = product.id
                
                try deal.save()
            }
        }
    }
    
    static func findByStore(store: Store) throws -> Query<Deal> {
        return try query().filter("store_id", store.id!)
    }
}

extension Deal: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create("deals") { deal in
            deal.id()
            deal.string("start_date")
            deal.string("end_date")
            deal.int("discount")
            deal.parent(Store.self, optional: false)
            deal.parent(Product.self, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("deals")
    }
    
    func store() throws -> Parent<Store> {
        return try parent(store_id)
    }
    
    func product() throws -> Parent<Product> {
        return try parent(product_id)
    }
}
