//
//  PLTravelStoryListHandler.swift
//  PerfectTurnstilePostgreSQLDemoPackageDescription
//
//  Created by Glasses on 06/12/2017.
//

import PerfectHTTP
import PerfectPostgreSQL

class PLTravelStoryListHandler: PLBaseServiceHandler {
    override open class func defaultHandler(request: HTTPRequest, _ response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        
        var resp = [String: String]()
        
        let p = PGConnection()
        let status = p.connectdb("host=localhost dbname=glasses")
        
        let res = p.exec(statement: "INSERT INTO ")
        let num = res.numTuples()
        for x in 0..<num {
            let c1 = res.getFieldString(tupleIndex: x, fieldIndex: 0)
            let c2 = res.getFieldInt(tupleIndex: x, fieldIndex: 1)
            let c3 = res.getFieldInt(tupleIndex: x, fieldIndex: 2)
            let c4 = res.getFieldBool(tupleIndex: x, fieldIndex: 3)
            print("c1=\(c1) c2=\(c2) c3=\(c3) c4=\(c4)")
        }
        p.close()
        
        
        do {
            try response.setBody(json: resp)
        } catch {
            print(error)
        }
        response.completed()
    }
}
