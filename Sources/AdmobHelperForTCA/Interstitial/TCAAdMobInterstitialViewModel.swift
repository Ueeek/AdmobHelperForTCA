//
//  TCAAdMobIntersititialViewModel.swift
//
//
//  Created by KoichiroUeki on 2024/09/01.
//

import Foundation
import ComposableArchitecture
import GoogleMobileAds

public class TCAAdMobInterstitialViewModel: NSObject {
    public override init() {}
    private var interstitialAd: GADInterstitialAd?
    
    public func showAd() {
        DispatchQueue.main.async { [ weak self] in
            guard let interstitialAd = self?.interstitialAd else {
                return
            }
            
            interstitialAd.present(fromRootViewController: nil)
        }
    }
    
    public func loadAd() {
        Task {
            do {
                guard let adUnitIDsDict = Bundle.main.object(forInfoDictionaryKey: "AdUnitIDs") as? [String: String],
                      let adUnitID = adUnitIDsDict["interstitial"] else {
                    print("# NO Interstitial ID")
                    return
                }
                interstitialAd = try await GADInterstitialAd.load(
                    withAdUnitID: adUnitID, request: GADRequest())
                interstitialAd?.fullScreenContentDelegate = self
                print("# finish load interstitialAd \(interstitialAd)")
            } catch {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
            }
        }
    }
}

extension TCAAdMobInterstitialViewModel: GADFullScreenContentDelegate {
    // swiftlint:disable:next identifier_name
    public func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
    }
    
    // swiftlint:disable:next identifier_name
    public func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
    }
    
    public func ad(
        // swiftlint:disable:next identifier_name
        _ ad: GADFullScreenPresentingAd,
        didFailToPresentFullScreenContentWithError error: Error
    ) {
        print("\(#function) called")
    }
    
    // swiftlint:disable:next identifier_name
    public func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
    }
    
    // swiftlint:disable:next identifier_name
    public func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
    }
    
    // swiftlint:disable:next identifier_name
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
        // Clear the interstitial ad.
        interstitialAd = nil
    }
}
