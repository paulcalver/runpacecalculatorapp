import SwiftUI

struct DistancePickerView: View {
    @Binding var unit: DistanceUnit
    var value: Double
    var showPresets: Bool

    let onCancel: () -> Void
    let onDone: (Double) -> Void
    
    let title: String

    @State private var integerPart: Int = 0
    @State private var decimalPart: Int = 0
    @State private var valueInKm: Double = 0

    let presets: [(label: String, km: Double)] = [
        ("5k", 5.0),
        ("10k", 10.0),
        ("Half", 21.097),
        ("Marathon", 42.195)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                Text(title)
                    .font(.myInputHeadline)
                    .padding(.top, 12)

                if showPresets {
                    HStack(spacing: 10) {
                        ForEach(presets, id: \.label) { preset in
                            Button {
                                valueInKm = preset.km
                                updateWheelsFromKm()
                                onDone(valueInKm / unit.distanceFactorToKm)
                            } label: {
                                Text(preset.label)
                                    .font(.subheadline)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(Color(.systemGray5))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }

                HStack {
                    Picker("", selection: $integerPart) {
                        ForEach(0..<101) { i in
                            Text("\(i)").tag(i)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .pickerStyle(.wheel)
                    .onChange(of: integerPart) {
                        updateKmFromWheels()
                    }

                    Picker("", selection: $decimalPart) {
                        ForEach(0..<10) { d in
                            Text(".\(d)").tag(d)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .pickerStyle(.wheel)
                    .onChange(of: decimalPart) {
                        updateKmFromWheels()
                    }

                    Picker("", selection: $unit) {
                        Text("km").tag(DistanceUnit.kilometers)
                        Text("mi").tag(DistanceUnit.miles)
                    }
                    .frame(maxWidth: .infinity)
                    .pickerStyle(.wheel)
                    .onChange(of: unit) {
                        updateWheelsFromKm()
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
                        onDone(valueInKm / unit.distanceFactorToKm)
                    }
                }
            }
        }
        .onAppear { initialise() }
    }

    // MARK: - Helpers

    func initialise() {
        valueInKm = value * unit.distanceFactorToKm
        updateWheelsFromKm()
    }

    func updateKmFromWheels() {
        let combined = Double(integerPart) + Double(decimalPart) / 10
        valueInKm = combined * unit.distanceFactorToKm
    }

    func updateWheelsFromKm() {
        let v = valueInKm / unit.distanceFactorToKm
        integerPart = Int(v)
        decimalPart = Int((v - Double(integerPart)) * 10)
    }
}
