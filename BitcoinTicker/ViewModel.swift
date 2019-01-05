//
//  Model.swift
//  BitcoinTicker
//
//  Created by Nikandr Margal on 1/5/19.
//  Copyright © 2019 LÏL N1KKY. All rights reserved.
//

import UIKit

class ViewModel {
	var selectedCrypto: String {
		didSet {
			updateCryptoIconName()
		}
	}
	var selectedFiat: String
	var cryptoIconName: String!

	init(initCrypto: String, initFiat: String) {
		selectedCrypto = initCrypto
		selectedFiat = initFiat
		cryptoIconName = nil
		updateCryptoIconName()
	}

	func updateCryptoIconName() {
		switch selectedCrypto.lowercased() {
		case "bch":
			cryptoIconName = "bch"
		case "btc":
			cryptoIconName = "btc"
		case "eth":
			cryptoIconName = "eth"
		case "ltc":
			cryptoIconName = "ltc"
		case "xmr":
			cryptoIconName = "xmr"
		default:
			cryptoIconName = "roflan"
		}
	}
}
