//
//  main.swift
//  calc
//
//  Created by Jesse Clark on 12/3/18.
//  Copyright © 2018 UTS. All rights reserved.
//

import Foundation

var args = ProcessInfo.processInfo.arguments
args.removeFirst() // remove the name of the program

// Initialize a Calculator object
let calculator = Calculator()

// Calculate the result from the command-line arguments
 do {
    let result = try calculator.calculate(args: args)
    print(result)
} catch {
    fputs("Error\n", stderr)
    exit(1)
}
