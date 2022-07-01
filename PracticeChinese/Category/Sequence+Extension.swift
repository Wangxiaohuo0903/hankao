//
//  Sequence+Extension.swift
//  ChineseLearning
//
//  Created by feiyue on 19/04/2017.
//  Copyright © 2017 msra. All rights reserved.
//
import Foundation
import CocoaLumberjack
extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            self.swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        let result = Array(self)
        result.shuffle()
        return result
    }
}


class QuizLogic {
    private var ids: [Int]
    private var currentScore: Double
    private var wrongIds: Set<Int>
    private let wrongRate = 0.65//
    private let maxScore: Double = 100
    private var quizScore: Double!//每一题的得分
    static let selectedQuizNumber = 10
    
    init(indexes: [Int], selectedNum: Int) {
        let temp = indexes.shuffled()
        self.ids = Array(temp.prefix(selectedNum))
        self.currentScore = 0
        self.wrongIds = Set<Int>()
        if indexes.count <= 0 {
            self.quizScore = self.maxScore
        } else {
            self.quizScore = self.maxScore / Double(ids.count)
        }
    }
    
    convenience init(size: Int, selectedNum: Int) {
        if size <= 0 {
            self.init(indexes: [Int](), selectedNum: selectedNum)
        } else {
            self.init(indexes: Array(0...size - 1), selectedNum: selectedNum)
        }
    }
    
    //获取当前进度，如果做错题，进度不增加，如果做对了，那么增加剩余进度除以当前题目的数量
    func getScore() -> Double {
        if self.currentScore > self.maxScore {
            return self.maxScore
        }
        return self.currentScore
    }
    
    func getProgress() -> Double {
        let score = self.getScore()
        return score / self.maxScore
    }
    
    private func next(success: Bool) -> Int? {
        if ids.count <= 0 {
            self.currentScore = 100
            return nil
        }
        if success {
            if wrongIds.contains(ids.last!) {
                currentScore += wrongRate * quizScore
            } else {
                currentScore += quizScore
            }
            ids.removeLast()//将上一题移除，必须非空
        } else {//做错不加分
            let pre = ids.last!
            if false == wrongIds.contains(pre) {
                wrongIds.insert(pre)
                ids.append(pre)
            }
            ids = Array(ids.shuffled())
        }
        if self.currentScore + 0.001 >= self.maxScore {//达到总分之后就停止
            return nil
        }
        return ids.last
    }
    
    func getNext(success: Bool?) -> Int? {
        if let success = success {
            return next(success: success)
        }
        return self.ids.last
    }
    
    func showStatus() {
        DDLogInfo("socre: \(self.currentScore), progress: \(self.getProgress()):")
        DDLogInfo("count: \(self.ids.count), ids: \(self.ids)")
    }
    
    public static func test() {
        let select: [Bool?] = [nil, false, true, true, false, false, true, true, true, true, true, true, true]
        let temp: [Int] = Array(0...20)
        let q = QuizLogic(indexes: temp, selectedNum: 5)
        for s in select {
            let index = q.getNext(success: s)
            DDLogInfo("result: \(s), select: \(index)")
            q.showStatus()
            DDLogInfo("\n")
        }
    }
}
