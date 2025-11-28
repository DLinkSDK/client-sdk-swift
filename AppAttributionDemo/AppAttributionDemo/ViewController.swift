//
//  ViewController.swift
//  AppAttributionDemo
//
//

import UIKit
import AppAttribution

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // here's demo for log attribution events with AppAttribution.
    }
    
    private func setUserInfo() {
        var userData = UserDataModel()
        userData.countryName = "COUNTRY_NAME"
        userData.city = "CITY"
        userData.emails = ["EMAIL1", "EMAIL2"]
        userData.phones = ["PHONE1", "PHONE2"]
        userData.firstName = "FIRST_NAME"
        userData.lastName = "LAST_NAME"
        userData.fbLoginId = "FB_LOGIN_ID"
        AttributionManager.setUserData(userData)
    }
    
    private func generateRandomProductContent(_ count: Int, price: Float, skuId: String? = nil) -> ProductItem.Content {
        let suffix = (0..<10).randomElement() ?? 0
        var content = ProductItem.Content(
            productId: "PRODUCT_ID_\(suffix)",
            productName: "PRODUCT_NAME_\(suffix)",
            quantity: count,
            value: price
        )
        
        // if the content has an related skuid, set it up.
        if let skuId {
            content.skuId = skuId
        }
        
        return content
    }
    
    private func logViewContent() {
        // you can log this when users entry the product's detail page
        let productItem = ProductItem(
            content: generateRandomProductContent(1, price: 9.9),
            currency: "USD",
            value: 9.9 // total price
        )
        LogEvent.shared.logViewContentEvent(item: productItem)
    }
    
    private func logAddToCard() {
        // when the user clicks the "Add to Cart" button.
        let content = generateRandomProductContent(3, price: 10.0)
        let productItem = ProductItem(
            content: content,
            currency: "RMB",
            value: content.value * Float(content.quantity) // total price
        )
        LogEvent.shared.logAddToCart(item: productItem)
    }
    
    private func logInitiateCheckoutEvent() {
        // when the user start to checkout
        let productItem = ProductItem(
            content: generateRandomProductContent(1, price: 9.9),
            currency: "USD",
            value: 9.9 // total price
        )
        LogEvent.shared.logInitiateCheckoutEvent(item: productItem)
    }
    
    private func logPurchase() {
        // when the user complte a normal purchase.

        // create the product content
        // if it have an related skuId, remember to set it up like content.skuId = "xxxx"
        var content = generateRandomProductContent(1, price: 9.9, skuId: "my_product_sku_Id")
        content.purchaseDate = Int(Date().timeIntervalSince1970) // set up the purchase date, measure by second
        let productItem = ProductItem(
            content: content,
            currency: "USD",
            value: 9.9 // total price
        )
        // pass the transactionIdentfier in if it's available.
        LogEvent.shared.logPurchaseSuccess(item: productItem, transactionIdentifier: "purchase_transaction_id")
    }
    
    private func logSubscribe() {
        // when the user has complete a subsciption.
        
        // create the product content
        // if it have an related skuId, remember to set it up like content.skuId = "xxxx"
        var content = generateRandomProductContent(1, price: 9.9, skuId: "my_subscirption_product_sku_Id")
        content.purchaseDate = Int(Date().timeIntervalSince1970) // set up the purchase date, measure by second
        var productItem = ProductItem(
            content: content,
            currency: "USD",
            value: 9.9 // total price
        )
        // Required!! set up the period of a subscription.
        // in other events, if the product is a subscription, you'd better also setup subscribeDay
        productItem.subscribeDay = 30
        // pass the transactionIdentfier in if it's available.
        LogEvent.shared.logPurchaseSuccess(item: productItem, transactionIdentifier: "subscription_transaction_id")

    }
}

