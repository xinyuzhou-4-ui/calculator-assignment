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
//检查输入内容是否合理的类
class InputValidator {

    func validateTokens(_ args: [String]) throws {
//只允许其中有这些符号以及整数数字
        for token in args {
            let isInteger = Int(token) != nil
            let isOperator = token == "+" || token == "-" || token == "x" || token == "/" || token == "%"
            let isBracket = token == "(" || token == ")"

            guard isInteger || isOperator || isBracket else {
                throw CalculatorError.invalidInput
            }
        }

        let invalidFirstTokens = ["+", "-", "x", "/", "%", ")"]
        let invalidLastTokens = ["+", "-", "x", "/", "%", "("]
//检查开头是否有不符要求字符
        if invalidFirstTokens.contains(args[0]) {
            throw CalculatorError.invalidInput
        }
//检查结尾字符是否有不符合要求字符
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

//减法类并排除除零情况
class Division {
    func divide(no1: Int, no2: Int) throws -> Int {
        guard no2 != 0 else {
            throw CalculatorError.divideByZero
        }
        return no1 / no2
    }
}
//取模类并排除零情况
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
        try validator.validateTokens(args)//首先尝试检测字符输入检测

        let result = try solveExpression(args)//
        return String(result)
    }
//按顺序将表达式算完，按照计算顺序，括号>乘除取模>加减
    func solveExpression(_ tokens: [String]) throws -> Int {
//返回字符数组之后计算最终返回字符
        let afterBrackets = try solveBrackets(tokens)//首先解决括号内的计算
        let afterMultiplyDivideMod = try solveMultiplyDivideMod(afterBrackets)//其次进行乘除取模计算
        let finalResult = try solveAddSubtract(afterMultiplyDivideMod)//剩下的按照顺序进行加减法

        return finalResult
    }
    
// 给括号里面单独用：不再重复找括号，只做乘除取模，再做加减，返回int
    func solveExpressionWithoutBrackets(_ tokens: [String]) throws -> Int {
        guard !tokens.contains("("), !tokens.contains(")") else {
            throw CalculatorError.invalidInput
        }

        let afterMultiplyDivideMod = try solveMultiplyDivideMod(tokens)
        let finalResult = try solveAddSubtract(afterMultiplyDivideMod)
        return finalResult
    }

// 找到括号并且计算返回不带括号的数列方法
    func solveBrackets(_ tokens: [String]) throws -> [String] {
        var currentTokens = tokens//复制一个数列进行改变
//其中有括号进入循环
        while currentTokens.contains("(") || currentTokens.contains(")") {
//找到第一个右括号的位置序号
            guard let rightBracketIndex = currentTokens.firstIndex(of: ")") else {
                throw CalculatorError.invalidInput
            }

            var leftBracketIndex: Int? = nil
            var checkIndex = rightBracketIndex - 1
//找到第一个左括号就退出循环并记录
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
//左右括号连续，抛出格式错误
            guard start + 1 < rightBracketIndex else {
                throw CalculatorError.invalidInput
            }
//取出最内层括号里面的元素
            let insideTokens = Array(currentTokens[(start + 1)..<rightBracketIndex])
//计算最内层括号的结果
            let insideResult = try solveExpressionWithoutBrackets(insideTokens)
//取出左边的数列
            let beforeBracket = Array(currentTokens[0..<start])
//取出右边的数列
            let afterBracket = Array(currentTokens[(rightBracketIndex + 1)..<currentTokens.count])
//左+括号结果+右
            currentTokens = beforeBracket + [String(insideResult)] + afterBracket
        }
//将最后的数组保存返回循环，验证是否有还有括号，如果没有则循环停止
        return currentTokens
    }

//只处理乘除取模
    func solveMultiplyDivideMod(_ tokens: [String]) throws -> [String] {
       
        var currentTokens = tokens
        var index = 0
//找出乘除取模进行计算
        while index < currentTokens.count {
            let token = currentTokens[index]
//如果其中存在乘除取模符号，则进行判断
            if token == "x" || token == "/" || token == "%" {
//保证数列内部的不是符号，否则上报错误
                guard index > 0, index + 1 < currentTokens.count else {
                    throw CalculatorError.invalidInput
                }
//保证左右两边都是数字
                guard let leftNumber = Int(currentTokens[index - 1]) else {
                    throw CalculatorError.invalidInput
                }
                guard let rightNumber = Int(currentTokens[index + 1]) else {
                    throw CalculatorError.invalidInput
                }

//根据符号不同，引用不同的计算式进行计算
                let result: Int
                if token == "x" {
                    result = multiplication.multiply(no1: leftNumber, no2: rightNumber)
                } else if token == "/" {
                    result = try division.divide(no1: leftNumber, no2: rightNumber)
                } else {
                    result = try modulus.mod(no1: leftNumber, no2: rightNumber)
                }
//将计算完的result作为元素插入原本的数组当中
                let beforePart = Array(currentTokens[0..<(index - 1)])
                let afterPart = Array(currentTokens[(index + 2)..<currentTokens.count])
                currentTokens = beforePart + [String(result)] + afterPart
                index = 0
            } else {
                index += 1
            }
        }
//结束循环之后返回数组
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
