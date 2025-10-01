import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var locationManager: LocationManager
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7654, longitude: -73.9812),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: .none)
                .ignoresSafeArea()
                .onAppear {
                    locationManager.requestPermission()
                    if let loc = locationManager.location {
                        region.center = loc
                    }
                }
                .onReceive(locationManager.$location) { newLocation in
                    if let newLocation = newLocation {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            region.center = newLocation
                        }
                    }
                }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        if let location = locationManager.location {
                            withAnimation(.easeInOut(duration: 1.0)) {
                                region.center = location
                            }
                        }
                    }) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 16)
                }
                Spacer()
            }
        }
    }
}
