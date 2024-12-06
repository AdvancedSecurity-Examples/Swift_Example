//
//  MenuView.swift
//  STTR
//
//  Created by Brady  on 3/10/21.
//

import SwiftUI
import Firebase


//view for the navigation sidebar
struct MenuView: View{
    @EnvironmentObject var session: SessionStore
    
    //function to sign the user out of the session
    func signOut() {
        session.signOut()
    }
    
    var body: some View{
        VStack(alignment: .leading){
            
            Group {
                HStack{
                    NavigationLink(destination: CartView()){
                        Text("Cart")
                            .foregroundColor(.black)
                            .font(.headline)
                    }
                }
                .padding(.init(top: UIScreen.main.bounds.height * 0.125, leading: 15, bottom: 15, trailing: 0))
                
                VStack{
                    Color.black.frame(height: CGFloat(1) / UIScreen.main.scale)
                }
                
                
                
                HStack{
                    NavigationLink(destination: AccountView()){
                        Text("Account")
                            .foregroundColor(.black)
                            .font(.headline)
                    }
                    
                }
                .padding()
                
                VStack{
                    Color.black.frame(height: CGFloat(1) / UIScreen.main.scale)
                }
                
                HStack{
                    NavigationLink(destination: ContactsView()){
                        Text("Contacts")
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

//view used for the sidebar menu
struct MenuViewHelper: View{
    
    @State var showMenu = false //used to show or not show menu
    @Environment(\.colorScheme) var colorScheme //used to determine light or dark mode
    
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
                    if(colorScheme != .dark){
                        Image(systemName: "line.horizontal.3")
                            .imageScale(.large)
                            .foregroundColor(.black)
                            .frame(width: 30, height: 30, alignment: .center)
                    } else {
                        Image(systemName: "line.horizontal.3")
                            .imageScale(.large)
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30, alignment: .center)
                    }
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
