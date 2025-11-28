//
//  PaceCalculatorApp.swift
//  PaceCalculator
//
//  Created by Paul Calver on 23/11/2025.
//

import SwiftUI
import StoreKit
import UIKit

@main
struct PaceCalculatorApp: App {
    // Hook in a UIKit AppDelegate so we can control orientation
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(Color.appBackgroundColor)
                .ignoresSafeArea()
                .onAppear { startStoreKitListener() }
                .tint(.black)
                .preferredColorScheme(.light)
        }
    }
}

// MARK: - AppDelegate for orientation

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        // Lock app to portrait only
        return .portrait
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
}

// MARK: - StoreKit Transaction Listener

private func startStoreKitListener() {
    Task.detached {
        for await update in Transaction.updates {
            do {
                let transaction = try await checkVerified(update)
                await transaction.finish()
                print("Finished StoreKit transaction:", transaction.id)
            } catch {
                print("Transaction verification failed:", error)
            }
        }
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
