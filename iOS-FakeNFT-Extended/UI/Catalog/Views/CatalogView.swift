import SwiftUI

struct CatalogView: View {

    @Environment(ServicesAssembly.self) private var services
    @State private var viewModel: CatalogViewModel?

    var body: some View {
        ZStack {
            Color.ypWhite.ignoresSafeArea()

            content
        }
        .errorAlert(error: errorBinding) {
            Task { await viewModel?.load() }
        }
        .task {
            if viewModel == nil {
                viewModel = CatalogViewModel(service: services.catalogService)
            }
            await viewModel?.load()
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if let viewModel {
            switch viewModel.state {
            case .idle, .loading:
                LoadingSpinner(size: .large)
            case .loaded(let collections):
                list(collections)
            case .error:
                Color.clear // toast is shown via errorAlert
            }
        } else {
            LoadingSpinner(size: .large)
        }
    }

    private func list(_ collections: [NftCollection]) -> some View {
        List {
            ForEach(collections) { collection in
                CatalogRow(collection: collection)
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
    }
}
