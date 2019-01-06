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
			return ViewModel.cryptos.count
		case 1:
			return ViewModel.fiats.count
		default:
			return 0
		}
	}

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		switch component {
		case 0:
			return ViewModel.cryptos[row]
		case 1:
			return ViewModel.fiats[row]
		default:
			return nil
		}
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		print(ViewModel.fiats[row])
		switch component {
		case 0:
			viewModel.selectedCrypto = ViewModel.cryptos[row]
		case 1:
			viewModel.selectedFiat = ViewModel.fiats[row]
		default:
			viewModel.selectedFiat = "USD"
			viewModel.selectedCrypto = "BTC"
		}
		getRatesForCurrencies(crypto: viewModel.selectedCrypto, fiat: viewModel.selectedFiat)
	}
}

class ViewController: UIViewController {
    
    let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/"
	var finalURL = ""
	var viewModel = ViewModel(initCrypto: "BCH", initFiat: "AUD")

	//MARK: - Outlets and actions
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var currencyPicker: UIPickerView!
	@IBOutlet weak var cryptoImage: UIImageView!
	@IBOutlet weak var reloadButton: UIButton!
	@IBAction func reloadButtonPressed(_ sender: Any) {
		presetPickersAndGetStartRates()
		disableReloadButton()
		Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(enableReloadButton), userInfo: nil, repeats: false)
	}

	@objc func enableReloadButton() {
		reloadButton.isEnabled = true
		reloadButton.alpha = 1
	}

	func disableReloadButton() {
		reloadButton.isEnabled = false
		reloadButton.alpha = 0.5
	}

	//MARK: - View set-up
    override func viewDidLoad() {
		super.viewDidLoad()
		currencyPicker.delegate = self
		currencyPicker.dataSource = self
		presetPickersAndGetStartRates()
    }

	func presetPickersAndGetStartRates() {
		if ViewModel.cryptos.contains(viewModel.selectedCrypto) && ViewModel.fiats.contains(viewModel.selectedFiat) {
			currencyPicker.selectRow(ViewModel.cryptos.firstIndex(of: viewModel.selectedCrypto)!, inComponent: 0, animated: true)
			currencyPicker.selectRow(ViewModel.fiats.firstIndex(of: viewModel.selectedFiat)!, inComponent: 1, animated: true)
			getRatesForCurrencies(crypto: viewModel.selectedCrypto, fiat: viewModel.selectedFiat)
		}
	}
    
    //MARK: - Networking
	func getRatesForCurrencies(crypto: String, fiat: String) {
		finalURL = baseURL + crypto + fiat
		callApiForNewRates(url: finalURL)
	}

    func callApiForNewRates(url: String) {
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

	//MARK: - Updating view elements
	func updateRatesData(for json: JSON) {
		if let rate = json["ask"].double {
			let symbol = ViewModel.currencySymbols[ViewModel.fiats.firstIndex(of: viewModel.selectedFiat)!]
			priceLabel.text = "1\(viewModel.selectedCrypto) = \(String(format: "%.2f", rate))\(symbol)"
			updateCryptoIcon()
		} else {
			priceLabel.text = "CANNOT GET DATA"
		}
	}

	func updateCryptoIcon() {
		cryptoImage.image = UIImage(named: viewModel.cryptoIconName)
	}
}
