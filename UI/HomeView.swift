import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Text("VECTRA")
                .font(.largeTitle)
                .bold()
                .padding()
            
            Button(action: {
                // start scan action
            }) {
                Text("New Scan")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    HomeView()
}
