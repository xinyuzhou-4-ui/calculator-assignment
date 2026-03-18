//
//  Calculator.swift
//  calc
//
//  Created by Jacktator on 31/3/20.
//  Copyright © 2020 UTS. All rights reserved.
 
import Foundation
//枚举一个错误列表，遇到相应的错误时引用
enum CalculatorError: Error {
    case invalidInput
    case divideByZero
}
//检查输入内容是否合理
class InputValidator {
//
    func validateTokens(_ args: [String]) throws {
//只允许其中有这些符号以及数字
        for token in args {
            let isInteger = Int(token) != nil
            let isOperator = token == "+" || token == "-" || token == "x" || token == "/" || token == "%"
            let isBracket = token == "(" || token == ")"

            guard isInteger || isOperator || isBracket else {
                throw CalculatorError.invalidInput
            }
        }
//检查开头与结尾的字符适合符合规则
        let invalidFirstTokens = ["+", "-", "x", "/", "%", ")"]
        let invalidLastTokens = ["+", "-", "x", "/", "%", "("]

        if invalidFirstTokens.contains(args[0]) {
            throw CalculatorError.invalidInput
        }

        if invalidLastTokens.contains(args[args.count - 1]) {
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
//总控制入口
class Calculator {
    let validator = InputValidator()
    let addition = Addition()
    let subtraction = Subtraction()
    let multiplication = Multiplication()
    let division = Division()
    let modulus = Modulus()
    //计算函数返回字符最终值用来通过检测
    func calculate(args: [String]) throws -> String {
        try validator.validateTokens(args)

        let result = try solveExpression(args)
        return String(result)
    }
    //按顺序将表达式算完，按照计算顺序，括号>乘除取模>加减
    func solveExpression(_ tokens: [String]) throws -> Int {
       
        let afterBrackets = try solveBrackets(tokens)
        let afterMultiplyDivideMod = try solveMultiplyDivideMod(afterBrackets)
        let finalResult = try solveAddSubtract(afterMultiplyDivideMod)

        return finalResult
    }
    
    // 给括号里面单独用：不再重复找括号，只做乘除取模，再做加减
    func solveExpressionWithoutBrackets(_ tokens: [String]) throws -> Int {
        guard !tokens.contains("("), !tokens.contains(")") else {
            throw CalculatorError.invalidInput
        }

        let afterMultiplyDivideMod = try solveMultiplyDivideMod(tokens)
        let finalResult = try solveAddSubtract(afterMultiplyDivideMod)
        return finalResult
    }

    // 先找最里面的一对括号，先算括号里面，再替换成结果，重复到没有括号为止
    func solveBrackets(_ tokens: [String]) throws -> [String] {
        var currentTokens = tokens

        while currentTokens.contains("(") || currentTokens.contains(")") {
            guard let rightBracketIndex = currentTokens.firstIndex(of: ")") else {
                throw CalculatorError.invalidInput
            }

            var leftBracketIndex: Int? = nil
            var checkIndex = rightBracketIndex - 1

            while checkIndex >= 0 {
                if currentTokens[checkIndex] == "(" {
                    leftBracketIndex = checkIndex
                    break
                }
                checkIndex -= 1
            }

            guard let start = leftBracketIndex else {
                throw CalculatorError.invalidInput
            }

            guard start + 1 < rightBracketIndex else {
                throw CalculatorError.invalidInput
            }

            let insideTokens = Array(currentTokens[(start + 1)..<rightBracketIndex])
            let insideResult = try solveExpressionWithoutBrackets(insideTokens)

            let beforeBracket = Array(currentTokens[0..<start])
            let afterBracket = Array(currentTokens[(rightBracketIndex + 1)..<currentTokens.count])
            currentTokens = beforeBracket + [String(insideResult)] + afterBracket
        }

        return currentTokens
    }

    // 括号处理完以后，只处理乘除取模
    func solveMultiplyDivideMod(_ tokens: [String]) throws -> [String] {
        guard !tokens.isEmpty else {
            throw CalculatorError.invalidInput
        }

        var currentTokens = tokens
        var index = 0

        while index < currentTokens.count {
            let token = currentTokens[index]

            if token == "x" || token == "/" || token == "%" {
                guard index > 0, index + 1 < currentTokens.count else {
                    throw CalculatorError.invalidInput
                }

                guard let leftNumber = Int(currentTokens[index - 1]) else {
                    throw CalculatorError.invalidInput
                }

                guard let rightNumber = Int(currentTokens[index + 1]) else {
                    throw CalculatorError.invalidInput
                }

                let result: Int

                if token == "x" {
                    result = multiplication.multiply(no1: leftNumber, no2: rightNumber)
                } else if token == "/" {
                    result = try division.divide(no1: leftNumber, no2: rightNumber)
                } else {
                    result = try modulus.mod(no1: leftNumber, no2: rightNumber)
                }

                let beforePart = Array(currentTokens[0..<(index - 1)])
                let afterPart = Array(currentTokens[(index + 2)..<currentTokens.count])
                currentTokens = beforePart + [String(result)] + afterPart
                index = 0
            } else {
                index += 1
            }
        }

        return currentTokens
    }

    // 最后按顺序处理加减
    func solveAddSubtract(_ tokens: [String]) throws -> Int {
       
        guard let firstNumber = Int(tokens[0]) else {
            throw CalculatorError.invalidInput
        }

        var result = firstNumber
        var index = 1

        while index < tokens.count {
            guard index + 1 < tokens.count else {
                throw CalculatorError.invalidInput
            }

            let token = tokens[index]

            guard let nextNumber = Int(tokens[index + 1]) else {
                throw CalculatorError.invalidInput
            }

            if token == "+" {
                result = addition.add(no1: result, no2: nextNumber)
            } else if token == "-" {
                result = subtraction.subtract(no1: result, no2: nextNumber)
            } else {
                throw CalculatorError.invalidInput
            }

            index += 2
        }

        return result
    }

   
}
