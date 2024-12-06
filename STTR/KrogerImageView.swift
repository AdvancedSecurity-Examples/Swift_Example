//
//  KrogerImageView.swift
//  STTR
//
//  Created by Siddharth N. on 3/10/21.
//


import UIKit
import Foundation
import SwiftUI
import Combine

//view used to display the images gotten from Kroger API Responses
struct KrogerImageView: View {
    @ObservedObject var imageLoader: ImageLoader
    @State var image : UIImage = UIImage()
    
    init(withURL url : String) {
        imageLoader = ImageLoader(urlString: url)
        
    }
    
    var body: some View {
        
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onReceive(imageLoader.didChange){ data in
                self.image = UIImage(data: data) ?? UIImage()
            }
    }
    
}
