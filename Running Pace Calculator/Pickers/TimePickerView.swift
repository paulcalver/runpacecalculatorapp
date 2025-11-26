import SwiftUI

struct TimePickerView: View {
    var seconds: TimeInterval
    let onCancel: () -> Void
    let onDone: (TimeInterval) -> Void

    @State private var hrs: Int = 0
    @State private var mins: Int = 0
    @State private var secs: Int = 0
    @State private var prewarmPickers: Bool = true

    var body: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 16) {

                    Text("Time")
                        .font(.myInputHeadline)
                        .padding(.top, 12)

                    HStack {
                        // HOURS
                        VStack(spacing: 4) {
                            Picker("", selection: $hrs) {
                                ForEach(0..<10) { i in
                                    Text("\(i) h").tag(i)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .pickerStyle(.wheel)
                        }

                        // MINUTES
                        VStack(spacing: 4) {
                            Picker("", selection: $mins) {
                                ForEach(0..<60) { i in
                                    Text(String(format: "%d min", i)).tag(i)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .pickerStyle(.wheel)
                        }

                        // SECONDS
                        VStack(spacing: 4) {
                            Picker("", selection: $secs) {
                                ForEach(0..<60) { i in
                                    Text(String(format: "%d s", i)).tag(i)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .pickerStyle(.wheel)
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
                            let total = TimeInterval(hrs * 3600 + mins * 60 + secs)
                            onDone(total)
                        }
                    }
                }
            }

            if prewarmPickers {
                HStack {
                    // Hours prewarm
                    Picker("", selection: .constant(0)) {
                        ForEach(0..<10) { i in
                            Text("\(i)")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .pickerStyle(.wheel)

                    // Minutes prewarm
                    Picker("", selection: .constant(0)) {
                        ForEach(0..<60) { i in
                            Text(String(format: "%d", i))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .pickerStyle(.wheel)

                    // Seconds prewarm
                    Picker("", selection: .constant(0)) {
                        ForEach(0..<60) { i in
                            Text(String(format: "%d", i))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .pickerStyle(.wheel)
                }
                .opacity(0.01)
                .allowsHitTesting(false)
                .onAppear {
                    DispatchQueue.main.async {
                        prewarmPickers = false
                    }
                }
            }
        }
        .onAppear { initialise() }
    }

    // MARK: - Initial state

    private func initialise() {
        let total = max(0, Int(seconds))
        hrs = total / 3600
        mins = (total % 3600) / 60
        secs = total % 60
    }
}
