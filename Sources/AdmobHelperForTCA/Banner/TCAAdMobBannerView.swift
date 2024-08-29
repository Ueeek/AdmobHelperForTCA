//
//  AdMobBannerView.swift
//  Created by KoichiroUeki on 2024/04/15.
//

import GoogleMobileAds
import SwiftUI
import ComposableArchitecture
import UIKit

@Reducer
struct AdMobBanner {
    @ObservableState
    struct State: Equatable {
        var adHeight: CGFloat = 10
    }
    
    enum Action: Sendable {
        case adHeightChange(newHeight: CGFloat)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .adHeightChange(let newHeight):
                    state.adHeight = newHeight
                    return .none
            }
        }
    }
}

public struct AdBannerView: View {
    var store: StoreOf<AdMobBanner> = .init(initialState: .init()) {
        AdMobBanner()
    }
    public var body: some View {
        _AdBannerView(updateHeight: { newHeight in
            store.send(.adHeightChange(newHeight: newHeight))
        }).frame(height: store.adHeight)
    }
}

// swiftlint:disable:next type_name
struct _AdBannerView: UIViewControllerRepresentable {
    var updateHeight: ((CGFloat) -> Void)
    
    typealias UIViewControllerType = AdBannerViewController
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let bannerViewController = UIViewControllerType()
        bannerViewController.updateHeight = updateHeight
        
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

class AdBannerViewController: UIViewController {
    private(set) var adBannerView = GADBannerView()
    var updateHeight: ((CGFloat) -> Void)?
    
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
    
    func updateHeight(height: CGFloat) {
        self.updateHeight?(height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyBanner(
            view.frame.inset(
                by: view.safeAreaInsets
            ).size.width
        )
    }
    
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        coordinator.animate { _ in
            // do nothing
        } completion: { _ in
            self.applyBanner(
                self.view.frame.inset(
                    by: self.view.safeAreaInsets
                ).size.width
            )
        }
    }
    
    private func applyBanner(_ width: CGFloat) {
        let size = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width)
        adBannerView.adSize = size
        adBannerView.isAutoloadEnabled = true
        self.updateHeight(height: size.size.height)
    }
}
