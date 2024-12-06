//
//  ImageLoader.swift
//  STTR
//
//  Created by Arjun Lalith on 3/11/21.
//
import Foundation
import SwiftUI
import Combine

class ImageLoader: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }
    
    init(urlString:String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) {data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.data = data
            }
        }
        task.resume()
    }
}

struct ImageView: View {
    @ObservedObject var imageLoader: ImageLoader
    @State var image : UIImage = UIImage()
    
    init(withURL url : String) {
        imageLoader = ImageLoader(urlString: url)
        
    }
    
    var body: some View {
        
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 250)
            .onReceive(imageLoader.didChange){ data in
                self.image = UIImage(data: data) ?? UIImage()
            }
    }
    
}
