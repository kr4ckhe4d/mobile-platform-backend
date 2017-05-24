//
//  UserController.swift
//  Hello
//
//  Created by Dihara Wijetunga on 5/21/17.
//
//

import Vapor
import Routing
import HTTP
import Foundation

final class UserController {
    
    func login(_ request: Request) throws -> ResponseRepresentable  {
        print(request)
        if let bodyBytes = request.body.bytes {
            
            let string = String(bytes: bodyBytes, encoding: String.Encoding.utf8)
            
            if let data = string!.data(using: .utf8) {
                do {
                    let jsonString = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                    print(jsonString.allItems[1].1)
                    
                    let email = jsonString.allItems[1].1
                        let password = jsonString.allItems[0].1
                        var user = try User.findByCredentials(email: email as! String, password: password as! String)
                        
                        if user != nil {
                            
                            let date = Date()
                            
                            let hash = try drop.hash.make((user?.email)! + (user?.password)! + String.init(date.timeIntervalSince1970.doubleValue))
                            if let token = hash.string {
                                user?.access_token = token
                                try user?.save()
                                return JSON(["access_token" : Node.init(token)])
                            }
                        }
                }
            }
        }
        

        return try Response(status: .unauthorized, json: JSON(["error" : "Unauthorized"]))
    }
    
    func logintest(_ request: Request) throws -> ResponseRepresentable{
        print(request.formData)
        return JSON(["foo" : "bar"])
    }
    func signup(_ request: Request) throws -> ResponseRepresentable  {
        print(request)
        if let bodyBytes = request.body.bytes {
            
            let string = String(bytes: bodyBytes, encoding: String.Encoding.utf8)
            
            if let data = string!.data(using: .utf8) {
                do {
                    let jsonString = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                    print(jsonString.allItems[1].1)
                    
//                    let email = jsonString.allItems[1].1
//                    let password = jsonString.allItems[0].1

                    let email = jsonString.allItems[2].1
                                  let password = jsonString.allItems[4].1
                                  let fname = jsonString.allItems[0].1
                                  let lname = jsonString.allItems[1].1
                                  let dob = jsonString.allItems[3].1
                                  let street_address = jsonString.allItems[5].1
                                  let country = jsonString.allItems[6].1
                                  let city = jsonString.allItems[7].1
                                  let postal = jsonString.allItems[8].1
                                  let contact_no = jsonString.allItems[9].1
                    
                    let existing = try User.findByCredentials(email: email as! String, password: password as! String)
                    
                            if existing != nil {
                                return try Response(status: .badRequest, json: JSON(["error" : "User Already Exists"]))
                            }
                    
                            var user = User(fname: fname as! String,
                                            lname: lname as! String,
                                            email: email as! String,
                                            password: password as! String,
                                            dob: dob as! String,
                                            street_address: street_address as! String,
                                            country: country as! String,
                                            city: city as! String,
                                            postal: 5,
                                            contact_no: 0775866536)
                            
                            try user.save()
                }
            }
        }

//        guard let email = request.formData?["email"]?.string,
//              let password = request.formData?["password"]?.string,
//              let fname = request.formData?["fname"]?.string,
//              let lname = request.formData?["lname"]?.string,
//              let dob = request.formData?["dob"]?.string,
//              let street_address = request.formData?["street_address"]?.string,
//              let country = request.formData?["country"]?.string,
//              let city = request.formData?["city"]?.string,
//              let postal = request.formData?["postal"]?.int,
//              let contact_no = request.formData?["contact_no"]?.int else {
//                throw Abort.badRequest
//        }
//        
//        let existing = try User.findByCredentials(email: email, password: password)
//        
//        if existing != nil {
//            return try Response(status: .badRequest, json: JSON(["error" : "User Already Exists"]))
//        }
//        
//        var user = User(fname: fname,
//                        lname: lname,
//                        email: email,
//                        password: password,
//                        dob: dob,
//                        street_address: street_address,
//                        country: country,
//                        city: city,
//                        postal: postal,
//                        contact_no: contact_no)
//        
//        try user.save()
        
        return try Response(status: .ok, json: JSON(["message" : "Successfully Registered!"]))
    }
    
    func profile(_ request: Request) throws -> ResponseRepresentable  {
        guard let token = request.headers["access_token"]?.string else {
            return try Response(status: .unauthorized, json: JSON(["error" : "Unauthorized"]))
        }
        
        let user = try User.findByToken(token: token)
        
        if user == nil {
            return try Response(status: .unauthorized, json: JSON(["error" : "Unauthorized"]))
        }
        
        return try user!.makeJSON()
    }
}
