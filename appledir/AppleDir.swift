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
    mutating func run() throws {
        print("it's appledir, but in swift!")
    }
}

