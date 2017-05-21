//
//  ProductController.swift
//  Hello
//
//  Created by Dihara Wijetunga on 5/21/17.
//
//

import Vapor
import Routing
import HTTP

final class ProductController {
    
    func search(_ request: Request) throws -> ResponseRepresentable  {
        guard let token = request.headers["access_token"]?.string else {
            return try Response(status: .unauthorized, json: JSON(["error" : "Unauthorized"]))
        }
        
        let user = try User.findByToken(token: token)
        
        if user == nil {
            return try Response(status: .unauthorized, json: JSON(["error" : "Unauthorized"]))
        }
        
        if let keyword = request.data["keyword"]?.string {
            let nameResults = try Product.findByNameKeyword(keyword: keyword).run()
            let descResults = try Product.findByDescKeyword(keyword: keyword).run()
            let combined = nameResults + descResults
            return try combined.makeJSON()
        }
        
        if let keyword = request.data["tag"]?.string {
            
        }
        
        return try Response(status: .badRequest, json: JSON(["error" : "No Keyword!"]))
    }
}
