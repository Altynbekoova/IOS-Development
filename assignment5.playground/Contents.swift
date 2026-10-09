// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each declaration when you start working on it.


// MARK: Level 1 · The Power Cell

// Why a class and not a struct here?  ->
final class PowerCell {
    private var charge: Int
    init(charge: Int) {
        self.charge = max(0, min(100, charge))
    }

    func level() -> Int { charge }
    func spend(_ amount: Int) -> Bool {
        guard amount > 0, amount <= charge else { return false }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        guard amount > 0 else { return }
        charge = min(100, charge + amount)               // выше 100 не уходим
    }
}

let testCell = PowerCell(charge: 150)
print(testCell.level())
print(testCell.spend(30), testCell.level())
print(testCell.spend(-5), testCell.spend(500), testCell.level())
testCell.recharge(by: 100); print(testCell.level())

// Encapsulation proof:
// testCell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level

// MARK: Level 2 · The Fleet

// 2.1  What does `final` on runOnce() buy you?  ->
class Drone: Diagnosable, Rechargeable {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }
    var statusLine: String { "\(id): \(cell.level())% \(cell.level().powerBar)" }
    
    func performTask() -> Int { 0 }
    
    final func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }

    var canRunAnotherTask: Bool { cell.level() >= powerCost }

    // Diagnosable
    var componentID: String { id }
    var statusCode: Int { code(forCharge: cell.level()) }
    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

// 2.2
final class WelderDrone: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 40 }
    func weldSeam() -> String { "\(id): seam welded" }
}

class ScannerDrone: Drone {
    override var powerCost: Int { 10 }
    override func performTask() -> Int { 15 }
    override var statusLine: String { super.statusLine + " [scanner]" }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }
    override func performTask() -> Int { 25 }
}

// 2.3
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":  return WelderDrone(id: id, cell: cell)
    case "scanner": return ScannerDrone(id: id, cell: cell)
    case "cargo":   return CargoDrone(id: id, cell: cell)
    default:        return nil
    }
}

var builtFleet: [Drone] = []
for record in fleetData {
    if let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
        builtFleet.append(drone)
    } else {
        print("Warning: unknown drone kind '\(record.kind)' (\(record.id)), skipped")
    }
}
let fleet: [Drone] = builtFleet
print(fleet.count)


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var total = 0
    for _ in 0..<max(rounds, 0) {
        for drone in fleet {
            total += drone.runOnce()                   
        }
    }
    return total
}

let A = runShift(fleet, rounds: 3)
print("A =", A)

var totalCharge = 0
var stillReady = 0
for drone in fleet {
    print(drone.statusLine)
    totalCharge += drone.cell.level()
    if drone.canRunAnotherTask { stillReady += 1 }
}
let B = totalCharge
let C = stillReady
print("B =", B, "C =", C)

// MARK: Level 4 · Diagnostics

// 4.1
protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}


// 4.2
protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int

    var componentID: String { id }
    var statusCode: Int { code(forCharge: chargeLevel) }
    // Why does Drone implement recharge(by:) without `mutating`?  ->
    // struct SensorModule: Diagnosable, Rechargeable { }
    // mutating: a struct is a value, so its method may change self only if marked `mutating`.
    mutating func recharge(by amount: Int) {
        guard amount > 0 else { return }
        chargeLevel = min(100, chargeLevel + amount)
    }
}
var sensors: [SensorModule] = []
for record in sensorData {
    sensors.append(SensorModule(id: record.id, chargeLevel: record.charge))
}

var spareSensor = SensorModule(id: "spare", chargeLevel: 90)
spareSensor.recharge(by: 50); print(spareSensor.chargeLevel)   // 100
let spareDrone = WelderDrone(id: "W-T", cell: PowerCell(charge: 10))
spareDrone.recharge(by: 30); print(spareDrone.cell.level())    // 40

// 4.3
// Why could [Drone] never have held the sensors?  ->
// func diagnosticsReport(_ components: [Diagnosable]) -> String { }
// [Drone] could never hold sensors: SensorModule is a struct and cannot inherit from Drone,
// but both can conform to the Diagnosable protocol.
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var lines: [String] = []
    for component in components {
        lines.append(component.diagnose())
    }
    return lines.joined(separator: "\n")
}

var components: [Diagnosable] = []
for drone in fleet { components.append(drone) }
for sensor in sensors { components.append(sensor) }
print(diagnosticsReport(components))


// MARK: Level 5 · Shared Behaviour

// 5.1 · default diagnose() + the single home of the Health Rule
extension Diagnosable {
    func diagnose() -> String {
        "\(componentID): code \(statusCode)"
    }

    func code(forCharge charge: Int) -> Int {
        if charge < 20 { return 2 }      // critical
        if charge < 50 { return 1 }      // warning
        return 0                         // nominal
    }
}

// 5.2 · the beacon you cannot edit
extension LegacyBeacon: Diagnosable {
    var componentID: String { name }
    var statusCode: Int { code(forCharge: signalStrength) }
    func diagnose() -> String {
        "[LEGACY] \(name): signal \(signalStrength), code \(statusCode)"
    }
}

components.append(beacon)
print(diagnosticsReport(components))

var codeSum = 0
for component in components { codeSum += component.statusCode }
let D = codeSum
print("D =", D)

// 5.3
extension Int {
    var powerBar: String {
        let filled = Swift.max(0, Swift.min(10, self / 10))
        return String(repeating: "#", count: filled) + String(repeating: ".", count: 10 - filled)
    }
}

print(42.powerBar, (-5).powerBar, 250.powerBar)


// MARK: Level 6 · Incident Reports
// Two of these do not compile. Two compile and lie.
// For each: expectation, actual behaviour, the language rule, the fix.

// Report 1 (does not compile)
// Expected: PatchDrone works for 30 units.
// Error: "overriding declaration requires an 'override' keyword".
// Rule: a subclass must mark every override explicitly, so you can't replace a parent's method by accident.
// Fix:
final class PatchDrone: Drone {
    override func performTask() -> Int { 30 }
}

// Report 2 (does not compile)
// Expected: a welder variant that returns 999.
// Error: "cannot inherit from a final class 'WelderDrone'" (and runOnce is also final in Drone).
// Rule: `final` forbids subclassing / overriding, so the shift ritual can't be bypassed.
// Fix: subclass Drone, change the work (not the ritual):
final class HeavyWelder: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 999 }
}

// Report 3 (does not compile)
// Expected: call weldSeam() on the first fleet element.
// Error: "value of type 'Drone' has no member 'weldSeam'". The static type is Drone, the compiler only knows Drone's members.
// Rule: you see only what the declared type has; for a subclass member ask at runtime with a conditional cast.
// as? returns an optional because the element may not be a WelderDrone at all (then the cast gives nil).
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
if let welder = first as? WelderDrone {
    print(welder.weldSeam())
}

// Report 4 (compiles and lies)
// Expected: "thruster T-1". Actual: "generic component".
// label() is NOT a requirement of the protocol, it exists only in the extension. Calls through
// a [Labelled] are bound statically to the extension's version (static dispatch).
// Rule: only protocol requirements go through the witness table (dynamic dispatch), so the concrete type's own method wins only for requirements.
// Fix: add `func label() -> String` to the protocol itself.
protocol Labelled {
    var componentID: String { get }
    func label() -> String                              // <- одна строка меняет вывод
}
extension Labelled {
    func label() -> String { "generic component" }      // теперь это просто значение по умолчанию
}
struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}
let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())                                 // thruster T-1

// MARK: Finale · Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")


// MARK: Bonus

// Two ways to forbid using Drone directly; a protocol-based redesign;
// two or three sentences comparing them.
// 1a. Runtime: crash if someone creates a bare Drone (put it in Drone.init):
//     precondition(type(of: self) != Drone.self, "Drone is abstract, use a subclass")
// 1b. Compile time: make the base a protocol, then it cannot be instantiated at all.

// 2. Protocol-based fleet with a struct:
protocol Worker: Diagnosable {
    var id: String { get }
    var charge: Int { get set }
    var powerCost: Int { get }
    var workUnits: Int { get }
}
extension Worker {
    var componentID: String { id }
    var statusCode: Int { code(forCharge: charge) }
    mutating func runOnce() -> Int {
        guard charge >= powerCost else { return 0 }
        charge -= powerCost
        return workUnits
    }
}
struct WelderUnit: Worker {
    let id: String
    var charge: Int
    let powerCost = 25
    let workUnits = 40
}
var unit = WelderUnit(id: "W-X", charge: 60)
print(unit.runOnce(), unit.charge)                      // 40 35


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` protocol requirement without the
    keyword, while a struct must write it?
 A class is a reference type. It can change its data without mutating.
 A struct is a value type. It needs mutating to change its data.

 2. One thing inheritance does that protocols cannot, and one thing
    protocols do that inheritance cannot:
 Inheritance: A class can get code and data from a parent class.
 Protocols: A struct, class, or enum can use many protocols.

 3. What does `final` prevent, and what did it protect in runOnce()?
 final stops other classes from overriding a method.
 In runOnce(), it protects the method from being changed by subclasses.

 4. In Report 4, why did the protocol extension's method win?
 Because the method was only in the protocol extension, not in the protocol requirements.
 Swift uses the extension method, not the class method.

*/
