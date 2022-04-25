//
//  FileList.swift
//  FileGate
//
//  Created by Alex White on 4/20/22.
//

import SwiftUI
import Foundation

struct FileList: View {
    @State private var fileItems: [FileItem] = []
    @State private var singleSelection: UUID?
    
    var body: some View {
        NavigationView {
            List(fileItems, selection: $singleSelection) {
                Text($0.name)
            }

            if (singleSelection != nil)
            {
                AsyncImage(url: fileItems.first(where: { item in
                    return item.id == singleSelection
                })?.value, transaction: Transaction(animation: .easeIn)) { phase in
                    switch phase {
                    case .empty:
                        Color.purple.opacity(0.1)
                 
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                 
                    case .failure(_):
                        Image(systemName: "exclamationmark.icloud")
                            .resizable()
                            .scaledToFit()
                 
                    @unknown default:
                        Image(systemName: "exclamationmark.icloud")
                    }
                }
                .scaledToFill()
            }
            else if (fileItems.isEmpty) {
                Text("Select a directory")
            }
            else {
                Text("Select an image")
            }
        }
        .toolbar {
            ToolbarItem {
                Button(action: {
                    fileItems = enumerateFiles()
                }) {
                    Label("Open Directory", systemImage: "folder")
                }
            }
        }
    }
}

struct FileList_Previews: PreviewProvider {
    static var previews: some View {
        FileList()
    }
}

struct FileItem: Identifiable, Hashable {
    let name: String
    let value: URL
    let id = UUID()
}

private func enumerateFiles() -> [FileItem]
{
    let fileManager = FileManager.default
    
    let panel = NSOpenPanel()
    panel.canChooseDirectories = true
    panel.canChooseFiles = false
    
    let response = panel.runModal()
    if (response == .OK) {
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: panel.url!, includingPropertiesForKeys: nil,options: [.skipsHiddenFiles,.skipsSubdirectoryDescendants])
            
            return fileURLs.map { return FileItem(name: $0.path, value: $0) }
        }
        catch  {
            print("Error getting files \(error)")
            return []
        }
    }
    
    
   return []
}
