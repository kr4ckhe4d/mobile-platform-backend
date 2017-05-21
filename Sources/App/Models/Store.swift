import Vapor
import Fluent

final class Store: Model {
    
    var id:Node?
    var name: String
    var address: String
    var email: String
    var logo: String
    var contact_no: Int
    var rating: Int
    var review_count: Int
    
    init(name: String,
         address: String,
         email: String,
         logo: String,
         contact_no: Int,
         rating: Int,
         review_count: Int) {
        self.name           = name
        self.address        = address
        self.email          = email
        self.contact_no     = contact_no
        self.rating         = rating
        self.review_count   = review_count
        self.logo           = logo
    }
    
    init(node: Node, in context: Context) throws {
        self.id             = try node.extract("id")
        self.name           = try node.extract("name")
        self.address        = try node.extract("address")
        self.email          = try node.extract("email")
        self.logo           = try node.extract("logo")
        self.contact_no     = try node.extract("contact_no")
        self.rating         = try node.extract("rating")
        self.review_count   = try node.extract("review_count")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id"           : id,
            "name"         : name,
            "address"      : address,
            "email"        : email,
            "logo"         : logo,
            "contact_no"   : contact_no,
            "rating"       : rating,
            "review_count" : review_count
            ])
    }
    
    static func seed() throws {
        
        for index in 1...10 {
            let name = "Store" + String.init(index)
            let email = "store@xyz.com"
            let address = "some address"
            let contact_no = 123456789
            let rating = 8
            let review_count = index * 34
            
            var store = Store.init(name: name,
                              address: address,
                              email: email,
                              logo: "images/stores/redline.png",
                              contact_no: contact_no,
                              rating: rating,
                              review_count: review_count)
            try store.save()
        }
        
    }
}

extension Store: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("stores") { cars in
            cars.id()
            cars.string("name")
            cars.string("address")
            cars.string("email")
            cars.string("logo")
            cars.int("contact_no")
            cars.int("rating")
            cars.int("review_count")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("stores")
    }
    
    func products() throws -> Children<Product> {
        return try children()
    }
    
    func deals() throws -> Children<Deal> {
        return try children()
    }
}
