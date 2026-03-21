import Foundation

// Define calculator errors used when invalid cases occur
enum CalculatorError: Error {
    case invalidInput
    case divideByZero
}

class checkInput {

    func validateTokens(_ args: [String]) throws {
        // Only allow integers, operators, and brackets
        for t in args {
            let isInteger = Int(t) != nil
            let isOperator = t=="+" || t == "-" || t == "x" || t == "/" || t == "%"
            let isBracket = t == "(" || t == ")"

            guard isInteger || isOperator || isBracket else {
                throw CalculatorError.invalidInput
            }
        }

        let FirstTokens = ["+", "-", "x", "/", "%", ")"]
        let LastTokens = ["+", "-", "x", "/", "%", "("]
        // Check whether the first token is invalid
        if FirstTokens.contains(args[0]) {
            throw CalculatorError.invalidInput
        }
        // Check whether the last token is invalid
        if LastTokens.contains(args[args.count - 1]) {
            throw CalculatorError.invalidInput
        }
    }
}

class Addition {
    func add(no1: Int, no2: Int) -> Int {
        return no1 + no2
    }
}

class Subtraction {
    func sub(no1: Int, no2: Int) -> Int {
        return no1 - no2
    }
}

class Multiplication {
    func mul(no1: Int, no2: Int) -> Int {
        return no1 * no2
    }
}

// Division class with divide-by-zero protection
class Division {
    func div(no1: Int, no2: Int) throws -> Int {
        guard no2 != 0 else {
            throw CalculatorError.divideByZero
        }
        return no1 / no2
    }
}

// Modulus class with divide-by-zero protection
class Modulus {
    func mod(no1: Int, no2: Int) throws -> Int {
        guard no2 != 0 else {
            throw CalculatorError.divideByZero
        }
        return no1 % no2
    }
}

// Main controller class
class Calculator {
    let validator = checkInput()
    let add = Addition()
    let sub = Subtraction()
    let mul = Multiplication()
    let div = Division()
    let mod = Modulus()

    // Main calculate function that returns the final result as a string
    func calculate(args: [String]) throws -> String {
        try validator.validateTokens(args)  // First validate the input tokens

        let result = try solveExpression(args)
        return String(result)
    }

    // Solve the expression in order: brackets, then multiply/divide/mod, then add/subtract
    func solveExpression(_ tokens: [String]) throws -> Int {

        // Process the tokens step by step and return the final integer result
        let afterBr = try solveBrackets(tokens)  // First solve expressions inside brackets
        let afterMDM = try solveMultiplyDivideMod(afterBr)  // Then solve multiply, divide, and modulus operations
        let finalAns = try solveAddSubtract(afterMDM)  // Finally solve addition and subtraction from left to right

        return finalAns
    }

    // Used for bracket contents only: no more bracket checking, just multiply/divide/mod, then add/subtract
    func solveExpressionWithoutBrackets(_ tokens: [String]) throws -> Int {
        guard !tokens.contains("("), !tokens.contains(")") else {
            throw CalculatorError.invalidInput
        }

        let afterMDM = try solveMultiplyDivideMod(tokens)
        let finalAns = try solveAddSubtract(afterMDM)
        return finalAns
    }

    // Find bracket pairs, solve them, and return tokens without brackets
    func solveBrackets(_ tokens: [String]) throws -> [String] {
        var list = tokens  // Make a copy of the token list so it can be modified
        // Keep looping while there are still brackets in the token list
        while list.contains("(") || list.contains(")") {
            // Find the index of the first right bracket
            guard let rightI = list.firstIndex(of: ")") else {
                throw CalculatorError.invalidInput
            }

            var leftI: Int? = nil
            var i = rightI - 1
            // Search left to find the matching left bracket, then stop
            while i >= 0 {
                if list[i] == "(" {
                    leftI = i
                    break
                }
                i -= 1
            }

            guard let start = leftI else {
                throw CalculatorError.invalidInput
            }
            // If the brackets are empty, throw an input error
            guard start + 1 < rightI else {
                throw CalculatorError.invalidInput
            }
            // Extract the tokens inside the innermost brackets
            let inside = Array(list[(start + 1)..<rightI])
            // Solve the expression inside the innermost brackets
            let insideAns = try solveExpressionWithoutBrackets(inside)
            // Get the tokens on the left side
            let leftPart = Array(list[0..<start])
            // Get the tokens on the right side
            let rightPart = Array(list[(rightI + 1)..<list.count])
            // Rebuild the token list as left part + bracket result + right part
            list = leftPart + [String(insideAns)] + rightPart
        }
        // Return the updated token list; the loop stops when no brackets remain
        return list
    }

    // Handle multiply, divide, and modulus only
    func solveMultiplyDivideMod(_ tokens: [String]) throws -> [String] {

        var currentTokens = tokens
        var i = 0
        // Scan the token list and solve multiply, divide, and modulus operations
        while i < currentTokens.count {
            let token = currentTokens[i]
            // If the current token is x, /, or %, process it
            if token == "x" || token == "/" || token == "%" {
                // Make sure the operator has valid tokens on both sides
                guard i > 0, i + 1 < currentTokens.count else {
                    throw CalculatorError.invalidInput
                }
                // Make sure both sides can be converted to integers
                guard let leftNo = Int(currentTokens[i - 1]) else {
                    throw CalculatorError.invalidInput
                }
                guard let rightNo = Int(currentTokens[i + 1]) else {
                    throw CalculatorError.invalidInput
                }

                // Use the correct calculation based on the operator
                let result: Int
                if token == "x" {
                    result = mul.mul(no1: leftNo, no2: rightNo)
                } else if token == "/" {
                    result = try div.div(no1: leftNo, no2: rightNo)
                } else {
                    result = try mod.mod(no1: leftNo, no2: rightNo)
                }
                // Replace the three tokens with the calculated result
                let beforePart = Array(currentTokens[0..<(i - 1)])
                let afterPart = Array(currentTokens[(i + 2)..<currentTokens.count])
                currentTokens = beforePart + [String(result)] + afterPart
                i = 0
            } else {
                i += 1
            }
        }
        // Return the token list after all multiply/divide/mod operations are done
        return currentTokens
    }

    // Finally handle addition and subtraction in order
    func solveAddSubtract(_ tokens: [String]) throws -> Int {
        // Convert the first token to an integer; throw an error if it fails
        guard let firstNum = Int(tokens[0]) else {
            throw CalculatorError.invalidInput
        }

        var result = firstNum
        var i = 1

        // Start the addition and subtraction loop
        while i < tokens.count {

            let token = tokens[i]
            // Convert the next number token to an integer; throw an error if it fails
            guard let nextNum = Int(tokens[i + 1]) else {
                throw CalculatorError.invalidInput
            }
            // Check whether the operator is + or -
            if token == "+" {
                result = add.add(no1: result, no2: nextNum)
            } else if token == "-" {
                result = sub.sub(no1: result, no2: nextNum)
            } else {
                throw CalculatorError.invalidInput
            }

            i += 2
        }
        // Return the final integer result after the loop ends
        return result
    }
}
