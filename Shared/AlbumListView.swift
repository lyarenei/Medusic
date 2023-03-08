import SwiftUI

struct AlbumListView: View {
    
    var navTitle: String
    
    var body: some View {
        let layout = [GridItem(.adaptive(minimum: 170, maximum: 170))]
        
        ScrollView(.vertical) {
            LazyVGrid(columns: layout) {
                ForEach(0..<15) {_ in
                    VStack(alignment: .leading) {
                        Image(systemName: "")
                            .resizable()
                            .frame(width: 160.0, height: 160)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10.0)
                                    .stroke(style: StrokeStyle(lineWidth: 1.0))
                            )
                        VStack(alignment: .leading) {
                            Text("Title")
                                .font(.subheadline)
                            
                            Text("Subtitle")
                                .font(.caption)
                        }
                    }
                }
            }.font(.largeTitle)
        }
        .navigationTitle(navTitle)
    }
}

struct SectionView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumListView(navTitle: "Navigation Title")
    }
}
