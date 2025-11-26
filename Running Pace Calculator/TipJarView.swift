import SwiftUI
import StoreKit
import Combine

// MARK: - ViewModel

@MainActor
class TipJarViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var message: String?
    @Published var hasTipped = false
    
    let productIDs: [String] = ["tip_small", "tip_medium", "tip_large"]
    
    func load() async {
        isLoading = true
        message = nil
        do {
            let loadedProducts = try await Product.products(for: productIDs)
            products = loadedProducts.sorted { $0.priceDecimal < $1.priceDecimal }
            
            if products.isEmpty {
                message = "No tip options returned. Check StoreKit configuration."
            }
        } catch {
            message = "Failed to load tip options: \(error.localizedDescription)"
            products = []
        }
        isLoading = false
    }
    
    func purchase(_ product: Product) async {
        message = nil
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                
                hasTipped = true
                message = "Thank you for your tip!"
                
            case .userCancelled:
                message = nil
                
            case .pending:
                message = "Purchase pending…"
                
            @unknown default:
                message = "Unknown purchase result."
            }
            
        } catch {
            message = "Purchase failed: \(error.localizedDescription)"
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
}

private extension Product {
    var priceDecimal: Decimal { price }
}


// MARK: - View

struct TipJarView: View {
    @StateObject private var vm = TipJarViewModel()
    
    var body: some View {
        ZStack {
            // Full green background
            Color(hue: 120.0 / 360.0, saturation: 0.6, brightness: 0.6)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    
                    // TITLE
                    Text("Tip Jar")
                        .font(.myTitle)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 24)       // MATCHES SETTINGS + CONTENT
                    
                    
                    // LOADING
                    if vm.isLoading {
                        ProgressView()
                    }
                    
                    // SUCCESS MESSAGE
                    else if vm.hasTipped, let message = vm.message {
                        Text(message)
                            .font(.myTitle)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 8)
                    }
                    
                    // TIP OPTIONS
                    else {
                        if vm.products.isEmpty {
                            Text(vm.message ?? "Tips are not available right now.")
                                .font(.myCaption)
                                .multilineTextAlignment(.center)
                                .padding(.top, 8)
                        } else {
                            ForEach(vm.products, id: \.id) { product in
                                Button {
                                    Task { await vm.purchase(product) }
                                } label: {
                                    HStack {
                                        Text(product.displayName)
                                        Spacer()
                                        Text(product.displayPrice)
                                            .foregroundStyle(.primary)
                                    }
                                    .font(.myInput)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            if let message = vm.message {
                                Text(message)
                                    .font(.myCaption)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 8)
                            }
                        }
                    }
                    
                    Spacer(minLength: 24)
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)    // MATCHES MAIN APP BORDER
                .padding(.vertical, 10)
            }
        }
        .task {
            await vm.load()
        }
        .toolbarBackground(.clear, for: .navigationBar)
    }
}

