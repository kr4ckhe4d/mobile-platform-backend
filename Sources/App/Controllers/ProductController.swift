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
import Fluent

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
        
        if let tagString = request.data["tag"]?.string {
            let tags = tagString.components(separatedBy: "-")
            var results: [Product] = []
            
            for tag in tags {
                let queryResults = try Product.findByTag(tag: tag).run()
                
                for queryResult in queryResults {
                    
                    var shouldAdd: Bool = true
                    
                    // Iterate over the results to check if this product has been retrieved already.
                    for result in results {
                        if result.id == queryResult.id {
                            shouldAdd = false
                        }
                    }
                    
                    if shouldAdd == true {
                        results.append(queryResult)
                    }
                }
            }
            
            return try results.makeJSON()
        }
        
        return try Response(status: .badRequest, json: JSON(["error" : "No Keyword!"]))
    }
}
