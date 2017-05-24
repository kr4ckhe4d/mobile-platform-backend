import Vapor
import VaporSQLite
import Routing

let drop = Droplet()

drop.middleware.append(try CORSMiddleware(configuration: drop.config))

try drop.addProvider(VaporSQLite.Provider.self)

drop.preparations.append(User.self)
drop.preparations.append(Store.self)
drop.preparations.append(Product.self)
drop.preparations.append(Deal.self)
drop.preparations.append(Order.self)
drop.preparations.append(OrderItem.self)

let userController = UserController()
let storeController = StoreController()
let dealController = DealController()
let productController = ProductController()
let orderController = OrderController()

drop.group("api") { api in
    api.group("v1") { v1 in
        
        v1.post("login", handler: userController.login)
        
        v1.post("signup", handler: userController.signup)
        
        v1.get("profile", handler: userController.profile)
        
        v1.get("stores", handler: storeController.stores)
        
        v1.get("stores", ":store_id", handler: storeController.store)
        
        v1.get("stores", ":store_id", "products", handler: storeController.products)
        
        v1.get("stores", ":store_id", "deals", handler: storeController.deals)
        
        v1.get("deals", handler: dealController.deals)
        
        v1.get("search", handler: productController.search)
        
        v1.get("orders", handler: orderController.orders)
        
        v1.get("orders", ":order_id" , handler: orderController.order)
        
        v1.post("orders", "checkout", handler: orderController.checkout)
        
        v1.get("seed") { request in
            try User.seed()
            try Store.seed()
            try Product.seed()
            try Deal.seed()
            //try Order.seed()
            
            return JSON(["status" : true])
        }
    }
}

drop.run()
