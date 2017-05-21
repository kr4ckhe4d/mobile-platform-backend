import Vapor
import Fluent

final class Product: Model {
    
    var id:Node?
    var name: String
    var desc: String
    var price: Int
    var img_path: String
    var stock: Int
    var store_id: Node?
    
    init(name: String,
         desc: String,
         price: Int,
         img_path: String,
         stock: Int) {
        self.name           = name
        self.desc           = desc
        self.price          = price
        self.img_path       = img_path
        self.stock          = stock
    }
    
    init(node: Node, in context: Context) throws {
        self.id             = try node.extract("id")
        self.name           = try node.extract("name")
        self.desc           = try node.extract("desc")
        self.price          = try node.extract("price")
        self.img_path       = try node.extract("img_path")
        self.stock          = try node.extract("stock")
        self.store_id       = try node.extract("store_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id"           : id,
            "name"         : name,
            "desc"         : desc,
            "price"        : price,
            "img_path"     : img_path,
            "stock"        : stock,
            "store_id"     : store_id
            ])
    }
    
    static func seed() throws {
        let stores = try Store.all()
        
        for store in stores {
            
            for index in 1...10 {
                let name = "Product" + String.init(index)
                let desc = "blah blah blah"
                let price = 123 * index
                let img = "assdasads.png"
                let stock = 123
                
                var product = Product(name: name, desc: desc, price: price, img_path: img, stock: stock)
                product.store_id = store.id
                try product.save()
            }
            
        }
    }
    
    static func findByStore(store: Store) throws -> Query<Product> {
        return try query().filter("store_id", store.id!)
    }
    
    static func findByNameKeyword(keyword: String) throws -> Query<Product> {
        return try query().filter("name", .contains, keyword)
    }
    
    static func findByDescKeyword(keyword: String) throws -> Query<Product> {
        return try query().filter("desc", .contains, keyword)
    }
}

extension Product: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create("products") { products in
            products.id()
            products.string("name")
            products.string("desc")
            products.int("price")
            products.string("img_path")
            products.int("stock")
            products.parent(Store.self, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("products")
    }
    
    func store() throws -> Parent<Store> {
        return try parent(store_id)
    }
}
