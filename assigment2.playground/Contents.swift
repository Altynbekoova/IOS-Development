import Foundation


var fruits = ["Apple", "Banana", "Cherry", "Mango", "Peach"]
print(fruits[2])


var favoriteNumbers: Set<Int> = [7, 9, 13, 21]
favoriteNumbers.insert(42)
print(favoriteNumbers)


let languageReleaseYears = [
    "Swift": 2014,
    "Python": 1991,
    "Java": 1995
]
print(languageReleaseYears["Swift"]!)


var colors = ["Red", "Green", "Blue", "Yellow"]
colors[1] = "Purple"
print(colors)


let setA: Set<Int> = [1, 2, 3, 4]
let setB: Set<Int> = [3, 4, 5, 6]
let intersectionSet = setA.intersection(setB)
print(intersectionSet)

var studentScores = [
    "Aruzhan": 95,
    "Ali": 88,
    "Dana": 92
]
studentScores["Ali"] = 94
print(studentScores)

let firstBatch = ["apple", "banana"]
let secondBatch = ["cherry", "date"]
let mergedArray = firstBatch + secondBatch
print(mergedArray)


var countryPopulations = [
    "Kazakhstan": 20_000_000,
    "Japan": 125_000_000
]
countryPopulations["France"] = 68_000_000
print(countryPopulations)


let animals1: Set<String> = ["cat", "dog"]
let animals2: Set<String> = ["dog", "mouse"]

let unionSet = animals1.union(animals2)
let finalAnimalsSet = unionSet.subtracting(animals2)
print(finalAnimalsSet)

let studentGrades: [String: [Int]] = [
    "Aruzhan": [100, 95, 98],
    "Arman": [85, 90, 88]
]
print("Second grade:", studentGrades["Aruzhan"]![1])
