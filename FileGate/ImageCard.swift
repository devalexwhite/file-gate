//
//  ImageCard.swift
//  FileGate
//
//  Created by Alex White on 4/20/22.
//

import SwiftUI

struct ImageCard: View {
    //    @State public var url: URL
    @State private var translation: CGSize = .zero
    @State private var gesturePercentage: CGFloat = 0.0
    
    private var photo: Photo
    private var onRemove: (_ photo: Photo, _ keep: Bool) -> Void
    private var thresholdPercentage: CGFloat = 0.2
    
    init(photo: Photo, onRemove: @escaping (_ photo:Photo, _ keep: Bool) -> Void) {
        self.photo = photo
        self.onRemove = onRemove
        
    }
    
    private func getGesturePercentage(geometry: GeometryProxy, from gesture: DragGesture.Value) -> CGFloat
    {
        gesturePercentage = gesture.translation.width / geometry.size.width
        return gesturePercentage
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack
            {
                VStack(alignment: .leading)
                {
                    
                    AsyncImage(url: self.photo.url) { phase in
                        switch phase {
                        case .empty:
                            Color.purple.opacity(0.1)
                            
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                            
                        case .failure(_):
                            Image(systemName: "exclamationmark.icloud")
                                .resizable()
                                .scaledToFit()
                            
                        @unknown default:
                            Image(systemName: "exclamationmark.icloud")
                        }
                    }
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.75)
                    .clipped()
                    
                    
                    
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(self.photo.filename)
                                .font(.title)
                                .bold()
                            
                            Text("\(String(photo.width ?? 0))x\(String(photo.height ?? 0)), \(photo.colorMode ?? "")")
                                .font(.subheadline)
                                .bold()
                                .padding(.bottom)
                        }
                        Spacer()
                    }.padding(.horizontal)
                }
                
                .background(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .opacity(
                    1.0 -  abs(gesturePercentage)
                )
                
                if abs(gesturePercentage) > thresholdPercentage
                {
                    VStack {
                        Text(gesturePercentage > 0 ? "👍" : "👎")
                            .font(Font(CTFont(.application, size: 60.0)))
                            .opacity(abs(gesturePercentage) + 0.70)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .background(Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.20 + abs(gesturePercentage)))
                    .cornerRadius(10)
                    .clipped()
                }
                
            }
            .offset(x: translation.width, y: 0)
            .rotationEffect(.degrees(
                Double(self.translation.width / geometry.size.width) * 25
            ), anchor: .bottom)
            .animation(.interactiveSpring())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        translation = value.translation
                        _ = getGesturePercentage(geometry: geometry, from: value)
                    }
                    .onEnded { value in
                        if abs(getGesturePercentage(geometry: geometry, from: value)) > thresholdPercentage
                        {
                            self.onRemove(self.photo, getGesturePercentage(geometry: geometry, from: value) > 0)
                        }
                        else {
                            gesturePercentage = 0
                        }
                        translation = .zero
                        
                    }
            )
        }
    }
}


struct FileURL: Identifiable, Hashable
{
    let name: String
    let url: URL
    let id = UUID()
}

struct ImageCard_Previews: PreviewProvider {
    static var previews: some View {
        let filePath = Bundle.main.path(forResource: "sample", ofType: "jpg")!
        let fileUrl = URL(fileURLWithPath: filePath)
        let photo = Photo(id: 1, filename: "test", url: fileUrl)
        ImageCard(photo: photo, onRemove: {_,_  in }).frame(height: 400).padding()
    }
}
