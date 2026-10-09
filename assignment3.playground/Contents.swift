// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each signature when you start working on it.


// MARK: Level 1 · Decoding Telemetry

// 1.1
 func parseReading(_ raw: String) -> Reading? {
     guard let (sensor, valueText) = splitOnce(raw, by: ":"),
           !sensor.isEmpty,
           let value = Int(valueText),
           value >= 0 || sensor == "TEMP"
     else{
         return nil
     }
     return (sensor: sensor, value: value)
 }

// 1.2
 func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
     var valid: [Reading] = []
     var invalidCount = 0
     for line in lines{
         if let reading = parseReading(line){
             valid.append(reading)
         } else {
             invalidCount += 1
         }
     }
     return(valid, invalidCount)
 }

let parsed = parseLog(rawLog)
let A = parsed.invalidCount

print(parseReading("02:87") as Any)
print(parseReading("RAD:-1") as Any)
print(parseReading(":55") as Any)
print("A=", A)

// MARK: Level 2 · Analysis

// 2.1
 func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
     var result: [Reading] = []
     for reading in readings{
         if isIncluded(reading){
             result.append(reading)
         }
     }
     return result
 }
 func values(of readings: [Reading]) -> [Int] {
     var result: [Int] = []
     for reading in readings{
         result.append(reading.value)
     }
     return result
 }

let o2Readings = select(parsed.valid){$0.sensor == "O2"}
let o2Values = values(of: o2Readings)
print(o2Values)
print(values(of: select(parsed.valid){$0.sensor == "TEMP"}))

// 2.2
 func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
     guard let first = values.first else{return nil}
     var minV = first
     var maxV = first
     var sm = 0
     for v in values{
         if v<minV{
             minV = v
         }
         if v>maxV{
             maxV = v
         }
         sm+=v
     }
     return(minV, maxV, Double(sm)/Double(values.count))
 }
 func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
     stats(of: values)
 }

print(stats(3,8,1) as Any)
print(stats() as Any)

let B = Int(stats(of: o2Values)?.average ?? 0)
print("B=", B)

// 2.3 · The Closure Ladder (5 sorts, then compare results in code)
let ladder1 = parsed.valid.sorted(by: {(a: Reading, b: Reading) -> Bool in return a.value > b.value})
let ladder2 = parsed.valid.sorted(by: {a,b in return a.value > b.value})
let ladder3 = parsed.valid.sorted(by: {a,b in a.value>b.value})
let ladder4 = parsed.valid.sorted(by: {$0.value > $1.value})
let ladder5 = parsed.valid.sorted(by: {$0.value > $1.value})

func sameReadings(_ x: [Reading], _ y: [Reading]) -> Bool{
    guard x.count == y.count else {return false}
    for i in 0..<x.count{
        if x[i].sensor != y[i].sensor || x[i].value != y[i].value{
            return false
        }
    }
    return true
}

print(sameReadings(ladder1, ladder2),
sameReadings(ladder1, ladder3),
sameReadings(ladder1, ladder4),
sameReadings(ladder1, ladder5))


// MARK: Level 3 · Temperature Stabilization

// 3.1
 func heatUp(_ t: Int) -> Int { t + 5}
 func coolDown(_ t: Int) -> Int { t - 3 }
 func hold(_ t: Int) -> Int {t }

 func chooseProtocol(for temp: Int) -> (Int) -> Int {
     if temp < 18{return heatUp}
     if temp>24{return coolDown}
     return hold
 }

// 3.2
 func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
     var temp = start
     var steps = 0
     while(temp < 18 || temp > 24) && steps < maxSteps{
         let action = chooseProtocol(for: temp)
         temp = action(temp)
         steps += 1
     }
     return (temp, steps, temp >= 18 && temp <= 24)
 }
print(runUntilStable(from: 31))
print(runUntilStable(from: -100, maxSteps: 5))

// let C = ...
let tempReadings = select(parsed.valid){$0.sensor == "TEMP"}
var C = 0
if let tempStats = stats(of:values(of: tempReadings)){
    C = runUntilStable(from: tempStats.min).steps
}
print("C=", C)


// MARK: Level 4 · The Crew

// 4.1
 func oxygenLevel(of member: CrewMember) -> Int? {
     member.module?.oxygenTank?.level
 }

// 4.2
 func status(of member: CrewMember) -> String {
     guard let level = oxygenLevel(of: member)
     else{
         let place = member.module?.name ?? "open space"
         return "\(member.name): no data (\(place))"
     }
     if level < 20 {
             return "\(member.name): \(level)% CRITICAL"
         }
         return "\(member.name): \(level)% OK"
 }

// 4.3
 @discardableResult
 func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
     guard amount > 0 else{return 0}
     let moved = min(amount, source, 100 - target)
     source -= moved
     target += moved
     return moved
 }

var D = 0
if let labTank = lab.oxygenTank, let habTank = hab.oxygenTank {
    let moved = transferOxygen(from: &labTank.level, to: &habTank.level, amount: 30)
    print("perekacheno: ", moved)
    D = habTank.level
    
}
print("D =", D)

// 4.4
 func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
     var found: [CrewMember] = []
     for name in names{
         guard let member = roster[name] else{
             print("Unknown crew member: \(name)")
             continue
         }
         found.append(member)
     }
     found.sort {$0.priority < $1.priority}
     var result: [String] = []
     for member in found{
         result.append(member.name)
     }
     return result
 }

print(evacuationOrder("Dana", "ghost", "Aigerim", "Timur", roster: roster))
print(evacuationOrder("Nurlan", "Timur", roster: roster))


// MARK: Level 5 · The Saboteur's Logbook
// The saboteur's code is below, commented out (it needs your
// oxygenLevel(of:) to compile). Comment on every problem, then
// write fixed versions and a test that proves the logic bug is gone.


func reportOxygen(for member: CrewMember) -> String {
    guard let tank = member.module?.oxygenTank else{
        return "\(member.name): no data"
    }
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        if let level = oxygenLevel(of: member), level < 20 {
            return member.name
        }
    }
    return nil
}

if let labTank = lab.oxygenTank, let habTank = hab.oxygenTank{
    let savedLab = labTank.level
    let savedHab = habTank.level
    labTank.level = 5
    habTank.level = 7
    print(firstCritical(in: crew) ?? "none")
    labTank.level = savedLab
    habTank.level = savedHab
}
print(firstCritical(in: []) as Any)



// MARK: Finale · Launch Code

 let launchCode = "\(A)-\(B)-\(C)-\(D)"
 print("LAUNCH CODE: \(launchCode)")


// MARK: Bonus

// func makeAlarm(threshold: Int) -> (Int) -> Bool { }


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. guard let vs if let beyond syntax:
 
 guard let checks if we can continue. If the value is nil, we stop.
 if let checks a value and runs code if it exists.

 2. Why can't you pass [Int] to stats(_ values: Int...)?
 Because [Int] is an array, but Int... takes separate numbers.

 3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile?
 Because we cannot change the same variable two times at once with inout.

 4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile?
 Because oxygenLevel returns Int?, but "no data" is a String. The types are different.

 5. Full type of chooseProtocol and how to read it:

 Bonus. Where does the alarm counter live after makeAlarm returns?
 (Bool) -> (String) -> String
 It takes a Bool and returns a function. This function takes a String and returns a String.
 Bonus. Where does the alarm counter live after makeAlarm returns?
 The counter stays in the closure's memory. It is not deleted when makeAlarm returns.

*/
