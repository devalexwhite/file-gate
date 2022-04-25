//
//  FileGateIosApp.swift
//  FileGateIos
//
//  Created by Alex White on 4/22/22.
//

import SwiftUI

@main
struct FileGateIosApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
