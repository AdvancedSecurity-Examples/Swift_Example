//
//  MenuView.swift
//  STTR
//
//  Created by Brady  on 3/10/21.
//

import SwiftUI
import Firebase



struct MenuView: View{
    @EnvironmentObject var session: SessionStore
    
    func signOut() {
        session.signOut()
    }
    
    var body: some View{
        VStack(alignment: .leading){
            
            Group {
              //  GeometryReader{ geometry in
                    HStack{
                        NavigationLink(destination: UsernameView(name: session.session?.displayName ?? "N/A", email: session.session?.email ?? "N/A")){
                            Text("Username")
                                .foregroundColor(.black)
                                .font(.headline)
                        }

                    }
                    .padding(.init(top: UIScreen.main.bounds.height * 0.125, leading: 15, bottom: 15, trailing: 0))
                //    .padding(.init(top: 85, leading: 15, bottom: 15, trailing: 0))
                //}
               
                
                VStack{
                    Color.black.frame(height: CGFloat(1) / UIScreen.main.scale)
                }
                
                HStack{
                    NavigationLink(destination: CartView()){
                        Text("Cart")
                            .foregroundColor(.black)
                            .font(.headline)
                    }
                }
                .padding()
                
                VStack{
                    Color.black.frame(height: CGFloat(1) / UIScreen.main.scale)
                }
                
                HStack{
                    NavigationLink(destination: GeneralSettingsView()){
                        Text("Settings")
                            .foregroundColor(.black)
                            .font(.headline)
                    }
                }
                .padding()
                
                VStack{
                    Color.black.frame(height: CGFloat(1) / UIScreen.main.scale)
                }
            }
            
            Group{
    
                HStack{
                    Text("Account")
                        .foregroundColor(.black)
                        .font(.headline)
                }
                .padding()
                
                VStack{
                    Color.black.frame(height: CGFloat(1) / UIScreen.main.scale)
                }
                
                HStack{
                    Button(action: signOut) {
                        Text("Sign Out")
                            .foregroundColor(.black)
                            .font(.headline)
                    }
                }
                .padding()
                
                VStack{
                    Color.black.frame(height: CGFloat(1) / UIScreen.main.scale)
                }
            }
            Spacer()
            
        }
        .padding(.bottom,100)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray3))
        .edgesIgnoringSafeArea(.all)
        
        
    }
}


struct MenuViewHelper: View{
    
    @State var showMenu = false
        
        var body: some View {
            
            let drag = DragGesture()
                .onEnded {
                    if $0.translation.width < -100 {
                        withAnimation {
                            self.showMenu = false
                        }
                    }
                }
            
            return NavigationView {
    
                       GeometryReader { geometry in
                           ZStack(alignment: .leading) {
                               RecipeView(showMenu: self.$showMenu)
                                   .frame(width: geometry.size.width, height: geometry.size.height)
                                   .offset(x: self.showMenu ? geometry.size.width/2 : 0)
                                   .disabled(self.showMenu ? true : false)
                               if self.showMenu {
                                   MenuView()
                                       .frame(width: geometry.size.width/2)
                                       .transition(.move(edge: .leading))
                               }
                           }
                               .gesture(drag)
                       }
                           .navigationBarTitle("Search Recipes", displayMode: .inline)
                       .background(NavigationConfigurator { nc in
                                         nc.navigationBar.barTintColor = .systemGray3
                                         nc.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
                                 })
                           .navigationBarItems(leading: (
                               Button(action: {
                                   withAnimation {
                                       self.showMenu.toggle()
                                   }
                               }) {
                                   Image(systemName: "line.horizontal.3")
                                    .imageScale(.large)
                                    .foregroundColor(.black)
                               }
                           ))
            }.navigationViewStyle(StackNavigationViewStyle())
            
            
        }
    
}

struct NavigationConfigurator: UIViewControllerRepresentable {
    
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }

}


#if DEBUG
struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
#endif
