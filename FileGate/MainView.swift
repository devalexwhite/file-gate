//
//  MainView.swift
//  FileGate
//
//  Created by Alex White on 4/22/22.
//

import SwiftUI
import CoreLocation

struct Photo: Hashable {
    var id: Int
    
    let filename: String
    let url: URL
    var width: Int? = nil
    var height: Int? = nil
    var colorMode: String? = nil
    var latitude: Double? = nil
    var longitude: Double? = nil
}

struct MainView: View {
    @State public var photos: [Photo] = []
    @State private var outputDirectory: URL? = nil

    
    private var maxId: Int {
        return photos.map { $0.id }.max() ?? 0
    }
    
    private func getCardWidth(_ geometry: GeometryProxy, id: Int) -> CGFloat {
        let offset: CGFloat = CGFloat(photos.count - 1 - id) * 10
        return geometry.size.width - offset
    }
    
    private func getCardOffset(_ geometry: GeometryProxy, id: Int) -> CGFloat {
        return CGFloat(photos.count - 1 - id) * 10
    }
    
    private func removePhoto(photo: Photo, keep: Bool = false) -> Void
    {
        self.photos.removeAll(where: { $0.id == photo.id })
        
        if keep == true {
            let fileManager = FileManager.default
            let dest = outputDirectory!.absoluteURL.appendingPathComponent(photo.filename)
            do {
                try fileManager.copyItem(at: photo.url.absoluteURL, to: dest.absoluteURL)
            }
            catch {
                
            }
        }
    }
    
    private func openDirectory() -> [Photo]
    {
        let fileManager = FileManager.default
        
        // Get the input directory
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.showsHiddenFiles = false
        openPanel.allowedContentTypes = [.image]
        
        var openPanelResult = openPanel.runModal()
        
        if (openPanelResult == .OK && openPanel.url != nil)
        {
            // Get the output directory
            let inputDirectory = openPanel.url
            
            openPanelResult = openPanel.runModal()
            
            if (openPanelResult == .OK && openPanel.url != nil) {
                outputDirectory = openPanel.url?.absoluteURL
                
                do {
                    var fileURLs = try fileManager.contentsOfDirectory(at: inputDirectory!, includingPropertiesForKeys: nil,options: [.skipsHiddenFiles,.skipsSubdirectoryDescendants])
                    
                    fileURLs = fileURLs.filter {
                        return ["jpeg", "png", "jpg", "bmp", "tiff"].contains($0.pathExtension)
                    }
                    
                    return fileURLs.enumerated().map { (index, fileUrl) in
                        let data = NSData(contentsOf: fileUrl.absoluteURL)!
                        let source = CGImageSourceCreateWithData(data as CFData, nil)!
                        let metadata = NSDictionary(dictionary: CGImageSourceCopyPropertiesAtIndex(source, 0, nil)!)
                        
                        var photo = Photo(id: index,filename: fileUrl.lastPathComponent, url: fileUrl.absoluteURL)
                        
                        photo.width = metadata["PixelWidth"] as? Int
                        photo.height = metadata["PixelHeight"] as? Int
                        photo.colorMode = metadata["ColorModel"] as? String
                        
                        photo.latitude = (metadata["{GPS}"] as? NSDictionary)?["Latitude"] as? Double
                        photo.longitude = (metadata["{GPS}"] as? NSDictionary)?["Longitude"] as? Double
                        
                        return photo
                    }
                } catch {
                    return []
                }
            }
        }
        
        return []
    }
    
    var body: some View {
        VStack()
        {
            
            
            GeometryReader { geometry in
                VStack
                {
                    
                    
                    if (photos.count > 0)
                    {
                        VStack{
                            HStack
                            {
                                Text("\(photos.count) photos left")
                                    .font(.title)
                                    .bold()
                                Spacer()
                            }.padding()
                        }
                        
                        .background(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.bottom)
                        
                    }
                    ZStack
                    {
                        ForEach(photos, id: \.id) { photo in
                            if (self.maxId - 3)...self.maxId ~= photo.id {
                                ImageCard(photo: photo, onRemove: removePhoto)
                                    .frame(width: self.getCardWidth(geometry, id: photo.id), height: 400, alignment: .top)
                                    .offset(x:0, y: self.getCardOffset(geometry, id: photo.id))
                                    .animation(.spring())
                            }
                        }
                    }
                }
                Spacer()
            }
        }
        .padding()
        
        .toolbar {
            ToolbarItem {
                Button(action: {
                    photos = openDirectory()
                }) {
                    Label("Open Directory", systemImage: "folder")
                }
            }
        }
    }
}



struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let filePath = Bundle.main.path(forResource: "sample", ofType: "jpg")!
        let fileUrl = URL(fileURLWithPath: filePath)
        
        MainView(photos: [Photo(id: 1, filename: "test", url: fileUrl)])
    }
}
