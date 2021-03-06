//
//  FileGateApp.swift
//  FileGate
//
//  Created by Alex White on 4/20/22.
//

import SwiftUI

@main
struct FileGateApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
