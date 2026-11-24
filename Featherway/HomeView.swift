import SwiftUI

struct HomeView: View {
    @State private var showingRound = false
    @State private var round = ActiveRound.load()
    @State private var draftCourse = ""
    @State private var draftHole = 1

    @State private var selectedTab = Tab.home

    private enum Tab { case home, myBirds, history }
    @State private var showingCamera = false

    @State private var sightings: [URL] = []
    @State private var selectedPhoto: SavedPhoto?
    @State private var loadFailed = false

    private struct SavedPhoto: Identifiable {
        let id: URL
        let name: String?
        let location: SightingLocation?
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                wordmark
                    .padding(.vertical, 7)

                switch selectedTab {
                case .home: homeContent
                case .myBirds: myBirds
                case .history: history
                }
            }
            .padding(.horizontal, 15)
            .padding(.top, 6)
            .padding(.bottom, 12)
        }
        .id(selectedTab)
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            tabBar
        }
        .background(Palette.ivory.ignoresSafeArea())
        .foregroundStyle(Palette.forest)
        .tint(Palette.copper)
        .task { loadSightings() }
        .fullScreenCover(isPresented: $showingCamera) {
            BirdCaptureView(round: round) { url in
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
                if let location = photo.location {
                    if !location.course.isEmpty {
                        Label(location.course, systemImage: "mappin")
                    }
                    if let hole = location.hole {
                        Label("Hole \(hole)", systemImage: "flag")
                    }
                }
                SightingPhoto(url: photo.id, isThumbnail: false)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Button("Done") { selectedPhoto = nil }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Palette.ivory)
            .tint(Palette.forest)
        }
        .sheet(isPresented: $showingRound) {
            roundEditor
        }
    }

    @ViewBuilder
    private var homeContent: some View {
        hero

        VStack(spacing: 8) {
            actionButton("Spot a Bird", symbol: "camera", prominent: true) { showingCamera = true }
            actionButton(round.map { "\($0.course) · Hole \($0.hole)" } ?? "Start a Round",
                         symbol: "flag", prominent: false) {
                draftCourse = round?.course ?? ""
                draftHole = round?.hole ?? 1
                showingRound = true
            }
        }

        collection
            .padding(.top, 3)
    }

    private var roundEditor: some View {
        NavigationStack {
            Form {
                Section("Golf course") {
                    TextField("Course name", text: $draftCourse)
                        .textInputAutocapitalization(.words)
                }
                Section {
                    Picker("Hole", selection: $draftHole) {
                        ForEach(1...18, id: \.self) { hole in
                            Text(hole.formatted()).tag(hole)
                        }
                    }
                } header: {
                    Text("Current hole")
                } footer: {
                    Text("New bird sightings will use this course and hole.")
                }
                if round != nil {
                    Button("End Round") { setRound(nil) }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Palette.ivory)
            .navigationTitle(round == nil ? "Start a Round" : "Current round")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingRound = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(round == nil ? "Start" : "Save") {
                        if let updated = ActiveRound(course: draftCourse, hole: draftHole) {
                            setRound(updated)
                        }
                    }
                    .disabled(ActiveRound(course: draftCourse, hole: draftHole) == nil)
                }
            }
        }
        .tint(Palette.forest)
    }

    private func setRound(_ updated: ActiveRound?) {
        ActiveRound.store(updated)
        round = updated
        showingRound = false
    }

    private var myBirds: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("My Birds")
                .font(.system(.largeTitle, design: .serif))
                .accessibilityAddTraits(.isHeader)
            if loadFailed {
                Button("Couldn’t load sightings. Try again") { loadSightings() }
            } else if sightings.isEmpty {
                ContentUnavailableView {
                    Label("No saved sightings yet", systemImage: "bird")
                } description: {
                    Text("Save a bird photo to start your collection.")
                } actions: {
                    Button("Spot a Bird") { showingCamera = true }
                }
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12)], spacing: 16) {
                    ForEach(sightings, id: \.self) { url in
                        Button {
                            openPhoto(url)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                thumbnail(url)
                                Text(verbatim: SightingFiles.birdName(for: url) ?? "Unnamed sighting")
                                    .font(.system(.headline, design: .serif))
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var history: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            Text("History")
                .font(.system(.largeTitle, design: .serif))
                .accessibilityAddTraits(.isHeader)
            if loadFailed {
                Button("Couldn’t load sightings. Try again") { loadSightings() }
            } else if sightings.isEmpty {
                ContentUnavailableView("No sightings yet", systemImage: "clock",
                    description: Text("Saved sightings will appear here in date order."))
            } else {
                ForEach(sightings, id: \.self) { url in
                    Button {
                        openPhoto(url)
                    } label: {
                        HStack(spacing: 14) {
                            thumbnail(url)
                                .frame(width: 70)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(verbatim: SightingFiles.birdName(for: url) ?? "Unnamed sighting")
                                    .font(.system(.headline, design: .serif))
                                if let date = SightingFiles.savedAt(for: url) {
                                    Text(date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.subheadline)
                                        .foregroundStyle(Palette.sage)
                                }
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Palette.sage)
                                .accessibilityHidden(true)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    Divider()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func openPhoto(_ url: URL) {
        selectedPhoto = SavedPhoto(id: url, name: SightingFiles.birdName(for: url), location: SightingFiles.location(for: url))
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
                            openPhoto(url)
                        } label: {
                            thumbnail(url)
                        }
                        .accessibilityLabel("View sighting \(sightings.count - index)")
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func thumbnail(_ url: URL) -> some View {
        Color.clear
            .aspectRatio(1.1, contentMode: .fit)
            .overlay { SightingPhoto(url: url, isThumbnail: true) }
            .clipShape(.rect(cornerRadius: 11))
            .accessibilityHidden(true)
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
            tabItem("Home", icon: "house", selected: selectedTab == .home) { selectedTab = .home }
            tabItem("My Birds", icon: "bird", selected: selectedTab == .myBirds) { selectedTab = .myBirds }
            tabItem("History", icon: "flag", selected: selectedTab == .history) { selectedTab = .history }
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
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
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

}

#Preview {
    HomeView()
}
