import SwiftUI

struct LibraryView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    
                } label: {
                    Label(
                        "Playlists",
                        systemImage: "music.note.list"
                    )
                }
                .disabled(true)
                
                NavigationLink {
                    
                } label: {
                    Label(
                        "Artists",
                        systemImage: "music.mic"
                    )
                }
                .disabled(true)
                
                NavigationLink {
                    AlbumListView()
                } label: {
                    Label(
                        "Albums",
                        systemImage: "square.stack"
                    )
                }
                
                NavigationLink {
                    
                } label: {
                    Label(
                        "Songs",
                        systemImage: "music.note"
                    )
                }
                .disabled(true)
                
                NavigationLink {
                    
                } label: {
                    Label(
                        "Downloaded",
                        systemImage: "tray.and.arrow.down"
                    )
                }
                .disabled(true)
            }
            .navigationTitle("Library")
            .listStyle(.plain)
        }
    }
}

#if DEBUG
struct LibraryNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
#endif
