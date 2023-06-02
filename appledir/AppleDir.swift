//
//  main.swift
//  appledir
//  A reimplementation in Swift
//
//  Created by Steve Hayman on 2023-06-02.
//

import Foundation
import ArgumentParser

@main
struct AppleDir: ParsableCommand {
    
    
    @Argument(help: "The people to search")
    var people: [String]
    
    @Option(name:.shortAndLong, help:"Separator between fields - default ' ' ")
    var separator = " "
    
    @Flag(name:.shortAndLong, help: "Go up from each person, recursively")
    var up = false
    
    @Flag(name:.shortAndLong, help: "Go down from each person, recursively")
    var down = false
    
    @Flag(name:.shortAndLong, help: "Display data in a table")
    var table = false
    
    @Flag(name:.shortAndLong, help: "Use indenting to separate levels")
    var indent = false

    @Option(name:.shortAndLong, help:"Specify output fields.  Default \"name,email,telephoneNumber,manager.name")
    var outputFields = "name,email,telephoneNumber,manager.name"
    
    // todo: can this automatically set outputFields?
    @Flag(name:.customShort("S"), help:"Short output format - name,email")
    var shortOutput = false
    
    @Option(name:.shortAndLong, help:"Descend at most N levels.")
    var maxLevels = 0
    
    @Option(name:.shortAndLong, help:"Fetch badge photos as jpg files and write to this path")
    var photoPath: String?
    
    @Flag(name:.customShort("A"), help: "Print all available for each user in the form key: value")
    var allData = false
    
    @Flag(name:.customShort("I"), help: "Include contractors (IC) in the output")
    var includeContractors = false
    
    @Flag(name:.customShort("B"), help: "do NOT trim leading and trailing blanks")
    var blanksTrimmed = true
    
    @Flag(name:.shortAndLong, help:"Verbose output, including LDAP connection debugging")
    var verbose = false
    
    @Flag(name:.shortAndLong, help:"Output in JSON")
    var json = false

    @Flag(name:.customShort("V"), help:"Output in VCard (vcf)")
    var vCard = false

    @Flag(name:.shortAndLong, help:"Output in CSV")
    var csv = false

    @Flag(name:.shortAndLong, help:"Approximate, rather than exact, name matching (experiment)")
    var approximateMatching = false

    @Flag(name:.customShort("V"), help:"Validate names (experiment)")
    var validateNames = false

    @Flag(name:.shortAndLong, help:"Search by group ID")
    var groupIDSearch = false
    
    
    
    mutating func run() throws {
        print("it's appledir, but in swift!")
        print("People: \(people)")
        print("Output fields: \(outputFields)")
        print("Photo path: \(photoPath)")
    }
}

