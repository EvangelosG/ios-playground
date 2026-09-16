import SwiftUI
import UIKit

/// A UIKit collection view — compositional layout plus a diffable data source —
/// hosted in SwiftUI with `UIViewControllerRepresentable`.
struct CollectionViewDemo: View {
    @State private var itemCount = 12
    @State private var columns = 2
    @State private var lastTapped: String?

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Stepper("Items: \(itemCount)", value: $itemCount, in: 1...40)
                Stepper("Columns: \(columns)", value: $columns, in: 1...4)
            }
            .font(.callout)
            .padding(.horizontal)

            Text(lastTapped.map { "Selected \($0)" } ?? "Tap a cell — the delegate call comes back through the coordinator.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            PhotoGridController(itemCount: itemCount, columns: columns) { lastTapped = $0 }
                .ignoresSafeArea(edges: .bottom)
        }
        .padding(.top)
    }
}

struct PhotoGridController: UIViewControllerRepresentable {
    let itemCount: Int
    let columns: Int
    let onSelect: (String) -> Void

    func makeUIViewController(context: Context) -> UICollectionViewController {
        let controller = UICollectionViewController(collectionViewLayout: Self.layout(columns: columns))
        controller.collectionView.backgroundColor = .clear
        controller.collectionView.delegate = context.coordinator
        context.coordinator.configure(collectionView: controller.collectionView)
        context.coordinator.apply(itemCount: itemCount, animated: false)
        return controller
    }

    func updateUIViewController(_ controller: UICollectionViewController, context: Context) {
        context.coordinator.onSelect = onSelect
        controller.collectionView.setCollectionViewLayout(Self.layout(columns: columns), animated: true)
        context.coordinator.apply(itemCount: itemCount, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }

    private static func layout(columns: Int) -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / CGFloat(columns)), heightDimension: .fractionalHeight(1))
        )
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(120)),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        return UICollectionViewCompositionalLayout(section: section)
    }

    @MainActor
    final class Coordinator: NSObject, UICollectionViewDelegate {
        var onSelect: (String) -> Void
        private var dataSource: UICollectionViewDiffableDataSource<Int, String>?

        init(onSelect: @escaping (String) -> Void) {
            self.onSelect = onSelect
        }

        /// Cell registration + diffable data source: the UIKit equivalent of a
        /// SwiftUI `ForEach` over identifiable values.
        func configure(collectionView: UICollectionView) {
            let registration = UICollectionView.CellRegistration<UICollectionViewCell, String> { cell, _, identifier in
                var background = UIBackgroundConfiguration.listPlainCell()
                background.cornerRadius = 14
                background.backgroundColor = UIColor(hue: CGFloat(abs(identifier.hashValue % 100)) / 100, saturation: 0.55, brightness: 0.9, alpha: 1)
                cell.backgroundConfiguration = background

                var content = UIListContentConfiguration.cell()
                content.text = identifier
                content.textProperties.color = .white
                content.textProperties.font = .preferredFont(forTextStyle: .headline)
                cell.contentConfiguration = content
            }

            dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { view, indexPath, identifier in
                view.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: identifier)
            }
        }

        func apply(itemCount: Int, animated: Bool) {
            var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
            snapshot.appendSections([0])
            snapshot.appendItems((1...max(1, itemCount)).map { "Item \($0)" })
            dataSource?.apply(snapshot, animatingDifferences: animated)
        }

        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            collectionView.deselectItem(at: indexPath, animated: true)
            if let identifier = dataSource?.itemIdentifier(for: indexPath) {
                onSelect(identifier)
            }
        }
    }
}

#Preview {
    NavigationStack { CollectionViewDemo() }
}
