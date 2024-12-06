//
//  ImageLoader.swift
//  STTR
//
//  Created by Arjun Lalith on 3/11/21.
//
import Foundation
import SwiftUI
import Combine


//class used to load images from a url
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
        URLCache.shared.removeAllCachedResponses()
        task.resume()
    }
}

//view used to display an image from a url
struct ImageView: View {
    @ObservedObject var imageLoader: ImageLoader
    @State var image : UIImage = UIImage()
    
    init(withURL url : String) {
        imageLoader = ImageLoader(urlString: url)
        
    }
    
    var body: some View {
        
        Image(uiImage: image)
            .resizable()
            .frame(width: UIScreen.main.bounds.width - 30, height: UIScreen.main.bounds.height/4)
            .aspectRatio(contentMode: .fit)            
            .onReceive(imageLoader.didChange){ data in
                self.image = UIImage(data: data) ?? UIImage()
            }
    }
    
}
