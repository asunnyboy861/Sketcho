import SwiftUI
import SwiftData

struct ProjectsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]
    @State private var showPaywall = false

    init() {
        _projects = Query(sort: \Project.updatedAt, order: .reverse)
    }

    var body: some View {
        NavigationStack {
            Group {
                if projects.isEmpty {
                    ContentUnavailableView(
                        "No projects yet",
                        systemImage: "folder",
                        description: Text("Render your first room on the Create tab and it will appear here with its full version timeline.")
                    )
                } else {
                    List {
                        ForEach(projects) { project in
                            NavigationLink {
                                ProjectDetailView(project: project)
                            } label: {
                                HStack(spacing: 12) {
                                    if let thumb = project.latestVersion?.image {
                                        Image(uiImage: thumb)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 64, height: 48)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    } else {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(DesignSystem.cardBackground)
                                            .frame(width: 64, height: 48)
                                    }
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(project.name)
                                            .font(.headline)
                                            .lineLimit(1)
                                        Text("\(project.versions.count) version\(project.versions.count == 1 ? "" : "s") · \(project.updatedAt.formatted(.relative(presentation: .named)))")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                modelContext.delete(projects[index])
                            }
                            try? modelContext.save()
                        }
                    }
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showPaywall = true
                    } label: {
                        Label("Unlimited", systemImage: "crown.fill")
                            .foregroundStyle(DesignSystem.amber)
                    }
                    .accessibilityLabel("Upgrade to Pro for unlimited project folders")
                }
            }
            .sheet(isPresented: $showPaywall) { PaywallView() }
        }
    }
}

struct ProjectDetailView: View {
    let project: Project
    @Environment(\.dismiss) private var dismiss
    @State private var selectedVersion: RenderVersion?

    private var sortedVersions: [RenderVersion] {
        project.versions.sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let selected = selectedVersion ?? project.latestVersion {
                    if let original = selected.originalImage {
                        CompareSlider(before: original, after: selected.image ?? UIImage())
                            .frame(height: 300)
                    } else if let image = selected.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    versionInfo(selected)
                }

                Text("Version Timeline")
                    .font(.headline)
                ForEach(Array(sortedVersions.enumerated().reversed()), id: \.element.persistentModelID) { index, version in
                    versionRow(version, number: index + 1)
                }
            }
            .padding()
        }
        .background(DesignSystem.charcoal.ignoresSafeArea())
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
        }
    }

    private func versionInfo(_ version: RenderVersion) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(version.channel.label, systemImage: "checkmark.seal.fill")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(DesignSystem.amber)
                Spacer()
                Text("v\(sortedVersions.count)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            Text("\(version.style.displayName) · lock \(Int(version.lockStrength * 100))%")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(version.prompt)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .sketchoCard()
    }

    private func versionRow(_ version: RenderVersion, number: Int) -> some View {
        Button {
            selectedVersion = version
        } label: {
            HStack(spacing: 12) {
                if let thumb = version.image {
                    Image(uiImage: thumb)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 52, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Version \(number)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                    Text(version.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if (selectedVersion ?? project.latestVersion) === version {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(DesignSystem.amber)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Version \(number), roll back to this version")
    }
}
