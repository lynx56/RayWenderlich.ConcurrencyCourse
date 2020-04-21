import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let sentence = "I didn't fail the test. I just found 100 ways to do it wrong."
let wordOperations = BlockOperation()

let words = sentence.components(separatedBy: CharacterSet.whitespaces).filter({ !$0.isEmpty })

for word in words {
    wordOperations.addExecutionBlock {
        print(word)
    }
}

wordOperations.completionBlock = {
    PlaygroundPage.current.finishExecution()
}

let queue = OperationQueue()
queue.addOperation(wordOperations)
queue.waitUntilAllOperationsAreFinished()
