import SwiftUI

struct FirstLaunchView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack{
                Image("\(colorScheme == .dark ? "bg-dark" : "bg-white")").resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
                
                VStack {
                    Text("Instructions").font(.title).fontWeight(.bold).padding()
                    Text("1. To use  this app, you must download the watchOS companion app, and have it open.").frame(maxWidth: .infinity, alignment: .leading).font(.system(size: 18)).padding(.bottom, 5)
                    Text("2. Wear your watch on the hand you will be punching with.").frame(maxWidth: .infinity, alignment: .leading).font(.system(size: 18)).padding(.bottom, 5)
                    Text("3. Prop your phone up infront of you and press start.").frame(maxWidth: .infinity, alignment: .leading).font(.system(size: 18)).padding(.bottom, 5)
                    Text("4. After the countdown, Punch!").frame(maxWidth: .infinity, alignment: .leading).font(.system(size: 18))
                }.padding([.leading, .trailing]).padding([.leading, .trailing])
                
                NavigationLink(destination: ContentView().navigationBarBackButtonHidden(true)) {
                    Text("Continue")
                }.buttonStyle(.bordered).controlSize(.large).buttonBorderShape(.roundedRectangle(radius: 12)).tint(.gray).foregroundColor(colorScheme == .dark ? .white : .black).padding().simultaneousGesture(TapGesture().onEnded{
                    UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                })
            }
        }
        
    }
    
}

#Preview {
    FirstLaunchView()
}
