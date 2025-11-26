import SwiftUI
import UIKit

struct ContentView: View {
    private func setWindowBackgroundToMatchApp() {
        let uiColor = UIColor(hue: CGFloat(120.0/360.0), saturation: 0.6, brightness: 0.6, alpha: 1.0)
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .forEach { scene in
                scene.windows.forEach { $0.backgroundColor = uiColor }
            }
    }

    @StateObject private var vm = PaceViewModel()
    
    @State private var showingSettings = false
    @State private var path: [Route] = []
    
    @State private var activeSheet: ActiveSheet?
    
    private enum Route: Hashable {
        case settings
    }
    
    private enum ActiveSheet: Identifiable {
        case distance
        case time
        case split
        case pace
        case speed
        
        var id: Int { hashValue }
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color(hue: 120.0/360.0, saturation: 0.6, brightness: 0.6)
                    .ignoresSafeArea(.all)
                
                // MAIN CONTENT
                ScrollViewReader { proxy in
                    ScrollView {
                        Color.clear.frame(height: 0).id("top")
                        VStack(spacing: 12) {
                            
                            // HEADER
                            HStack(alignment: .firstTextBaseline) {
                                Text("Running Pace\nCalculator")
                                    .font(.myTitle)
                                    .foregroundStyle(.primary)
                                    .lineLimit(2)
                                    //.minimumScaleFactor(0.8)
                                    .multilineTextAlignment(.leading)
                                    .alignmentGuide(.firstTextBaseline) { d in d[.top] }

                                Spacer()
                                
                                Image("logo") // replace with your asset name
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .alignmentGuide(.firstTextBaseline) { d in d[.top] }
                                    .accessibilityHidden(true)
                                    .offset(y: -6)
                            }
                            .padding(.top, 24)
                            .padding(.bottom, 8)

                            
                            // ---------------------------------------------------
                            // Distance
                            // ---------------------------------------------------
                            RowButton(
                                label: nil,
                                value: "\(vm.formattedDistance) \(vm.unit.rawValue)",
                                systemImage: "ruler"
                            ) {
                                vm.activeField = .distance
                                activeSheet = .distance
                            }
                            
                            // ---------------------------------------------------
                            // Time
                            // ---------------------------------------------------
                            RowButton(
                                label: nil,
                                value: vm.formattedDuration,
                                systemImage: "clock"
                            ) {
                                vm.activeField = .duration
                                activeSheet = .time
                            }
                            
                            // ---------------------------------------------------
                            // Pace
                            // ---------------------------------------------------
                            RowButton(
                                label: nil,
                                value: vm.paceString,
                                systemImage: "figure.run"
                            ) {
                                activeSheet = .pace
                            }
                            
                            // ---------------------------------------------------
                            // Speed
                            // ---------------------------------------------------
                            RowButton(
                                label: nil,
                                value: vm.speedString,
                                systemImage: "speedometer"
                            ) {
                                activeSheet = .speed
                            }
                            
                            // ---------------------------------------------------
                            // Splits every
                            // ---------------------------------------------------
                            RowButton(
                                label: nil,
                                value: "\(vm.splitIntervalString) \(vm.splitUnit.rawValue)",
                                systemImage: "line.3.horizontal.decrease"
                            ) {
                                activeSheet = .split
                            }
                            
                            
                            // RESET BUTTON
                            Button {
                                vm.reset()
                                withAnimation { proxy.scrollTo("top", anchor: .top) }
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Reset")
                                }
                                .font(.myInput)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.black)
                                )
                            }
                            .padding(.top, 0)
                            
                            
                            // MARK: - Splits & Predictions
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Splits")
                                    .font(.myHeadline)
                                
                                if vm.splitRows.isEmpty {
                                    Text("Enter a distance and pace (or time) to see splits.")
                                        .font(.myCaption)
                                        .foregroundStyle(.secondary)
                                } else {
                                    HStack(alignment: .top, spacing: 40) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(vm.splitUnit == .kilometers ? "Km" : "Mi")
                                                .font(.myHeadline)
                                                .foregroundStyle(.primary)
                                            ForEach(vm.splitRows) { row in
                                                Text(row.distanceDisplay)
                                            }
                                        }

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Time")
                                                .font(.myHeadline)
                                                .foregroundStyle(.primary)
                                            ForEach(vm.splitRows) { row in
                                                Text(row.durationDisplay)
                                            }
                                        }

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Halfway (\(halfwayDistanceString())) Split")
                                                .font(.myHeadline)
                                                .foregroundStyle(.primary)
                                            Text(halfwayTimeString(vm.duration))
                                        }
                                    }
                                    .font(.myCaption)
                                }
                                
                                Text("Predictive Equivalents")
                                    .font(.myHeadline)
                                    .padding(.top, 8)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("5k – \(vm.predictedEquivalentTime(for: 5))")
                                    Text("10k – \(vm.predictedEquivalentTime(for: 10))")
                                    Text("Half Marathon – \(vm.predictedEquivalentTime(for: 21.097))")
                                    Text("Marathon – \(vm.predictedEquivalentTime(for: 42.195))")
                                }
                                .font(.myCaption)
                                .foregroundStyle(.primary)
                                Text("Calculated using the Riegel Formula, based on your selected pace and distance combination.")
                                    .font(.myCaption)
                                    .foregroundStyle(.secondary)
                                    //.padding(.top, 8)
                                Text("Support the App")
                                    .font(.myHeadline)
                                    .padding(.top, 8)
                                Button {
                                    path.append(.settings)
                                } label: {
                                    Image(systemName: "chevron.right.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 32, height: 32)
                                        .foregroundStyle(.primary)
                                        .padding(.vertical, 8)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            
                            .frame(maxWidth: .infinity, alignment: .leading)   // <-- key line
                                                                
                            .padding(.top, 8)
                            .padding(.bottom, 24)
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)    // << bonus-tip alignment
                        .padding(.horizontal, 24)                           // << double border left/right
                        .padding(.vertical, 20)
                    }
                }
            }
            
            
            .background(
                Color(hue: 120.0/360.0, saturation: 0.6, brightness: 0.6)
                    .ignoresSafeArea(.all)
            )
            .onAppear { setWindowBackgroundToMatchApp() }
            
            
            // NAV DESTINATION
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .settings:
                    InfoView(unit: $vm.unit)
                        .navigationTitle("Info")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            
            
            // MARK: - Unified sheet for all pickers
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .distance:
                    DistancePickerView(
                        unit: $vm.unit,
                        value: vm.distanceInSelectedUnit,
                        showPresets: true,
                        onCancel: { activeSheet = nil },
                        onDone: { newValue in
                            vm.distanceInSelectedUnit = newValue
                            activeSheet = nil
                        },
                        title: "Distance"
                    )
                    .presentationDetents([.height(340)])
                    .presentationContentInteraction(.scrolls)
                    .presentationDragIndicator(.hidden)
                    
                case .time:
                    TimePickerView(
                        seconds: vm.duration,
                        onCancel: { activeSheet = nil },
                        onDone: { newSeconds in
                            vm.duration = newSeconds
                            activeSheet = nil
                        }
                    )
                    .presentationDetents([.height(340)])
                    .presentationContentInteraction(.scrolls)
                    .presentationDragIndicator(.hidden)
                    
                case .split:
                    DistancePickerView(
                        unit: $vm.splitUnit,
                        value: vm.splitIntervalInSplitUnit,
                        showPresets: false,
                        onCancel: { activeSheet = nil },
                        onDone: { newValue in
                            vm.splitIntervalInSplitUnit = max(newValue, 0.1)
                            activeSheet = nil
                        },
                        title: "Split Distance"
                    )
                    .presentationDetents([.height(340)])
                    .presentationContentInteraction(.scrolls)
                    .presentationDragIndicator(.hidden)
                    
                case .pace:
                    PacePickerView(
                        secondsPerUnit: vm.paceSecondsPerSelectedUnit ?? 0,
                        unit: $vm.unit,
                        onCancel: { activeSheet = nil },
                        onDone: { newSeconds in
                            vm.setPacePerSelectedUnit(newSeconds)
                            activeSheet = nil
                        }
                    )
                    .presentationDetents([.height(340)])
                    .presentationContentInteraction(.scrolls)
                    .presentationDragIndicator(.hidden)
                    
                case .speed:
                    SpeedPickerView(
                        unit: $vm.unit,
                        value: vm.speedPerSelectedUnit ?? 10.0,
                        onCancel: { activeSheet = nil },
                        onDone: { newSpeed in
                            vm.setSpeedPerSelectedUnit(newSpeed)
                            activeSheet = nil
                        }
                    )
                    .presentationDetents([.height(340)])
                    .presentationContentInteraction(.scrolls)
                    .presentationDragIndicator(.hidden)
                }
            }
            .presentationBackground(.clear)
        }
    }
    
    private func halfwayTimeString(_ totalSeconds: Double) -> String {
        let half = max(totalSeconds / 2, 0)
        let hours = Int(half) / 3600
        let minutes = (Int(half) % 3600) / 60
        let seconds = Int(half) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    private func halfwayDistanceString() -> String {
        let total = vm.distanceInSelectedUnit
        let half = total / 2
        let formatted = String(format: "%.1f", half)
        return "\(formatted) \(vm.unit.rawValue)"
    }
    
    // MARK: - Row view
    
    struct RowButton: View {
        let label: String?
        let value: String
        let systemImage: String
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 12) {
                    Image(systemName: systemImage)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if let label, !label.isEmpty {
                            Text(label)
                                .font(.myInput)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text(value)
                            .font(.myInput)
                            .foregroundStyle(.primary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.myInput)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
    }
}

