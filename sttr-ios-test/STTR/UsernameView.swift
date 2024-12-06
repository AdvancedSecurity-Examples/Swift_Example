//
//  UsernameView.swift
//  STTR
//
//  Created by Brady  on 3/16/21.
//

import SwiftUI

struct UsernameView: View {
    @EnvironmentObject var session: SessionStore
    var name: String
    var email: String
    
    
    var body: some View {
        
            VStack(spacing: 25){
                
                    HStack(alignment: .center){
                        Text("Name:")
                            .frame(width: 75, height: 20, alignment: .leading)
                        ZStack{
                            Text("\(name)")
                                .frame(width: 225, height: 20, alignment: .center)
                            
                            Rectangle()
                                .fill(Color(UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 0.7)))
                                .frame(width: 250, height: 20)
                        }
                        
                    }
                    HStack(alignment: .center){
                        Text("Email:")
                            .frame(width: 75, height: 20, alignment: .leading)
                        ZStack{
                            
                            Text("\(email)")
                                .frame(width: 225, height: 20, alignment: .center)
                            Rectangle()
                                .fill(Color(UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 0.7)))
                                .frame(width: 250, height: 20)
                        }
                    }
                    HStack(alignment: .center){
                        Text("Phone:")
                            .frame(width: 75, height: 20, alignment: .leading)

                        ZStack{
                            Text("N/A")
                                .frame(width: 225, height: 20, alignment: .center)
                            Rectangle()
                                .fill(Color(UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 0.7)))
                                .frame(width: 250, height: 20)
                        }
                    }
                    HStack(alignment: .center){
                        Text("Birthday:")
                            .frame(width: 75, height: 20, alignment: .leading)
                        ZStack{
                            Text("N/A")
                                .frame(width: 225, height: 20, alignment: .center)
                            Rectangle()
                                .fill(Color(UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 0.7)))
                                .frame(width: 250, height: 20)
                        }
                    }
                    Spacer()
                        .frame(height: 100)
            }
            .navigationBarTitle(Text("Username"),displayMode: .inline)
        

    }
    
}

struct UsernameView_Previews: PreviewProvider {
    static var previews: some View {
        UsernameView(name: "N/A", email: "N/A")
    }
}
