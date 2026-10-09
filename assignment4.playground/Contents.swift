// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each declaration when you start working on it.


// MARK: Level 1 · The Deck Register

// 1.1
 enum Deck: String, CaseIterable {
     case bridge, lab, cargo, medbay,engine
     
     var evacuationPriority: Int{
         switch self{
         case .bridge: return 1
         case .medbay: return 2
         case .lab: return 3
         case .engine: return 4
         case .cargo: return 5
             
         }
     }
 }

for deck in Deck.allCases{
    print("\(deck.rawValue): priority \(deck.evacuationPriority)")
}

// 1.2
 enum AlarmLevel: Int {
     case green = 0, yellow, orange, red
     
     static func level(forTotalMass mass: Int) -> AlarmLevel{
         let steps = min(mass / 500, 3)
         return AlarmLevel(rawValue: steps) ?? .green
     }
 }

print(AlarmLevel.level(forTotalMass: 0))
print(AlarmLevel.level(forTotalMass: 940))
print(AlarmLevel.level(forTotalMass: 4000))

// MARK: Level 2 · The Manifest

// 2.1
 enum ManifestEntry {
     case crate(id: Int, massKg: Int)
     case container(code: String, massKg: Int)
     case livestock(species: String, count: Int, massPerUnitKg: Int)
     case unknown(raw: String)
 }

// 2.2
 func parseEntry(_ line: String) -> ManifestEntry {
     let parts = fields(line)
     guard let tag = parts.first else{ return .unknown(raw: line)}
     
     switch tag{
     case "crate":
         guard parts.count == 3, let id = Int(parts[1]), let mass = Int(parts[2]) else {
             return .unknown(raw: line)
         }
         return .crate(id: id, massKg: mass)
         
     case "container":
         guard parts.count == 3, let mass = Int(parts[2]) else{
             return .unknown(raw: line)
         }
         return .container(code: parts[1], massKg: mass)
         
     case "livestock":
         guard parts.count == 4, let count = Int(parts[2]), let perUnit = Int(parts[3]) else { return .unknown(raw: line)
         }
         return .livestock(species: parts[1], count: count, massPerUnitKg: perUnit)
     default:
         return .unknown(raw: line)
         
     }
 }

// 2.3
 func mass(of entry: ManifestEntry) -> Int {
     switch entry {
     case .crate(_, let massKg):
         return massKg
     case .container(_, let massKg):
         return massKg
     case .livestock(_, let count, let massPerUnitKg):
         return count * massPerUnitKg
     case .unknown:
         return 0
     }
 }

var totalMass = 0
var unknownCount = 0
for line in rawManifest{
    let entry = parseEntry(line)
    totalMass += mass(of: entry)
    if case .unknown = entry{ unknownCount += 1}
}
print("Total mass:", totalMass)
print("Unknown lines:", unknownCount)
print(parseEntry("create:101:120"))

 let A = totalMass


// MARK: Level 3 · Crew Snapshots

// 3.1
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int
    
    mutating func breathe(_ amount: Int){
        oxygen = max(0, oxygen - amount)
    }
    mutating func move(to deck: Deck){
        self.deck = deck
    }
    mutating func reviveInMedbay(){
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }
    static func rookie(named name: String) -> CrewSnapshot{
        CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}
// 3.2
 var crewRoster: [CrewSnapshot] = []
for record in crewData{
    guard let deck = Deck(rawValue: record.deck) else{
        print("Warning: unknown deck '\(record.deck)' for \(record.name), skipped")
        continue
    }
    crewRoster.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
}
print(crewRoster.count)

var testSnap = CrewSnapshot.rookie(named: "Test")
testSnap.breathe(30); print(testSnap)
testSnap.move(to: .lab); print(testSnap)
testSnap.reviveInMedbay(); print(testSnap)

// 3.3 · Value-semantics demonstration (copy / plain parameter / inout)
func damageInsideFunction(_ s: CrewSnapshot){
    var local = s
    local.oxygen -= 30
    print(" inside function \(local.oxygen)")
}
func damageInPlace(_ s: inout CrewSnapshot){
    s.oxygen -= 30
}
let original = CrewSnapshot.rookie(named: "demo")
var copy = original
copy.oxygen = 10
print("1. After changing copy -> original: \(original.oxygen), copy: \(copy.oxygen)")
var patient = CrewSnapshot.rookie(named: "Patient")
print("2. Before plain function: \(patient.oxygen)")
damageInsideFunction(patient)
print("2. After plain function:  \(patient.oxygen)")

print("3. Before inout: \(patient.oxygen)")
damageInPlace(&patient)
print("3. After inout:  \(patient.oxygen)")

// MARK: Level 4 · The Teleport Pod

// 4.1
 final class TeleportPod {
     let id: String
     var chargeLevel: Int
     var occupant: CrewSnapshot?
     
     init(id: String, chargeLevel: Int){
         self .id = id
         self .chargeLevel = chargeLevel
         self .occupant = nil
     }
     func load(_ crew: CrewSnapshot) -> Bool {
         guard occupant == nil, chargeLevel >= 20 else{return false}
         occupant = crew
         return true
     }
     func fire() -> CrewSnapshot?{
         guard let crew = occupant else{return nil}
         chargeLevel -= 20
         occupant = nil
         return crew
     }
     
     deinit {
         print("Pod \(id) deallocated")
     }
 }

// 4.2 · Charge ledger: load+fire three times, then fire an empty pod
func findCrew(named name: String, in roster: [CrewSnapshot]) -> CrewSnapshot? {
    for member in roster where member.name == name {
        return member
    }
    return nil
}

let mainPod = TeleportPod(id: "P-1", chargeLevel: 100)
for(index, name) in ["Timur", "Dana", "Nurlan"].enumerated(){
    guard let member = findCrew(named: name, in: crewRoster) else{continue}
    let loaded = mainPod.load(member)
    let fired = mainPod.fire()
    print("Step \(index + 1): load \(name) = \(loaded), fired = \(fired?.name ?? "nobody"), charge = \(mainPod.chargeLevel)")
}
let empty = mainPod.fire()
print("Step 4: empty fire = \(empty?.name ?? "nil"), charge = \(mainPod.chargeLevel)")
let C = mainPod.chargeLevel

// 4.3 · Reference-semantics demonstration

let alias = mainPod
alias.chargeLevel = 5
print("pod: \(mainPod.chargeLevel), alias: \(alias.chargeLevel)")

var snapA = CrewSnapshot.rookie(named: "Same")
var snapB = snapA
snapB.oxygen = 1
print("snapA: \(snapA.oxygen), snapB: \(snapB.oxygen)")



// MARK: Level 5 · Station Systems

// 5.1
final class Station {
    let callSign: String

    var hullIntegrity: Int {
        willSet {
            print("Hull: \(hullIntegrity) -> \(newValue)")
        }
        didSet {
            if hullIntegrity > 100 { hullIntegrity = 100 }
            else if hullIntegrity < 0 { hullIntegrity = 0 }
        }
    }

    var oxygenByDeck: [Deck: Int]

    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        return "\(self.callSign): hull \(self.hullIntegrity), oxygen \(self.totalOxygen)"
    }()

    var totalOxygen: Int {
        var sum = 0
        for value in oxygenByDeck.values { sum += value }
        return sum
    }

    var averageOxygen: Int {
        get {
            guard oxygenByDeck.count > 0 else { return 0 }
            return totalOxygen / oxygenByDeck.count
        }
        set {
            for deck in Array(oxygenByDeck.keys) {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(callSign: String, hullIntegrity: Int = 100) {
        self.callSign = callSign
        self.hullIntegrity = hullIntegrity
        var dict: [Deck: Int] = [:]
        for reading in deckReadings {
            if let deck = Deck(rawValue: reading.deck) {
                dict[deck] = reading.oxygen
            } else {
                print("Warning: '\(reading.deck)' is not a real deck, skipped")
            }
        }
        self.oxygenByDeck = dict
    }
}

let station = Station(callSign: "ALMA-7")
let B = station.averageOxygen
print("B =", B)
print("Total oxygen:", station.totalOxygen)

print("Before diagnostics")
print(station.fullDiagnostics)
print(station.fullDiagnostics)

station.averageOxygen = 70
print(station.averageOxygen, station.totalOxygen)

// 5.2 · The clamp trap: 130, then -40, then 55
station.hullIntegrity = 130; print(station.hullIntegrity)
station.hullIntegrity = -40; print(station.hullIntegrity)
station.hullIntegrity = 55;  print(station.hullIntegrity)

// MARK: Level 6 · Incident Reports
// Three of these compile and are wrong. One does not compile.
// For each: expectation, actual behaviour, the language rule, the fix.


// Report 1
var roster = crewRoster
for index in 0..<roster.count {
    roster[index].oxygen -= 10
}

print(roster[0].oxygen)   // author expected the crew to have lost oxygen

// Report 2
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = TeleportPod(id: "B", chargeLevel: podA.chargeLevel)
podB.chargeLevel = 0
print(podA.chargeLevel)   // author expected 100

// Report 3
struct Logbook {
    var entries: [String] = []
    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}

// Report 4
var snapshot = CrewSnapshot.rookie(named: "Dana")
snapshot.oxygen = 40

let pod = TeleportPod(id: "B", chargeLevel: 50)
pod.chargeLevel = 10


// MARK: Level 7 · Sealing the Black Box

// The leaky original:
final class FlightRecorder {
    private var entries: [String] = []
    private(set) var isSealed = false
    var count: Int { entries.count }
    var transcript: String {
        var text = ""
        for (index, entry) in entries.enumerated() {
            text += "\(index + 1). \(entry)\n"
        }
        return text
    }
    func add(_ entry: String) {
        guard isSealed == false else { return }
        entries.append(entry)
    }
    func seal() {
        isSealed = true
    }
    fileprivate func linesForAudit() -> [String] {
        entries
    }
}

func auditTranscript(of recorder: FlightRecorder) -> String {
    let lines = recorder.linesForAudit()
    return "AUDIT: \(lines.count) entries, sealed: \(recorder.isSealed)"
}

let recorder = FlightRecorder()
recorder.add("Hull breach detected")
recorder.add("Teleporter offline")
recorder.seal()
recorder.add("This must be ignored")
print(recorder.count)
print(recorder.transcript)
print(auditTranscript(of: recorder))


// MARK: Finale · Integrity Code

let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")

// MARK: Bonus

// deinit in TeleportPod, a do-block lifetime experiment, and === identity

var survivor: TeleportPod?
do {
    let temp = TeleportPod(id: "T-1", chargeLevel: 100)
    survivor = temp
    print("inside do block")
}
print("after do block: pod is still alive")
survivor = nil
print("after survivor = nil")

func comparePods(_ a: TeleportPod, _ b: TeleportPod) -> String {
    if a === b { return "same pod (one object)" }
    if a.id == b.id && a.chargeLevel == b.chargeLevel { return "two pods with equal contents" }
    return "different pods"
}


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why did CrewSnapshot get an initializer for free and TeleportPod did not?
 CrewSnapshot is a struct. Swift can make an initializer automatically.
 TeleportPod is a class. It needs its own initializer.

 2. What does `mutating` do to self, and why do classes never need it?
 mutating allows a struct to change itself.
 Classes do not need it because they are reference types.

 3. In Report 4 both values are `let`. What exactly does `let` freeze for a
    struct, and what does it freeze for a class?
 For a struct, let means we cannot change its properties.
 For a class, let means we cannot change the object reference, but we can change its var properties.

 4. Why must a lazy property be var? When does lazy change behaviour, not
    just performance?
 Because its value is created later, when we first use it.
 lazy can change behavior because the code runs later, not at the start.

 5. private vs fileprivate: where in your FlightRecorder would private be
    too strict?
 private allows access only inside the declaration and its extensions in the same file.
 fileprivate allows access anywhere in the same file.
 We use fileprivate when another type in the same file needs access to FlightRecorder data.

 Bonus. On which line does deinit fire, and why can't === be used on
 CrewSnapshot?
 deinit runs when the last strong reference to a class object is removed.
 === works only with classes. CrewSnapshot is a struct, not a class.

*/
