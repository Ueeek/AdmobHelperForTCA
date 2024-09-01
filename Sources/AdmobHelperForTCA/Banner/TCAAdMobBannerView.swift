//
//  AdMobBannerView.swift
//  Created by KoichiroUeki on 2024/04/15.
//

import GoogleMobileAds
import SwiftUI
import ComposableArchitecture
import UIKit

@Reducer
public struct AdMobBanner {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
        var adHeight: CGFloat = 10
    }
    
    public enum Action: Sendable {
        case adHeightChange(newHeight: CGFloat)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .adHeightChange(let newHeight):
                    print("# reducer adHeightChanged")
                    state.adHeight = newHeight
                    return .none
            }
        }
    }
}

public struct AdBannerView: View {
    let store: StoreOf<AdMobBanner>
    
    public init(store: StoreOf<AdMobBanner>? = nil) {
        self.store = store ?? .init(initialState: AdMobBanner.State(), reducer: { AdMobBanner() })
    }
    
    public var body: some View {
        _AdBannerView(store: store)
            .frame(height: store.adHeight)
    }
    
    // swiftlint:disable:next type_name
    struct _AdBannerView: UIViewControllerRepresentable {
        let store: StoreOf<AdMobBanner>
        
        typealias UIViewControllerType = AdBannerViewController
        
        func makeUIViewController(context: Context) -> UIViewControllerType {
            let bannerViewController = UIViewControllerType(store: store)
            return bannerViewController
        }
        
        func updateUIViewController(
            _ uiViewController: UIViewControllerType,
            context: Context
        ) {
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator()
        }
    }
}
    
class AdBannerViewController: UIViewController {
    private var store: StoreOf<AdMobBanner>
    private(set) var adBannerView = GADBannerView()
    
    public init(store: StoreOf<AdMobBanner>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let adUnitIDsDict = Bundle.main.object(forInfoDictionaryKey: "AdUnitIDs") as? [String: String],
              let adUnitID = adUnitIDsDict["banner"] else {
            print("# NO BANNER ID")
            return
        }
        adBannerView.adUnitID = adUnitID
        view.addSubview(adBannerView)
        adBannerView.rootViewController = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyBanner()
    }
    
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        coordinator.animate { _ in
            // do nothing
        } completion: { _ in
            self.applyBanner()
        }
    }
    
    private func applyBanner() {
        let width = view.frame.inset(by: view.safeAreaInsets).size.width
        let size = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width)
        adBannerView.adSize = size
        adBannerView.isAutoloadEnabled = true
        store.send(.adHeightChange(newHeight: size.size.height))
    }
}
