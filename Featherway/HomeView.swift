import SwiftUI

struct HomeView: View {
    @State private var pendingAction: PreviewAction?

    @State private var showingCamera = false

    @State private var sightings: [URL] = []
    @State private var selectedPhoto: SavedPhoto?
    @State private var loadFailed = false

    private struct SavedPhoto: Identifiable {
        let id: URL
        let name: String?
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                wordmark
                    .padding(.vertical, 7)

                hero

                VStack(spacing: 8) {
                    actionButton("Spot a Bird", symbol: "camera", prominent: true) { showingCamera = true }
                    actionButton(PreviewAction.startRound.title, symbol: "flag", prominent: false) { pendingAction = .startRound }
                }

                collection
                    .padding(.top, 3)
            }
            .padding(.horizontal, 15)
            .padding(.top, 6)
            .padding(.bottom, 12)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            tabBar
        }
        .background(Palette.ivory.ignoresSafeArea())
        .foregroundStyle(Palette.forest)
        .tint(Palette.copper)
        .task { loadSightings() }
        .fullScreenCover(isPresented: $showingCamera) {
            BirdCaptureView { url in
                sightings.insert(url, at: 0)
                if loadFailed { loadSightings() }
            }
        }
        .sheet(item: $selectedPhoto) { photo in
            VStack {
                Text(verbatim: photo.name ?? "Your bird photo")
                    .font(.system(.title, design: .serif))
                    .foregroundStyle(Palette.forest)
                    .accessibilityAddTraits(.isHeader)
                SightingPhoto(url: photo.id, isThumbnail: false)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Button("Done") { selectedPhoto = nil }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Palette.ivory)
            .tint(Palette.forest)
        }
        .alert(
            pendingAction?.title ?? "",
            isPresented: Binding(
                get: { pendingAction != nil },
                set: { if !$0 { pendingAction = nil } }
            ),
            presenting: pendingAction
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { action in
            Text(action.previewMessage)
        }
    }

    private var wordmark: some View {
        HStack(spacing: 13) {
            Image(.heronMark)
                .resizable()
                .scaledToFit()
                .frame(width: 37, height: 46)

            Rectangle()
                .fill(Palette.sage.opacity(0.7))
                .frame(width: 1, height: 49)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 2) {
                    Text("Featherway")
                        .font(.system(size: 33, weight: .medium, design: .serif))
                    Circle()
                        .fill(Palette.copper)
                        .frame(width: 6, height: 6)
                        .padding(.top, 16)
                }

                Text("BIRDWATCHING FOR GOLFERS")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(2.3)
                    .foregroundStyle(Palette.sage)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.65)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Featherway, birdwatching for golfers")
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("YOUR COMPANION ON THE COURSE")
                .font(.subheadline.weight(.medium))
                .tracking(2.4)

            Rectangle()
                .fill(Palette.copper)
                .frame(width: 41, height: 2)
                .accessibilityHidden(true)

            Text("A little more to discover out here.")
                .font(.system(.largeTitle, design: .serif).weight(.medium))
                .accessibilityAddTraits(.isHeader)
        }
        .foregroundStyle(Palette.ivory)
        .padding(.horizontal, 27)
        .padding(.top, 24)
        .padding(.bottom, 100)
        .frame(maxWidth: .infinity, minHeight: 248, alignment: .topLeading)
        .background(alignment: .bottom) {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    Palette.heroGreen
                    Image(.course)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: 161, alignment: .bottom)
                        .clipped()
                        .mask(alignment: .top) {
                            LinearGradient(
                                stops: [
                                    .init(color: .clear, location: 0),
                                    .init(color: .black, location: 0.43)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                }
            }
            .accessibilityHidden(true)
        }
        .clipShape(.rect(cornerRadius: 17))
    }

    private func actionButton(_ title: String, symbol: String, prominent: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: symbol)
                    .font(.system(prominent ? .title2 : .body))
                    .accessibilityHidden(true)

                if prominent {
                    Rectangle()
                        .fill(Palette.ivory.opacity(0.8))
                        .frame(width: 1, height: 25)
                        .accessibilityHidden(true)
                }

                Text(title)
                    .font(.system(prominent ? .title2 : .body, design: .serif).weight(.medium))
            }
            .foregroundStyle(prominent ? Palette.ivory : Palette.forest)
            .padding(.vertical, prominent ? 11 : 8)
            .frame(maxWidth: .infinity, minHeight: prominent ? 54 : 44)
            .background(
                prominent ? Palette.copper : Palette.stone.opacity(0.48),
                in: .rect(cornerRadius: prominent ? 17 : 12)
            )
            .overlay {
                if !prominent {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Palette.sage.opacity(0.36))
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var collection: some View {
        VStack(alignment: .leading, spacing: 11) {
            ViewThatFits(in: .horizontal) {
                HStack {
                    collectionTitle.fixedSize()
                    Spacer(minLength: 8)
                    if !loadFailed { collectionCount.fixedSize() }
                }

                VStack(alignment: .leading, spacing: 8) {
                    collectionTitle
                    if !loadFailed { collectionCount }
                }
            }

            if loadFailed {
                Button("Couldn’t load sightings. Try again") { loadSightings() }
            } else if sightings.isEmpty {
                HStack(spacing: 6) {
                    birdTile(.heron, name: "Great Blue Heron")
                    birdTile(.hawk, name: "Hawk")
                    birdTile(.quail, name: "Quail")
                }
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 3), spacing: 6) {
                    ForEach(Array(sightings.enumerated()), id: \.element) { index, url in
                        Button {
                            selectedPhoto = SavedPhoto(id: url, name: SightingFiles.birdName(for: url))
                        } label: {
                            Color.clear
                                .aspectRatio(1.1, contentMode: .fit)
                                .overlay { SightingPhoto(url: url, isThumbnail: true) }
                                .clipShape(.rect(cornerRadius: 11))
                        }
                        .accessibilityLabel("View sighting \(sightings.count - index)")
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func loadSightings() {
        do {
            sightings = try SightingFiles.local.list()
            loadFailed = false
        } catch {
            loadFailed = true
        }
    }

    private var collectionTitle: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Your collection")
                .font(.system(.title, design: .serif).weight(.medium))
                .accessibilityAddTraits(.isHeader)

            Text("A LIFETIME OF DISCOVERIES")
                .font(.caption2.weight(.semibold))
                .tracking(2)
                .foregroundStyle(Palette.sage)
        }
    }

    private var collectionCount: some View {
        VStack(spacing: 2) {
            Text(sightings.isEmpty ? "3" : String(sightings.count))
                .font(.system(.title, design: .serif).weight(.medium))
                .monospacedDigit()

            Text(sightings.isEmpty ? "SAMPLE SPECIES" : "SIGHTINGS")
                .font(.caption2.weight(.semibold))
                .tracking(1)
                .foregroundStyle(Palette.sage)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Palette.stone, in: .rect(cornerRadius: 14))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(sightings.isEmpty ? "3 sample species" : "\(sightings.count) saved sightings")
    }

    private func birdTile(_ artwork: ImageResource, name: String) -> some View {
        Color.clear
            .aspectRatio(1.1, contentMode: .fit)
            .overlay {
                GeometryReader { geometry in
                    Image(artwork)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .clipShape(.rect(cornerRadius: 11))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(name)
            .accessibilityAddTraits(.isImage)
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabItem("Home", icon: "house", selected: true)
            tabItem("My Birds", icon: "bird", action: .myBirds)
            tabItem("History", icon: "flag", action: .history)
        }
        .padding(.horizontal, 10)
        .padding(.top, 5)
        .background(alignment: .top) {
            Palette.ivory
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Palette.sage.opacity(0.25))
                        .frame(height: 1)
                }
                .ignoresSafeArea(edges: .bottom)
        }
    }

    private func tabItem(
        _ title: String,
        icon: String,
        selected: Bool = false,
        action: PreviewAction? = nil
    ) -> some View {
        Button {
            pendingAction = action
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 21))
                    .accessibilityHidden(true)
                Text(title.uppercased())
                    .font(.caption2.weight(.semibold))
                    .tracking(1.1)
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(selected ? Palette.copper : Palette.sage)
            .frame(maxWidth: .infinity, minHeight: 46)
            .padding(.vertical, 2)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    enum Palette {
        static let forest = Color(red: 24 / 255, green: 55 / 255, blue: 39 / 255)
        static let heroGreen = Color(red: 40 / 255, green: 59 / 255, blue: 40 / 255)
        static let ivory = Color(red: 243 / 255, green: 238 / 255, blue: 227 / 255)
        static let copper = Color(red: 172 / 255, green: 84 / 255, blue: 31 / 255)
        static let stone = Color(red: 228 / 255, green: 222 / 255, blue: 206 / 255)
        static let sage = Color(red: 83 / 255, green: 104 / 255, blue: 88 / 255)
    }

    private enum PreviewAction {
        case startRound, myBirds, history

        var title: String {
            switch self {
            case .startRound: "Start a Round"
            case .myBirds: "My Birds"
            case .history: "History"
            }
        }

        var previewMessage: String {
            switch self {
            case .startRound: "Round tracking is planned for a later version."
            case .myBirds: "Your collection is on Home, below Spot a Bird."
            case .history: "Sighting and round history are planned for a later version."
            }
        }
    }
}

#Preview {
    HomeView()
}
