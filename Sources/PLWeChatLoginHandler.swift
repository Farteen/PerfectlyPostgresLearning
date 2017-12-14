//
//  PLWeChatLoginHandler.swift
//  PerfectTurnstilePostgreSQLDemo
//
//  Created by Glasses on 05/12/2017.
//

import PerfectHTTP
import PerfectPostgreSQL
import Foundation

class PLWeChatLoginHandler: PLBaseServiceHandler {
    override open class func defaultHandler(request: HTTPRequest, _ response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        
        var resp = [String: String]()
        guard let user_wechat_id = request.param(name: "userWeChatID") else {
            resp["errorCode"] = "Parameter Invalid"
            do {
                try response.setBody(json: resp)
            } catch {
                print(error)
            }
            response.completed()
            return
        }
        
        guard let user_wechat_name = request.param(name: "userWeChatName") else {
            resp["errorCode"] = "Parameter Invalid"
            do {
                try response.setBody(json: resp)
            } catch {
                print(error)
            }
            response.completed()
            return
        }
        
        guard let user_phone = request.param(name: "userPhone") else {
            resp["errorCode"] = "Parameter Invalid"
            do {
                try response.setBody(json: resp)
            } catch {
                print(error)
            }
            response.completed()
            return
        }
        
        let p = PGConnection()
        let status = p.connectdb("host=localhost dbname=glasses")
        /// 查询是否有该用户手机号
        let queryResult = p.exec(statement: "SELECT * FROM users WHERE user_wechat_id = ($1)", params: [user_phone])
        
        /**
         wechat_id   | text |           |          |         | extended |              |
         wechat_name | text |           |          |         | extended |              |
         user_phone  | text |           |          |         | extended |              |
         user_id     | text |           | not null |         | extended |              |
         */
        let user_id = UUID().uuidString
        let result = p.exec(statement: "INSERT INTO users (wechat_id, wechat_name, user_phone, user_id) VALUES ($1, $2, $3, $4)", params: [user_wechat_id, user_wechat_name, user_phone, user_id])
        let num = result.numTuples()
        
        p.close()
        do {
            try response.setBody(json: resp)
        } catch {
            print(error)
        }
        response.completed()
    }
}
