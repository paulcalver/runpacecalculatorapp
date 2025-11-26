//
//  Untitled.swift
//  PaceCalculator
//
//  Created by Paul Calver on 23/11/2025.
//
import SwiftUI
import Combine

enum DistanceUnit: String, CaseIterable, Identifiable {
    case kilometers = "km"
    case miles = "mi"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .kilometers: return "Kilometers"
        case .miles: return "Miles"
        }
    }
    
    // how many km in one unit
    var distanceFactorToKm: Double {
        switch self {
        case .kilometers: return 1.0
        case .miles: return 1.60934
        }
    }
}

class PaceViewModel: ObservableObject {
    // core inputs (stored in km + seconds)
    @Published var distance: Double = 0 { didSet { if distance != oldValue { recomputeUsingStoredPaceIfPossible() } } }
    @Published var duration: TimeInterval = 0 { didSet { if duration != oldValue { recomputeUsingStoredPaceIfPossible() } } }
    
    /// Global unit for distance / pace / speed
    @Published var unit: DistanceUnit = .kilometers {
        didSet {
            // Keep the displayed split interval value the same when units change
            // (e.g., 1.0 km -> 1.0 mi). Capture the old displayed value first.
            let oldDisplayedSplit = splitIntervalInSplitUnit // uses old splitUnit
            // Update the splits unit to match the new global unit
            splitUnit = unit
            // Recompute the base km value so that the displayed value remains the same in the new unit
            splitIntervalKm = oldDisplayedSplit * splitUnit.distanceFactorToKm
        }
    }
    
    /// Unit used ONLY for splits
    @Published var splitUnit: DistanceUnit = .kilometers
    
    /// Split interval stored in km internally
    @Published var splitIntervalKm: Double = 1.0
    
    /// Stores the last entered pace in seconds per km (base). Optional so pace can be entered before distance/time.
    @Published private var storedPaceSecondsPerKm: Double?
    /// Stores the last entered speed in km/h (base). Optional so speed can be entered before distance/time.
    @Published private var storedSpeedKmh: Double?
    private var isResetting = false
    
    enum ActiveField {
        case distance, duration
    }
    var activeField: ActiveField = .distance
    
    // MARK: - Conversions
    
    var distanceInSelectedUnit: Double {
        get { distance / unit.distanceFactorToKm }
        set { distance = newValue * unit.distanceFactorToKm }
    }
    
    var formattedDistance: String {
        distanceInSelectedUnit == 0 ? "0.00" :
        String(format: "%.2f", distanceInSelectedUnit)
    }
    
    var formattedDuration: String {
        let rounded = Int(duration.rounded())
        guard rounded > 0 else { return "00:00:00" }
        let hrs = rounded / 3600
        let mins = (rounded % 3600) / 60
        let secs = rounded % 60
        return String(format: "%02d:%02d:%02d", hrs, mins, secs)
    }
    
    /// Split interval in the splits unit (km or miles, separately from main unit)
    var splitIntervalInSplitUnit: Double {
        get { splitIntervalKm / splitUnit.distanceFactorToKm }
        set { splitIntervalKm = newValue * splitUnit.distanceFactorToKm }
    }
    
    var splitIntervalString: String {
        guard splitIntervalInSplitUnit > 0 else { return "0.0" }
        return String(format: "%.1f", splitIntervalInSplitUnit)
    }
    
    // MARK: - Pace & Speed
    
    /// Pace in **seconds per km** (base unit)
    var paceSecondsPerKm: Double? {
        if distance > 0, duration > 0 {
            return duration / distance
        }
        // Fallback to stored pace if user entered pace first
        if let stored = storedPaceSecondsPerKm, stored > 0 {
            return stored
        }
        return nil
    }
    
    /// Pace in **seconds per selected unit** (km or mile)
    var paceSecondsPerSelectedUnit: Double? {
        guard let perKm = paceSecondsPerKm else { return nil }
        
        switch unit {
        case .kilometers:
            // sec per km
            return perKm
        case .miles:
            // sec per mile = sec per km × km per mile
            return perKm * unit.distanceFactorToKm
        }
    }
    
    var paceString: String {
        guard let pace = paceSecondsPerSelectedUnit else {
            return "0:00 /\(unit.rawValue)"
        }
        let total = Int(pace.rounded())
        let mins = total / 60
        let secs = total % 60
        return String(format: "%d:%02d /%@", mins, secs, unit.rawValue)
    }
    
    /// Speed in selected unit per hour
    var speedPerSelectedUnit: Double? {
        // If we can derive from distance and duration, prefer that
        if duration > 0, distance > 0 {
            let hours = duration / 3600
            let dist = distanceInSelectedUnit
            return dist / hours
        }
        // Fallback to stored speed if user entered speed first
        if let kmh = storedSpeedKmh, kmh > 0 {
            switch unit {
            case .kilometers:
                return kmh
            case .miles:
                return kmh / unit.distanceFactorToKm // convert km/h -> mi/h
            }
        }
        return nil
    }
    
    var speedString: String {
        guard let speed = speedPerSelectedUnit else {
            return "0.0 \(unit.rawValue)/h"
        }
        return String(format: "%.1f %@/h", speed, unit.rawValue)
    }
    
    /// Indicates whether the current visible pace comes from a direct user entry
    /// rather than being derived from distance and duration.
    var isPaceEnteredDirectly: Bool {
        let hasDerived = distance > 0 && duration > 0
        return !hasDerived && (storedPaceSecondsPerKm ?? 0) > 0
    }

    /// Indicates whether the current visible speed comes from a direct user entry
    /// rather than being derived from distance and duration.
    var isSpeedEnteredDirectly: Bool {
        let hasDerived = distance > 0 && duration > 0
        return !hasDerived && (storedSpeedKmh ?? 0) > 0
    }
    
    /// Called when the user inputs a pace value (in seconds per km or per mile)
    func setPacePerSelectedUnit(_ seconds: TimeInterval) {
        guard seconds > 0 else { return }

        // Convert to base pace (sec per km) and store it so pace can exist without distance
        switch unit {
        case .kilometers:
            storedPaceSecondsPerKm = seconds
        case .miles:
            storedPaceSecondsPerKm = seconds / unit.distanceFactorToKm
        }

        guard let pacePerKm = storedPaceSecondsPerKm else { return }

        // If distance is known, compute duration
        if distance > 0 {
            duration = (pacePerKm * distance).rounded()
        }
        // Else if duration is known, compute distance
        else if duration > 0 {
            let km = duration / pacePerKm
            if km.isFinite, km > 0 {
                distance = km
            }
        }
    }
    
    /// Called when the user inputs a speed value (in km/h or mi/h)
    func setSpeedPerSelectedUnit(_ speed: Double) {
        guard speed > 0 else { return }

        // Convert incoming speed to base km/h and store it
        switch unit {
        case .kilometers:
            storedSpeedKmh = speed
        case .miles:
            storedSpeedKmh = speed * unit.distanceFactorToKm // mi/h -> km/h
        }

        guard let kmh = storedSpeedKmh else { return }

        // If distance is known, compute duration
        if distance > 0 {
            let hours = (distance / kmh)
            duration = (hours * 3600).rounded()
        }
        // Else if duration is known, compute distance
        else if duration > 0 {
            let hours = duration / 3600
            let km = kmh * hours
            if km.isFinite, km > 0 { distance = km }
        }
    }
    
    /// Recompute the missing variable if we have a stored pace and one of distance/duration changed.
    func recomputeUsingStoredPaceIfPossible() {
        if isResetting { return }

        // Try with stored pace first
        if let pacePerKm = storedPaceSecondsPerKm, pacePerKm > 0 {
            if distance > 0 && (duration <= 0) {
                duration = (pacePerKm * distance).rounded()
                return
            } else if duration > 0 && (distance <= 0) {
                let km = duration / pacePerKm
                if km.isFinite, km > 0 { distance = km }
                return
            }
        }

        // If pace wasn't applicable, try with stored speed
        if let kmh = storedSpeedKmh, kmh > 0 {
            if distance > 0 && (duration <= 0) {
                let hours = distance / kmh
                duration = (hours * 3600).rounded()
                return
            } else if duration > 0 && (distance <= 0) {
                let hours = duration / 3600
                let km = kmh * hours
                if km.isFinite, km > 0 { distance = km }
                return
            }
        }
    }
    
    /// Called when the user inputs a pace (sec per km or mile) and a total duration
    /// This computes and sets the distance (stored in km internally).
    /// - Parameters:
    ///   - paceSecondsPerSelectedUnit: Pace expressed in seconds per selected unit (km or mile depending on `unit`). Must be > 0.
    ///   - duration: Total duration in seconds. Must be > 0.
    func setDistanceFrom(paceSecondsPerSelectedUnit: TimeInterval, duration: TimeInterval) {
        guard paceSecondsPerSelectedUnit > 0, duration > 0 else { return }

        // Convert incoming pace to seconds per km (base)
        let pacePerKm: Double
        switch unit {
        case .kilometers:
            pacePerKm = paceSecondsPerSelectedUnit
        case .miles:
            // sec per mile -> sec per km
            pacePerKm = paceSecondsPerSelectedUnit / unit.distanceFactorToKm
        }

        // distance (in km) = duration (sec) / (sec per km)
        let km = duration / pacePerKm
        guard km.isFinite, km > 0 else { return }

        // Set model values (round duration to whole seconds like other setters)
        self.duration = duration.rounded()
        self.distance = km
    }

    /// Convenience to set distance from pace given as minutes and seconds per selected unit.
    /// For example, 4 min 30 sec per km with a 45-minute duration.
    func setDistanceFrom(paceMinutes: Int, paceSeconds: Int, totalDurationSeconds: TimeInterval) {
        let totalPaceSeconds = TimeInterval(max(0, paceMinutes) * 60 + max(0, paceSeconds))
        setDistanceFrom(paceSecondsPerSelectedUnit: totalPaceSeconds, duration: totalDurationSeconds)
    }
    
    // MARK: - Predicted / Equivalent times (Riegel)

    /// Uses the Riegel formula: T2 = T1 * (D2/D1)^k
    /// where k ≈ 1.06 for typical road running.
    func predictedEquivalentTime(for targetDistanceKm: Double) -> String {
        // Need a valid reference performance
        guard distance > 0,
              duration > 0,
              targetDistanceKm > 0 else {
            return "--:--"
        }
        
        let baseDistanceKm = distance
        let baseTimeSec = duration
        let exponent = 1.06
        
        let ratio = targetDistanceKm / baseDistanceKm
        let predictedSecDouble = Double(baseTimeSec) * pow(ratio, exponent)
        let predictedSec = Int(predictedSecDouble.rounded())
        
        let hrs = predictedSec / 3600
        let mins = (predictedSec % 3600) / 60
        let s = predictedSec % 60
        
        if hrs > 0 {
            return String(format: "%d:%02d:%02d", hrs, mins, s)
        } else {
            return String(format: "%02d:%02d", mins, s)
        }
    }
    
    /// Returns a formatted time string ("mm:ss" or "h:mm:ss")
    /// for running `distKm` at the current pace.
    func predictedTime(for distKm: Double) -> String {
        guard distKm > 0, let secPerKm = paceSecondsPerKm else {
            return "--:--"
        }

        let totalSec = Int((secPerKm * distKm).rounded())
        let hrs = totalSec / 3600
        let mins = (totalSec % 3600) / 60
        let secs = totalSec % 60

        if hrs > 0 {
            return String(format: "%d:%02d:%02d", hrs, mins, secs)
        } else {
            return String(format: "%02d:%02d", mins, secs)
        }
    }
    
    
    
    // MARK: - Splits
    
    struct SplitRow: Identifiable {
        let id = UUID()
        let distanceDisplay: String   // e.g. "1.0"
        let durationDisplay: String   // e.g. "04:10"
    }
    
    // Splits from 1× interval up to the full distance
    var splitRows: [SplitRow] {
        guard splitIntervalKm > 0,
              distance > 0,
              let _ = paceSecondsPerKm else { return [] }
        
        var rows: [SplitRow] = []
        
        // number of whole intervals that fit in total distance
        let fullIntervals = Int(distance / splitIntervalKm)
        
        // 1×, 2×, 3× ... up to the last whole interval
        if fullIntervals > 0 {
            for n in 1...fullIntervals {
                let distKm = Double(n) * splitIntervalKm
                let distInSplitUnit = distKm / splitUnit.distanceFactorToKm
                let distString = String(format: "%.1f", distInSplitUnit)
                let duration = predictedTime(for: distKm)
                rows.append(SplitRow(distanceDisplay: distString,
                                     durationDisplay: duration))
            }
        }
        
        // If there's a remainder (e.g. 12 km with 5 km splits), add a final row
        let lastFullKm = Double(fullIntervals) * splitIntervalKm
        let remainder = distance - lastFullKm
        if remainder > 0.01 {
            let distKm = distance
            let distInSplitUnit = distKm / splitUnit.distanceFactorToKm
            let distString = String(format: "%.1f", distInSplitUnit)
            let duration = predictedTime(for: distKm)
            rows.append(SplitRow(distanceDisplay: distString,
                                 durationDisplay: duration))
        }
        
        return rows
    }
    
    // MARK: - Reset
    
    func reset() {
        isResetting = true
        // Clear stored pace first so didSet recomputes don't restore values
        storedPaceSecondsPerKm = nil
        storedSpeedKmh = nil
        distance = 0
        duration = 0
        splitIntervalKm = 1.0
        splitUnit = unit   // or .kilometers, up to you
        isResetting = false
    }
}

