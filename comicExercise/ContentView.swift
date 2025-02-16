//UI updates happen on the main thread



import SwiftUI

struct comic: Codable{
    var num:Int
    var month:String
    var day:String
    var year:String
    var title:String
    var img:String
    var alt:String
}


class ComicModel{
    var comic:comic?
    var imageURL:URL?
    var refreshDate:Date?
    
    func refresh() async{
        
        self.comic = await getComic()
    }
    
    
    private func getComic() async -> comic?{
        let session = URLSession(configuration: .default)
        
        if let url = URL(string: "https://xkcd.com/info.0.json"){
            let request = URLRequest(url:url)
            
            do{
                let (data,response) = try await session.data(for:request)
                let decoder = JSONDecoder()
                let comic = try decoder.decode(comicExercise.comic.self, from: data)
                self.imageURL = URL(string:comic.img)
                self.refreshDate = Date()
                return comic
            } catch{
                //             TODO: DO something with the error
                print(error)
            }
        }
        return nil
    }
}




//        session.dataTask(with: request) { data, response, error in
//            if let data = data{
//                let decoder = JSONDecoder()
//                do {
//                    let comicResponse = try
//                    decoder.decode(comic.self,
//                                   from: data)
//                    completion(comicResponse) //call te completion so that it can get its data
//                } catch{
//                    print("Error decoding: \(error)")
//                }
//            }
//        }.resume()






//this is what I did, for some reason got an error when trying to display num
//struct ContentView: View {
//
//    @State var num:Int
//    @State var month:String = ""
//    @State var day:String = ""
//    @State var year:String = ""
//    @State var img:String = ""
//    @State var alt:String = ""
//    @State var title:String = ""
//
//    var body: some View {
//        VStack {
//            Button("Today's XKCD Comic"){
//                getComic {comicResponse in
//                    num = comicResponse.num
//                    title = comicResponse.title
//                    month = comicResponse.month
//                    day = comicResponse.day
//                    year = comicResponse.year
//                    img = comicResponse.img
//                    alt = comicResponse.alt
//                }
//            }.font(.title)
//
//            Text("Title: \(title)")
//            Text("Date: \(month)/\(day)/\(year)")
//
//            Text("img: \(img)")
//            Text("alt: \(alt)")
////            Text(num)
//
//
//
//        }
//        .padding()
//    }
//}




struct ContentView:View{
    @State var fetchingComic = false
    @State var dailyComic: comic?
    @State var imageURL: URL?
    @State var comicModel = ComicModel()
    
    
    func loadComic(){
        fetchingComic = true
        Task{
            await comicModel.refresh()
            fetchingComic = false
        }
    }
    
    var body: some View{
        VStack{
            Text("Today's XKCD Comic")
                .font(.title)
            Text(dailyComic?.title ?? "")
            AsyncImage(url: comicModel.imageURL){ image in//Async image will not fetch a new image
                image.resizable()
                    .aspectRatio(contentMode: .fit)
            }placeholder: {
                if (fetchingComic){
                    ProgressView()
                }
            }
            Spacer()
            Button("Get Comic") {
                loadComic()
            }
            .padding()
            .background(Color(red: 0, green: 0, blue: 0.5))
            .foregroundStyle(.white)
            .clipShape(Capsule())
            
            .disabled(fetchingComic)
        }.padding()
            .onAppear{
                loadComic()
            }
    }
}

#Preview {
    ContentView()
}
