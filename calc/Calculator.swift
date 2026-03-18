//
//  Calculator.swift
//  calc
//
//  Created by Jacktator on 31/3/20.
//  Copyright © 2020 UTS. All rights reserved.
//

import Foundation

enum CalculatorError: Error {
    case invalidInput
    case divideByZero
}

class InputValidator {
    func validateTokens(_ args: [String]) throws {
        guard !args.isEmpty else {
            throw CalculatorError.invalidInput
        }
       
        guard args.count % 2 == 1 else {
            throw CalculatorError.invalidInput
        }

        for i in 0..<args.count {
            let token = args[i]

            if i % 2 == 0 {
                guard Int(token) != nil else {
                    throw CalculatorError.invalidInput
                }
            } else {
                guard token == "+" || token == "-" || token == "x" || token == "/" || token == "%" else {
                    throw CalculatorError.invalidInput
                }
            }
        }
    }
}

class Addition {
    func add(no1: Int, no2: Int) -> Int {
        return no1 + no2
    }
}

class Subtraction {
    func subtract(no1: Int, no2: Int) -> Int {
        return no1 - no2
    }
}

class Multiplication {
    func multiply(no1: Int, no2: Int) -> Int {
        return no1 * no2
    }
}

class Division {
    func divide(no1: Int, no2: Int) throws -> Int {
        guard no2 != 0 else {
            throw CalculatorError.divideByZero
        }
        return no1 / no2
    }
}

class Modulus {
    func mod(no1: Int, no2: Int) throws -> Int {
        guard no2 != 0 else {
            throw CalculatorError.divideByZero
        }
        return no1 % no2
    }
}

class Calculator {
    let validator = InputValidator()
    let addition = Addition()
    let subtraction = Subtraction()
    let multiplication = Multiplication()
    let division = Division()
    let modulus = Modulus()
    
    func calculate(args: [String]) throws -> String {
        try validator.validateTokens(args)

        guard let firstNumber = Int(args[0]) else {
            throw CalculatorError.invalidInput
        }

        var result = firstNumber
        var index = 1

        while index < args.count {
            let operatorText = args[index]

            guard index + 1 < args.count else {
                throw CalculatorError.invalidInput
            }

            guard let nextNumber = Int(args[index + 1]) else {
                throw CalculatorError.invalidInput
            }

            if operatorText == "+" {
                result = addition.add(no1: result, no2: nextNumber)
            } else if operatorText == "-" {
                result = subtraction.subtract(no1: result, no2: nextNumber)
            } else if operatorText == "x" {
                result = multiplication.multiply(no1: result, no2: nextNumber)
            } else if operatorText == "/" {
                result = try division.divide(no1: result, no2: nextNumber)
            } else if operatorText == "%" {
                result = try modulus.mod(no1: result, no2: nextNumber)
            } else {
                throw CalculatorError.invalidInput
            }

            index += 2
        }

        return String(result)
    }
}




























/*class Calculator {
    
    /// For multi-step calculation, it's helpful to persist existing result
    var currentResult = 0;
    
    /// Perform Addition
    ///
    /// - Author: Jacktator
    /// - Parameters:
    ///   - no1: First number
    ///   - no2: Second number
    /// - Returns: The addition result
    ///
    /// - Warning: The result may yield Int overflow.
    /// - SeeAlso: https://developer.apple.com/documentation/swift/int/2884663-addingreportingoverflow
    func add(no1: Int, no2: Int) -> Int {
        return no1 + no2;
    }
    
    /// Handles integer parsing and the simplest valid expression forms.
    func calculate(args: [String]) throws -> String {
        // First test: a single integer such as 42, +4, -4
        if args.count == 1 {
            let inputText = args[0]

            guard let parsedInteger = Int(inputText) else {
                throw CalculatorError.invalidInput
            }

            currentResult = parsedInteger
            return String(currentResult)
        }

        // Second test: valid input should accept the form number operator number
        if args.count == 3 {
            let firstText = args[0]
            let operatorText = args[1]
            let secondText = args[2]

            guard let firstNumber = Int(firstText) else {
                throw CalculatorError.invalidInput
            }

            guard let secondNumber = Int(secondText) else {
                throw CalculatorError.invalidInput
            }

            guard operatorText == "+" else {
                throw CalculatorError.invalidInput
            }

            currentResult = add(no1: firstNumber, no2: secondNumber)
            return String(currentResult)
        }

        throw CalculatorError.invalidInput
    }
    
}
*/
