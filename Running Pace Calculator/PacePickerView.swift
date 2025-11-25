import SwiftUI

struct PacePickerView: View {
    /// Input pace in seconds per selected unit (km or mi)
    var secondsPerUnit: TimeInterval
    @Binding var unit: DistanceUnit   // ← this updates the app's unit

    let onCancel: () -> Void
    let onDone: (TimeInterval) -> Void

    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    @State private var selectedUnit: DistanceUnit

    init(
        secondsPerUnit: TimeInterval,
        unit: Binding<DistanceUnit>,
        onCancel: @escaping () -> Void,
        onDone: @escaping (TimeInterval) -> Void
    ) {
        self.secondsPerUnit = secondsPerUnit
        self._unit = unit
        self.onCancel = onCancel
        self.onDone = onDone

        _selectedUnit = State(initialValue: unit.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                Text("Pace")
                    .font(.myInputHeadline)
                    .padding(.top, 12)

                // Wheels: minutes | seconds | unit
                HStack {

                    // Minutes wheel
                    VStack(spacing: 4) {
                        Picker("", selection: $minutes) {
                            ForEach(0..<30) { m in
                                Text(String(format: "%02d", m)).tag(m)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .pickerStyle(.wheel)
                    }

                    // Seconds wheel
                    VStack(spacing: 4) {
                        Picker("", selection: $seconds) {
                            ForEach(0..<60) { s in
                                Text(String(format: "%02d", s)).tag(s)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .pickerStyle(.wheel)
                    }

                    // Unit wheel
                    VStack(spacing: 4) {
                        Picker("", selection: $selectedUnit) {
                            Text("/km").tag(DistanceUnit.kilometers)
                            Text("/mi").tag(DistanceUnit.miles)
                        }
                        .frame(maxWidth: .infinity)
                        .pickerStyle(.wheel)
                        .onChange(of: selectedUnit) {
                            convertPace(to: selectedUnit)
                            unit = selectedUnit
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.bottom, 12)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        let finalSeconds = TimeInterval(minutes * 60 + seconds)
                        onDone(finalSeconds)
                    }
                }
            }
        }
        .onAppear { initialise() }
    }

    // MARK: - Setup

    private func initialise() {
        let total = max(0, Int(secondsPerUnit))
        minutes = total / 60
        seconds = total % 60
    }

    // MARK: - Unit Conversion

    private func convertPace(to newUnit: DistanceUnit) {
        guard newUnit != unit else { return }

        // Convert current pace to sec/km (base)
        let secPerKm: Double = {
            switch unit {
            case .kilometers:
                return Double(minutes * 60 + seconds)
            case .miles:
                return Double(minutes * 60 + seconds) / DistanceUnit.miles.distanceFactorToKm
            }
        }()

        // Convert base → target
        let newSeconds: Double = {
            switch newUnit {
            case .kilometers:
                return secPerKm
            case .miles:
                return secPerKm * DistanceUnit.miles.distanceFactorToKm
            }
        }()

        let total = Int(newSeconds)
        minutes = total / 60
        seconds = total % 60
    }
}
