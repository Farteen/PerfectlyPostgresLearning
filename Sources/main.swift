//
//  main.swift
//  PerfectTurnstileSQLiteDemo
//
//  Created by Jonathan Guthrie on 2016-10-11.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

import StORM
import PostgresStORM
import PerfectTurnstilePostgreSQL
import PerfectRequestLogger
import TurnstilePerfect
import PerfectPostgreSQL

//StORMdebug = true
RequestLogFile.location = "./requests.log"

// Used later in script for the Realm and how the user authenticates.
let pturnstile = TurnstilePerfectRealm()


PostgresConnector.host        = "localhost"
PostgresConnector.username    = "glasses"
PostgresConnector.password    = "Glassesd"
PostgresConnector.database    = "glasses"
PostgresConnector.port        = 5432

//let result = p.exec(
//    statement: "
//    select datname,datdba,encoding,datistemplate
//    from pg_database
//")

// Set up the Authentication table
let auth = AuthAccount()
try? auth.setup()

// Connect the AccessTokenStore
tokenStore = AccessTokenStore()
try? tokenStore?.setup()

//let facebook = Facebook(clientID: "CLIENT_ID", clientSecret: "CLIENT_SECRET")
//let google = Google(clientID: "CLIENT_ID", clientSecret: "CLIENT_SECRET")

// Create HTTP server.
let server = HTTPServer()

// Register routes and handlers
let authWebRoutes = makeWebAuthRoutes()
let authJSONRoutes = makeJSONAuthRoutes("/api/v1")

// Add the routes to the server.
server.addRoutes(authWebRoutes)
server.addRoutes(authJSONRoutes)

// Adding a test route
var routes = Routes()
routes.add(method: .get, uri: "/api/v1/test", handler: AuthHandlersJSON.testHandler)
routes.add(method: .post, uri: "/user/login", handler: PLWeChatLoginHandler.defaultHandler)
routes.add(method: .get, uri: "/travel/storylist", handler: PLTravelStoryListHandler.defaultHandler)
routes.add(method: .get, uri: "/travel/writestory", handler: PLTravelStoryListHandler.defaultHandler)
routes.add(method: .post, uri: "/upload/file", handler: PLFileUploadHandler.defaultHandler)

// Add the routes to the server.
server.addRoutes(routes)


// Setup logging
let myLogger = RequestLogger()

// add routes to be checked for auth
var authenticationConfig = AuthenticationConfig()
//authenticationConfig.include("/api/v1/check")
//authenticationConfig.exclude("/api/v1/login")
//authenticationConfig.exclude("/api/v1/register")

let authFilter = AuthFilter(authenticationConfig)

// Note that order matters when the filters are of the same priority level
server.setRequestFilters([pturnstile.requestFilter])
server.setResponseFilters([pturnstile.responseFilter])

server.setRequestFilters([(authFilter, .high)])

server.setRequestFilters([(myLogger, .high)])
server.setResponseFilters([(myLogger, .low)])

// Set a listen port of 8181
server.serverPort = 8181

// Where to serve static files from
server.documentRoot = "./webroot"

do {
	// Launch the HTTP server.
	try server.start()
} catch PerfectError.networkError(let err, let msg) {
	print("Network error thrown: \(err) \(msg)")
}
