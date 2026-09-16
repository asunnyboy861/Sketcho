import SwiftUI
import PhotosUI
import SwiftData

struct HomeView: View {
    @StateObject private var session = RenderSessionViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]
    @State private var photoItem: PhotosPickerItem?
    @State private var activeProject: Project?
    @State private var showPaywall = false

    init() {
        _projects = Query(sort: \Project.updatedAt, order: .reverse)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("What are we rendering today?")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    quotaCard
                    captureButton
                    if session.sourceImage != nil { renderControls }
                    recentProjects
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .background(DesignSystem.charcoal.ignoresSafeArea())
            .navigationTitle("Sketcho")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .photosPicker(isPresented: $photoPickerPresented, selection: $photoItem, matching: .images)
            .fullScreenCover(isPresented: $session.showCamera) {
                CameraCaptureView { image in
                    if let image { session.load(image: image) }
                }
                .ignoresSafeArea()
            }
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .onChange(of: photoItem) { _, item in
                guard let item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        session.load(image: image)
                    }
                    photoItem = nil
                }
            }
            .sheet(item: $activeProject) { project in
                NavigationStack {
                    ProjectDetailView(project: project)
                }
            }
        }
    }

    @State private var photoPickerPresented = false

    private var hdSubtitle: String {
        if BYOKeyManager.shared.hasFalKey || StoreService.shared.isPro { return "Cloud HD" }
        let remaining = QuotaService.shared.hdRemainingToday
        return remaining > 0 ? "Uses 1 free HD" : "Free HD used — try tomorrow"
    }

    private var quotaCard: some View {
        VStack(spacing: 6) {
            Label(session.quotaLabel, systemImage: "sparkles")
                .font(.footnote.weight(.medium))
                .foregroundStyle(DesignSystem.amber)
            if QuotaService.shared.trialActive {
                Text("Full-feature trial: \(QuotaService.shared.trialHoursRemaining)h remaining — everything unlocked, no watermark")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .sketchoCard()
    }

    private var captureButton: some View {
        VStack(spacing: 14) {
            Button {
                session.showCamera = true
            } label: {
                ZStack {
                    Circle()
                        .fill(DesignSystem.amber)
                        .frame(width: 96, height: 96)
                        .shadow(color: DesignSystem.amber.opacity(0.4), radius: 18)
                    Image(systemName: "camera.fill")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(.black)
                }
            }
            .accessibilityLabel("Capture a room or sketch")

            HStack(spacing: 24) {
                Button {
                    photoPickerPresented = true
                } label: {
                    Label("Photo Library", systemImage: "photo.on.rectangle")
                }
                Button {
                    session.load(image: PlaceholderSketch.image)
                } label: {
                    Label("Try a Sample", systemImage: "wand.and.stars")
                }
            }
            .font(.subheadline)
            .buttonStyle(.borderless)
            .tint(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .sketchoCard()
    }

    private var renderControls: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let image = session.sourceImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(maxWidth: .infinity)
            }

            StyleCapsuleRail(selected: $session.selectedStyle)

            if session.lockModeOn {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Label("Lock Mode", systemImage: "lock.fill")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text("\(Int(session.lockStrength * 100))%")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(DesignSystem.amber)
                    }
                    Slider(value: $session.lockStrength, in: 0...1)
                        .tint(DesignSystem.amber)
                        .accessibilityLabel("Geometry lock strength")
                    Text("Higher values preserve your room's exact geometry")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            TextField("Describe changes (optional): walnut floor, dusk light…", text: $session.instruction)
                .textFieldStyle(.roundedBorder)

            if let result = session.currentResult {
                NavigationLink {
                    RenderResultView(session: session)
                } label: {
                    HStack {
                        Image(uiImage: result)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        VStack(alignment: .leading) {
                            Text("Latest render")
                                .font(.subheadline.weight(.semibold))
                            Text(session.lastChannel.label)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding(10)
                    .background(DesignSystem.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 12) {
                Button {
                    Task { await session.render(quality: .preview, context: modelContext, project: nil) }
                } label: {
                    VStack(spacing: 2) {
                        if session.isRendering {
                            ProgressView().tint(.black)
                        } else {
                            Image(systemName: "bolt.fill")
                        }
                        Text("Preview").font(.caption.weight(.semibold))
                        Text("Free · on-device").font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(DesignSystem.amber)
                .disabled(!session.canRender)
                .accessibilityLabel("Render preview, free, on-device")

                Button {
                    session.requestRender(quality: .hd, context: modelContext)
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "wand.and.stars")
                        Text("HD").font(.caption.weight(.semibold))
                        Text(hdSubtitle).font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(DesignSystem.amberDim)
                .disabled(!session.canRender || session.isRendering)
                .accessibilityLabel("Render high definition, \(hdSubtitle)")
            }

            if let error = session.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .sketchoCard()
    }

    private var recentProjects: some View {
        Group {
            if !projects.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Projects")
                        .font(.headline)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(projects.prefix(10)) { project in
                                Button {
                                    activeProject = project
                                } label: {
                                    VStack(alignment: .leading, spacing: 6) {
                                        if let thumb = project.latestVersion?.image {
                                            Image(uiImage: thumb)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 130, height: 90)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                        }
                                        Text(project.name)
                                            .font(.caption)
                                            .lineLimit(1)
                                            .frame(width: 130, alignment: .leading)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .sketchoCard()
            }
        }
    }
}

extension RenderChannel {
    var label: String {
        switch self {
        case .onDevice: return "Preview quality"
        case .onDeviceEnhanced: return "Preview quality (enhanced)"
        case .cloud: return "HD cloud render"
        case .byoCloud: return "HD render (your API key)"
        }
    }
}

struct StyleCapsuleRail: View {
    @Binding var selected: StylePack

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                ForEach(StylePack.allCases) { style in
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) { selected = style }
                    } label: {
                        Label(style.displayName, systemImage: style.symbol)
                            .font(.subheadline.weight(selected == style ? .semibold : .regular))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selected == style ? DesignSystem.amber : DesignSystem.cardBackground)
                            .foregroundStyle(selected == style ? .black : .primary)
                            .clipShape(Capsule())
                            .overlay {
                                if selected == style {
                                    Capsule().strokeBorder(DesignSystem.amber, lineWidth: 2)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Style \(style.displayName)")
                    .accessibilityAddTraits(selected == style ? .isSelected : [])
                }
            }
        }
    }
}

enum PlaceholderSketch {
    static var image: UIImage {
        let size = CGSize(width: 1024, height: 768)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor(red: 0.95, green: 0.93, blue: 0.88, alpha: 1).setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            let stroke = UIColor.darkGray
            stroke.setStroke()
            ctx.cgContext.setLineWidth(4)
            let room = CGRect(x: 120, y: 140, width: 784, height: 500)
            ctx.cgContext.stroke(room, width: 4)
            let sofa = CGRect(x: 260, y: 420, width: 380, height: 160)
            ctx.cgContext.stroke(sofa, width: 3)
            ctx.cgContext.move(to: CGPoint(x: 450, y: 160))
            ctx.cgContext.addLine(to: CGPoint(x: 450, y: 380))
            ctx.cgContext.strokePath()
        }
    }
}
