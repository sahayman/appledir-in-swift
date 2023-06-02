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
    var blanksNotTrimmed = false
    
    @Flag(name:.shortAndLong, help:"Verbose output, including LDAP connection debugging")
    var verbose = false

    // Different output formats, grouped together
    enum OutputFormat: EnumerableFlag {
        case plain
        case table
        case json
        case vCard
        case csv
        static func name(for value: Self) -> NameSpecification {
            switch value {
            case .plain:
                return .long
            case .vCard:
                return [.customShort("V"), .long]
                
            default:
                return .shortAndLong
            }
        }
        static func help(for value: Self) -> ArgumentHelp? {
            switch value {
            case .plain: return ArgumentHelp(stringLiteral: "One line per user")
            case .table: return ArgumentHelp(stringLiteral: "Table format output")
            case .vCard: return ArgumentHelp(stringLiteral: "VCard format output")
            case .json: return ArgumentHelp(stringLiteral: "JSON format output")
            case .csv:  return ArgumentHelp(stringLiteral: "CSV format output")
            }
        }
    }
    
    @Flag(help:"Output format") var outputFormat: OutputFormat = .plain


    @Flag(name:.shortAndLong, help:"Approximate, rather than exact, name matching (experiment)")
    var approximateMatching = false

    @Flag(name:.customShort("N"), help:"Validate names (experiment)")
    var validateNames = false

    @Flag(name:.shortAndLong, help:"Search by group ID")
    var groupIDSearch = false
    
    
    
    mutating func run() throws {
        
        // Some options affect others and I'm not sure how to do that properly yet
        argumentTidyUp()
        
        print("it's appledir, but in swift!")
        print("People: \(people)")
        print("Output fields: \(outputFields)")
        print("Photo path: \(photoPath ??  "not set")")
        
        // Set up a connection
        
        LDAP.connect()
        
        outputHeaders()
        
        for person in  people {
            directoryOutput(for: ApplePerson(name: person))
        }
        outputFooters()
    }
    
    mutating func argumentTidyUp() {
        if shortOutput {
            outputFields = "name,email"
        }
    }
    
    func directoryOutput(for person: ApplePerson ) {
        print("Directory: \(person.name)")
    }
    
    func outputHeaders() {
        switch outputFormat {
        case .json:
            print("[")
        case .vCard:
            print("""
                    BEGIN:VCARD\r
                    VERSION:3.0\r
                    PRODID:-//Apple Inc.//Mac OS X 10.15.4//EN\r

                    """
                  )
        default:
            // nothing needed
            return
        }
    }
    func outputFooters() {
        switch outputFormat {
        case .json:
            print("\n]")
        case .vCard:
            print("END: VCARD\r")
        default:
            // nothing needed
            return
        }
    }
}

