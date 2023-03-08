import SwiftUI

struct AlbumListView: View {
    
    @State
    private var isActive = false
    
    var navTitle: String
    
    var body: some View {
        let layout = [GridItem(.adaptive(minimum: 170, maximum: 170))]
        
        ScrollView(.vertical) {
            LazyVGrid(columns: layout) {
                ForEach(0..<15) {_ in
                    NavigationLink(
                        isActive: $isActive,
                        destination: {AlbumView(albumName: "Foo", artistName: "Bar")},
                        label: {
                            AlbumTile(
                                albumName: "Foo",
                                artistName: "Bar"
                            )
                            
                        }
                    )
                    .buttonStyle(.plain)
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
