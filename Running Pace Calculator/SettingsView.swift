import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var unit: DistanceUnit
    
    @State private var showUnitSheet = false
    
    // TODO: replace with your real App Store URL when live
    private let appShareURL = URL(string: "https://apps.paulcalver.cc")!
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // Header
                    HStack(alignment: .firstTextBaseline) {
                        Text("Support the App")
                            .font(.myTitle)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Spacer()

                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.myIcon)
                                .foregroundStyle(.primary)
                                .offset(y: 0)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 8)
                    
                   
                    
                    // Support section
//                    Text("A way to say thanks!")
//                        .font(.myHeadline)
//                        .foregroundStyle(.primary)
//                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("If you find this app useful, please consider supporting it by leaving a tip in our tip jar, or sharing with a friend.")
                        .font(.myFootnote)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Tip Jar row
                    NavigationLink(destination: TipJarView()) {
                        HStack(spacing: 12) {
                            Text("Tip Jar")
                                .font(.myInput)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.myCaption)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    
                    // Share app row
                    ShareLink(
                        item: appShareURL,
                        message: Text("Check out Running Pace Calculator – a simple pace & race prediction app.")
                    ) {
                        HStack(spacing: 12) {
                            Text("Share with a friend")
                                .font(.myInput)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                                .font(.myCaption)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    
                    // Website info
                    Text("For more info, or to get in touch, check out our website: https://apps.paulcalver.co")
                        .font(.myFootnote)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .toolbar(.hidden, for: .navigationBar)
        .background(
            Color(hue: 120.0/360.0, saturation: 0.6, brightness: 0.6)
                .ignoresSafeArea()
        )
        .sheet(isPresented: $showUnitSheet) {
            VStack(spacing: 16) {
                Text("Default Metrics")
                    .font(.myInputHeadline)
                    .padding(.top, 12)
                
                ForEach(DistanceUnit.allCases) { option in
                    Button {
                        unit = option
                        showUnitSheet = false
                    } label: {
                        HStack {
                            Text(option.displayName)
                            Spacer()
                            if option == unit {
                                Image(systemName: "checkmark")
                            }
                        }
                        .font(.myInputHeadline)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
            }
            .padding()
            .presentationDetents([.height(260)])
            .presentationDragIndicator(.visible)
        }
    }
}
