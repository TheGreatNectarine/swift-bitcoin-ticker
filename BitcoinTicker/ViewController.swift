//
//  ViewController.swift
//  BitcoinTicker
//
//  Created by Nikandr Margal on 1/5/19.
//  Copyright © 2019 LÏL N1KKY. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 2
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		switch component {
		case 0:
			return cryptos.count
		case 1:
			return fiats.count
		default:
			return 0
		}
	}

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		switch component {
		case 0:
			return cryptos[row]
		case 1:
			return fiats[row]
		default:
			return nil
		}
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		print(fiats[row])
		switch component {
		case 0:
			viewModel.selectedCrypto = cryptos[row]
		case 1:
			viewModel.selectedFiat = fiats[row]
		default:
			viewModel.selectedFiat = "USD"
			viewModel.selectedCrypto = "BTC"
		}
		updateURL(crypto: viewModel.selectedCrypto, fiat: viewModel.selectedFiat)
	}
}

class ViewController: UIViewController {
    
    let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/"
	var finalURL = ""
	var viewModel = ViewModel(initCrypto: "BCH", initFiat: "AUD")
	let cryptos = ["BCH", "BTC", "ETH", "LTC", "XMR"]
    let fiats = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","UAH","ZAR"]
	

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var currencyPicker: UIPickerView!
	@IBOutlet weak var cryptoImage: UIImageView!

    override func viewDidLoad() {
		super.viewDidLoad()
		currencyPicker.delegate = self
		currencyPicker.dataSource = self

		if cryptos.contains(viewModel.selectedCrypto) && fiats.contains(viewModel.selectedFiat) {
			currencyPicker.selectRow(cryptos.firstIndex(of: viewModel.selectedCrypto)!, inComponent: 0, animated: true)
			currencyPicker.selectRow(fiats.firstIndex(of: viewModel.selectedFiat)!, inComponent: 1, animated: true)
			updateURL(crypto: viewModel.selectedCrypto, fiat: viewModel.selectedFiat)
		}
    }

	func updateURL(crypto: String, fiat: String) {
		finalURL = baseURL + crypto + fiat
		getRatesData(url: finalURL)
	}
    
    //MARK: - Networking
    func getRatesData(url: String) {
        Alamofire.request(url, method: .get).responseJSON { response in
                if response.result.isSuccess {
                    print("Got rate data")
					self.updateRatesData(for: JSON(response.result.value!))
                } else {
					print("Error: \(response.result.error as Error?)")
                    self.priceLabel.text = "Connection Issues"
                }
            }
    }

    //MARK: - JSON Parsing
    func updateRatesData(for json: JSON) {
        if let rate = json["ask"].double {
			priceLabel.text = "1\(viewModel.selectedCrypto) = \(String(format: "%.2f", rate))\(viewModel.selectedFiat)"
			updateCryptoIcon()
		} else {
			priceLabel.text = "CANNOT GET DATA"
		}
    }

	func updateCryptoIcon() {
		cryptoImage.image = UIImage(named: viewModel.cryptoIconName)
	}

}



