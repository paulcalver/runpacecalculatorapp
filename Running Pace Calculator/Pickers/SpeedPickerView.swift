import SwiftUI

struct SpeedPickerView: View {
    @Binding var unit: DistanceUnit       // updates the app-wide unit
    var value: Double                     // speed in selected unit
    let onCancel: () -> Void
    let onDone: (Double) -> Void

    @State private var integerPart: Int = 0
    @State private var decimalPart: Int = 0
    @State private var selectedUnit: DistanceUnit
    @State private var internalValue: Double = 0

    init(
        unit: Binding<DistanceUnit>,
        value: Double,
        onCancel: @escaping () -> Void,
        onDone: @escaping (Double) -> Void
    ) {
        self._unit = unit
        self.value = value
        self.onCancel = onCancel
        self.onDone = onDone

        _selectedUnit = State(initialValue: unit.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                Text("Speed")
                    .font(.myInputHeadline)
                    .padding(.top, 12)

                HStack {

                    // Whole number wheel
                    Picker("", selection: $integerPart) {
                        ForEach(0..<51) { i in
                            Text("\(i)").tag(i)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .pickerStyle(.wheel)
                    .onChange(of: integerPart) {
                        updateValue()
                    }

                    // Decimal wheel
                    Picker("", selection: $decimalPart) {
                        ForEach(0..<10) { d in
                            Text(".\(d)").tag(d)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .pickerStyle(.wheel)
                    .onChange(of: decimalPart) {
                        updateValue()
                    }

                    // Unit wheel
                    Picker("", selection: $selectedUnit) {
                        Text("km/h").tag(DistanceUnit.kilometers)
                        Text("mi/h").tag(DistanceUnit.miles)
                    }
                    .frame(maxWidth: .infinity)
                    .pickerStyle(.wheel)
                    .onChange(of: selectedUnit) {
                        convertSpeed(to: selectedUnit)
                        unit = selectedUnit     // update global unit
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
                        onDone(internalValue)
                    }
                }
            }
        }
        .onAppear { initialise() }
    }

    // MARK: - Setup

    private func initialise() {
        internalValue = max(0, value)
        integerPart = Int(internalValue)
        decimalPart = Int((internalValue - Double(integerPart)) * 10)
    }

    private func updateValue() {
        internalValue = Double(integerPart) + Double(decimalPart) / 10.0
    }

    // MARK: - Unit Conversion (km/h <-> mph)

    private func convertSpeed(to newUnit: DistanceUnit) {
        guard newUnit != unit else { return }

        // Convert current speed to km/h (base)
        let kmhValue: Double = {
            switch unit {
            case .kilometers:
                return internalValue
            case .miles:
                return internalValue * DistanceUnit.miles.distanceFactorToKm
            }
        }()

        // Convert base -> target
        let newValue: Double = {
            switch newUnit {
            case .kilometers:
                return kmhValue
            case .miles:
                return kmhValue / DistanceUnit.miles.distanceFactorToKm
            }
        }()

        internalValue = newValue
        integerPart = Int(newValue)
        decimalPart = Int((newValue - Double(integerPart)) * 10)
    }
}
