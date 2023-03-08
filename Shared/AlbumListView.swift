import SwiftUI

struct AlbumListView: View {
    
    var navTitle: String
    
    var body: some View {
        let layout = [GridItem(.adaptive(minimum: 170, maximum: 170))]
        
        ScrollView(.vertical) {
            LazyVGrid(columns: layout) {
                ForEach(0..<15) {_ in
                    AlbumTile(albumName: "Foo", artistName: "Bar")
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
