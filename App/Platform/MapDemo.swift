import MapKit
import SwiftUI

/// SwiftUI MapKit: annotations, a bound camera position and map styles. Uses
/// fixed coordinates so nothing depends on location permission or hardware.
struct MapDemo: View {
    private struct Place: Identifiable {
        let id = UUID()
        let name: String
        let symbol: String
        let coordinate: CLLocationCoordinate2D
    }

    private let places = [
        Place(name: "Golden Gate Bridge", symbol: "road.lanes", coordinate: .init(latitude: 37.8199, longitude: -122.4783)),
        Place(name: "Ferry Building", symbol: "ferry", coordinate: .init(latitude: 37.7955, longitude: -122.3937)),
        Place(name: "Twin Peaks", symbol: "mountain.2", coordinate: .init(latitude: 37.7544, longitude: -122.4477))
    ]

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7857, longitude: -122.4310),
            span: MKCoordinateSpan(latitudeDelta: 0.13, longitudeDelta: 0.13)
        )
    )
    @State private var selection: UUID?
    @State private var style: MapStyleChoice = .standard

    private enum MapStyleChoice: String, CaseIterable {
        case standard = "Standard", hybrid = "Hybrid", imagery = "Imagery"

        var style: MapStyle {
            switch self {
            case .standard: .standard(elevation: .realistic)
            case .hybrid: .hybrid
            case .imagery: .imagery
            }
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            Picker("Style", selection: $style) {
                ForEach(MapStyleChoice.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            Map(position: $position, selection: $selection) {
                ForEach(places) { place in
                    Marker(place.name, systemImage: place.symbol, coordinate: place.coordinate)
                        .tag(place.id)
                }
                MapPolyline(coordinates: places.map(\.coordinate))
                    .stroke(.blue, lineWidth: 4)
            }
            .mapStyle(style.style)
            .mapControls {
                MapCompass()
                MapScaleView()
            }
            .frame(minHeight: 320)

            HStack {
                ForEach(places) { place in
                    Button(place.name) {
                        withAnimation {
                            position = .region(MKCoordinateRegion(center: place.coordinate, latitudinalMeters: 1_200, longitudinalMeters: 1_200))
                            selection = place.id
                        }
                    }
                    .font(.caption)
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal)

            Text(selection.flatMap { id in places.first { $0.id == id }?.name } ?? "Tap a marker or a button to move the camera.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom)
        }
    }
}

#Preview {
    NavigationStack { MapDemo() }
}
