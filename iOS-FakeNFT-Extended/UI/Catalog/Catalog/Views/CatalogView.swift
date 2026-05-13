import SwiftUI

struct CatalogView: View {

    @Environment(ServicesAssembly.self) private var services
    @State private var viewModel: CatalogViewModel?
    @State private var isShowingSortDialog = false

    @AppStorage("catalogSortOption") private var storedSortOption: CatalogSortOption = .nftCount

    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()
            content
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                MenuButton {
                    isShowingSortDialog = true
                }
            }
        }
        .confirmationDialog(
            Text("Catalog.sort.title"),
            isPresented: $isShowingSortDialog,
            titleVisibility: .visible
        ) {
            Button("Catalog.sort.byName") {
                storedSortOption = .name
            }
            Button("Catalog.sort.byNftCount") {
                storedSortOption = .nftCount
            }
            Button("Common.close", role: .cancel) {}
        }
        .errorAlert(error: errorBinding) {
            Task { await viewModel?.load() }
        }
        .task {
            if viewModel == nil {
                let vm = CatalogViewModel(service: services.catalogService)
                vm.sortOption = storedSortOption
                viewModel = vm
            }
            await viewModel?.load()
        }
        .onChange(of: storedSortOption) { _, newValue in
            viewModel?.sortOption = newValue
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if let viewModel {
            switch viewModel.state {
            case .loading:
                LoadingSpinner(size: .medium)
            case .success:
                list(viewModel.collections)  // ← передаём collections явно
            case .error:
                Color.clear
            }
        } else {
            LoadingSpinner(size: .medium)
        }
    }

    private func list(_ collections: [NftCollection]) -> some View {
        List {
            ForEach(collections) { collection in
                NavigationLink(value: CatalogRoute.collection(collection)) {
                    CatalogRow(collection: collection)
                }
                .buttonStyle(.plain)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.ypWhite)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.ypWhite)
        .contentMargins(.top, 20, for: .scrollContent)
        .refreshable {
            await viewModel?.load()
        }
    }

    // MARK: - Bindings

    private var errorBinding: Binding<Error?> {
        Binding(
            get: { viewModel?.error },
            set: { viewModel?.error = $0 }
        )
    }
}

#Preview {
    NavigationStack {
        CatalogView()
            .environment(ServicesAssembly(networkClient: DefaultNetworkClient()))
            .environment(Router())
    }
}
