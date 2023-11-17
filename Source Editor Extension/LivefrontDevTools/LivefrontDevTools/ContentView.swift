import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("This is the container app for Livefront's Xcode source editor extension.")
            Text("\n\nInstallation:")
                .font(.headline)
            List {
                listItem(
                    number: 1,
                    text: Text("Move this app to your ") +
                          Text("Applications").importantStyle() +
                          Text(" folder.")
                )
                listItem(
                    number: 2,
                    text: Text("Go to ") +
                          Text("System Settings > Privacy & Security > Extensions > Xcode Source Editor").importantStyle() +
                          Text(".")
                )
                listItem(
                    number: 3,
                    text: Text("Check the box for ") +
                          Text("Livefront").importantStyle() +
                          Text(".")
                )
                listItem(
                    number: 5,
                    text: Text("Open ") +
                    Text("Xcode").importantStyle() +
                    Text(".")
                )
                listItem(
                    number: 5,
                    text: Text("Go to ") +
                          Text("Editor > Livefront").importantStyle() +
                          Text(" to use the new source editor commands.")
                )
            }
            .listRowSeparator(.visible)
        }
        .padding()
    }

    @ViewBuilder
    func listItem(number: Int, text: Text) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text("\(number). ")
            text
        }
        .font(.title3)
    }
}

extension Text {
    func importantStyle() -> Text {
        self
            .bold()
            .foregroundColor(.cyan)
            .fontDesign(.rounded)
    }
}

#Preview {
    ContentView()
}
