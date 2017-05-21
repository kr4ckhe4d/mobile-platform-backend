import Vapor
import Fluent

final class User: Model {
    
    var id:Node?
    var fname: String
    var lname: String
    var email: String
    var password: String
    var dob: String
    var street_address: String
    var country: String
    var city: String
    var postal: Int
    var contact_no: Int
    var access_token: String
    
    init(fname: String,
         lname: String,
         email: String,
         password: String,
         dob: String,
         street_address: String,
         country: String,
         city: String,
         postal: Int,
         contact_no: Int) {
        self.fname          = fname
        self.lname          = lname
        self.email          = email
        self.password       = password
        self.dob            = dob
        self.street_address = street_address
        self.country        = country
        self.city           = city
        self.postal         = postal
        self.contact_no     = contact_no
        self.access_token   = ""
    }
    
    init(node: Node, in context: Context) throws {
        self.id             = try node.extract("id")
        self.fname          = try node.extract("fname")
        self.lname          = try node.extract("lname")
        self.email          = try node.extract("email")
        self.password       = try node.extract("password")
        self.dob            = try node.extract("dob")
        self.street_address = try node.extract("street_address")
        self.country        = try node.extract("country")
        self.city           = try node.extract("city")
        self.postal         = try node.extract("postal")
        self.contact_no     = try node.extract("contact_no")
        self.access_token   = try node.extract("access_token")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id"             : id,
            "fname"          : fname,
            "lname"          : lname,
            "email"          : email,
            "password"       : password,
            "dob"            : dob,
            "street_address" : street_address,
            "country"        : country,
            "city"           : city,
            "postal"         : postal,
            "contact_no"     : contact_no,
            "access_token"   : access_token
        ])
    }
    
    static func seed() throws {
        var user = User(fname: "Dihara", lname: "Wijetunga", email: "dihara@gmail.com", password: "test", dob: "22/10/1994", street_address: "24, rampart cross road, ethul kotte", country: "Sri lanka", city: "Colombo", postal: 10100, contact_no: 0718695696)
        
        try user.save()
    }
    
    static func findByCredentials(email: String, password: String) throws -> User? {
        return try query().filter("email", email).filter("password", password).first()
    }
    
    static func findByToken(token: String) throws -> User? {
        return try query().filter("access_token", token).first()
    }
}

extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("users") { cars in
            cars.id()
            cars.string("fname")
            cars.string("lname")
            cars.string("email")
            cars.string("password")
            cars.string("dob")
            cars.string("street_address")
            cars.string("country")
            cars.string("city")
            cars.int("postal")
            cars.int("contact_no")
            cars.string("access_token")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("users")
    }
    
    func orders() throws -> Children<Order> {
        return try children()
    }

}
