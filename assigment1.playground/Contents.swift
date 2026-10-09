

import Foundation


let firstName: String = "Aruzhan"
let lastName: String = "Altynbekova"
let birthYear: Int = 2007
let height: Double = 1.63
let isStudent: Bool = true
let city: String = "Almaty"


//bonus task
let currntYear: Int = 2026
let age: Int = currntYear - birthYear

//hobbie
let hobby = "Sleeping"
let numberOfHobbies: Int = 1
let favoriteNumber: Int = 67
let isHobbyCreative: Bool = false
let favoriteColor: String = "pink"

let futureGoals: String = "Become a full stack developer"
let favoriteActivity: String = "volleyball"

let lifeStory: String = """
My name is \(firstName) \(lastName). I am \(age) years old, born in \(birthYear), and I live in \(city). \
I am \(height)m tall and it is \(isStudent) that I am currently a student. \
My favorite hobby is \(hobby). Is it creative? \(isHobbyCreative). \
I have \(numberOfHobbies) hobbies in total, my favorite color is \(favoriteColor), and my favorite number is \(favoriteNumber). \
For outdoor activities, I really enjoy \(favoriteActivity). \(futureGoals)
"""

print(lifeStory)
