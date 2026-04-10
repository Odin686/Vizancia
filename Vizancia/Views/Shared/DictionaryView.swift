import SwiftUI

// MARK: - Dictionary View
struct DictionaryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: DictionaryCategory? = nil
    @State private var selectedEntry: DictionaryEntry? = nil
    @State private var animateCards = false

    private var filteredEntries: [DictionaryEntry] {
        var entries = AIDictionary.entries
        if let cat = selectedCategory {
            entries = entries.filter { $0.category == cat }
        }
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            entries = entries.filter {
                $0.term.lowercased().contains(query) ||
                $0.definition.lowercased().contains(query) ||
                $0.relatedTerms.contains { $0.lowercased().contains(query) }
            }
        }
        return entries
    }

    private var groupedEntries: [(DictionaryCategory, [DictionaryEntry])] {
        let grouped = Dictionary(grouping: filteredEntries, by: \.category)
        return DictionaryCategory.allCases.compactMap { cat in
            guard let entries = grouped[cat], !entries.isEmpty else { return nil }
            return (cat, entries.sorted { $0.term < $1.term })
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Search Bar
                    searchBar

                    // Category Filter
                    categoryChips

                    // Results Count
                    HStack {
                        Text("\(filteredEntries.count) terms")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.aiTextSecondary)
                        Spacer()
                    }
                    .padding(.horizontal)

                    // Entries
                    if filteredEntries.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 12, pinnedViews: .sectionHeaders) {
                            ForEach(groupedEntries, id: \.0) { category, entries in
                                Section {
                                    ForEach(entries) { entry in
                                        DictionaryCard(entry: entry) {
                                            withAnimation(.spring(response: 0.3)) {
                                                if selectedEntry == entry {
                                                    selectedEntry = nil
                                                } else {
                                                    selectedEntry = entry
                                                    HapticService.shared.lightTap()
                                                }
                                            }
                                        }
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(selectedEntry == entry ? categoryColor(for: category).opacity(0.5) : Color.clear, lineWidth: 2)
                                        )
                                    }
                                } header: {
                                    sectionHeader(for: category, count: entries.count)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 30)
            }
            .background(Color.aiBackground.ignoresSafeArea())
            .navigationTitle("AI Dictionary")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.15)) {
                animateCards = true
            }
        }
        .sheet(item: $selectedEntry) { entry in
            DictionaryDetailSheet(entry: entry)
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.aiTextSecondary)
                .font(.system(size: 16))
            TextField("Search terms...", text: $searchText)
                .font(.system(size: 16, design: .rounded))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.aiTextSecondary)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.aiCard)
                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        )
        .padding(.horizontal)
        .padding(.top, 4)
    }

    // MARK: - Category Chips
    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chipButton(label: "All", icon: "tray.full.fill", isSelected: selectedCategory == nil) {
                    withAnimation(.spring(response: 0.3)) { selectedCategory = nil }
                }
                ForEach(DictionaryCategory.allCases) { cat in
                    chipButton(label: cat.rawValue, icon: cat.icon, isSelected: selectedCategory == cat) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = selectedCategory == cat ? nil : cat
                        }
                        HapticService.shared.lightTap()
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func chipButton(label: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                Text(label)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.aiPrimary : Color.aiCard)
            )
            .foregroundColor(isSelected ? .white : .aiTextSecondary)
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.aiTextSecondary.opacity(0.15), lineWidth: 1)
            )
        }
    }

    // MARK: - Section Header
    private func sectionHeader(for category: DictionaryCategory, count: Int) -> some View {
        HStack(spacing: 8) {
            Image(systemName: category.icon)
                .font(.system(size: 14))
                .foregroundColor(categoryColor(for: category))
            Text(category.rawValue)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.aiTextPrimary)
            Text("(\(count))")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.aiTextSecondary)
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(Color.aiBackground)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "text.magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.aiTextSecondary.opacity(0.4))
            Text("No terms found")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.aiTextSecondary)
            Text("Try a different search or category")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.aiTextSecondary.opacity(0.7))
        }
        .padding(.top, 60)
    }

    private func categoryColor(for category: DictionaryCategory) -> Color {
        switch category.color {
        case "aiPrimary": return .aiPrimary
        case "aiSecondary": return .aiSecondary
        case "aiOrange": return .aiOrange
        case "aiBlue": return .aiBlue
        case "aiPink": return .aiPink
        case "aiIndigo": return .aiIndigo
        case "aiWarning": return .aiWarning
        case "aiGreen": return .aiSuccess
        case "aiCyan": return .aiCyan
        default: return .aiPrimary
        }
    }
}

// MARK: - Dictionary Card
struct DictionaryCard: View {
    let entry: DictionaryEntry
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                // Category icon
                ZStack {
                    Circle()
                        .fill(cardColor.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: entry.category.icon)
                        .font(.system(size: 15))
                        .foregroundColor(cardColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.term)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.aiTextPrimary)
                        .multilineTextAlignment(.leading)

                    Text(entry.definition)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.aiTextSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.aiTextSecondary.opacity(0.4))
                    .padding(.top, 4)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.aiCard)
                    .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
            )
        }
    }

    private var cardColor: Color {
        switch entry.category.color {
        case "aiPrimary": return .aiPrimary
        case "aiSecondary": return .aiSecondary
        case "aiOrange": return .aiOrange
        case "aiBlue": return .aiBlue
        case "aiPink": return .aiPink
        case "aiIndigo": return .aiIndigo
        case "aiWarning": return .aiWarning
        case "aiGreen": return .aiSuccess
        case "aiCyan": return .aiCyan
        default: return .aiPrimary
        }
    }
}

// MARK: - Dictionary Detail Sheet
struct DictionaryDetailSheet: View {
    let entry: DictionaryEntry
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(detailColor.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                Image(systemName: entry.category.icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(detailColor)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.category.rawValue)
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(detailColor)
                                Text(entry.term)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.aiTextPrimary)
                            }
                        }
                    }

                    // Definition
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Definition", systemImage: "text.book.closed.fill")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.aiTextSecondary)
                        Text(entry.definition)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.aiTextPrimary)
                            .lineSpacing(4)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.aiCard)
                            .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
                    )

                    // Example
                    if let example = entry.example {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Example", systemImage: "lightbulb.fill")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.aiWarning)
                            Text(example)
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(.aiTextPrimary)
                                .italic()
                                .lineSpacing(3)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.aiWarning.opacity(0.06))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.aiWarning.opacity(0.15), lineWidth: 1)
                                )
                        )
                    }

                    // Related Terms
                    if !entry.relatedTerms.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Related Terms", systemImage: "link")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.aiTextSecondary)

                            FlowLayout(spacing: 8) {
                                ForEach(entry.relatedTerms, id: \.self) { term in
                                    Text(term)
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(detailColor)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(detailColor.opacity(0.1))
                                        )
                                }
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.aiCard)
                                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
                        )
                    }
                }
                .padding()
                .padding(.bottom, 20)
            }
            .background(Color.aiBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
            }
        }
    }

    private var detailColor: Color {
        switch entry.category.color {
        case "aiPrimary": return .aiPrimary
        case "aiSecondary": return .aiSecondary
        case "aiOrange": return .aiOrange
        case "aiBlue": return .aiBlue
        case "aiPink": return .aiPink
        case "aiIndigo": return .aiIndigo
        case "aiWarning": return .aiWarning
        case "aiGreen": return .aiSuccess
        case "aiCyan": return .aiCyan
        default: return .aiPrimary
        }
    }
}

// MARK: - Flow Layout (for related terms tags)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            let point = CGPoint(
                x: bounds.minX + result.positions[index].x,
                y: bounds.minY + result.positions[index].y
            )
            subview.place(at: point, anchor: .topLeading, proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}
