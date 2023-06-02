//
//  LDAP.swift
//  All the LDAP connection stuff. Ick. 
//
//  Created by Steve Hayman on 2023-06-02.
//

import Foundation

let searchBase = "ou=people, o=apple"
private var connection: LDAPConnection?
struct LDAP {
    
    
    static func connect(hostname: String) {
        print("LDAP Connection to \(hostname)")
        connection = LDAPConnection()
        print("Got connection")
        
        
        let result = connection?.people(forQuery: "(sn=Hayman)", searchBase: "ou=people, o=apple")
        print("Got result \(result)")
    }
}
