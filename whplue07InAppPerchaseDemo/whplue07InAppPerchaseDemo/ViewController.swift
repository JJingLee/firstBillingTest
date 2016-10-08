//
//  ViewController.swift
//  whplue07InAppPerchaseDemo
//
//  Created by Chieh-Chun Li on 2016/10/4.
//  Copyright © 2016年 Daniel.LeeJJingLee. All rights reserved.
//

import UIKit
import StoreKit
import CoreFoundation

//extension String {
//    
//    func base64Encoded() -> String {
//        let plainData = dataUsingEncoding(NSUTF8StringEncoding)
//        let base64String = plainData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
//        return base64String!
//    }
//    
//    func base64Decoded() -> String {
//        let decodedData = NSData(base64EncodedString: self, options:NSDataBase64DecodingOptions(rawValue: 0))
//        let decodedString = NSString(data: decodedData!, encoding: NSUTF8StringEncoding)
//        return decodedString as! String
//    }
//}


class ViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var urlLabel: UITextField!
    
    @IBOutlet weak var send_btn: UIButton!
    var indicator = UIActivityIndicatorView();
    
    var productID : [String!]? = []
    var products  : [SKProduct!]? = []
    
    var selectedProducts : [Int]? = [];
    var isTransitioning : Bool = false;
    
    var http : HTTPAction = HTTPAction();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //add observer to see whats app going on.
        SKPaymentQueue.defaultQueue().addTransactionObserver(self);
        
        urlLabel.delegate = self;
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        productID?.append("whplue07TestProduct1");
        productID?.append("testProduct2");
        productID?.append("testProduct3");
        productID?.append("testProduct1");
        
        
//        var productID:NSSet = NSSet(object: "string")
//        var productsRequest:SKProductsRequest = SKProductsRequest()
//        var products = [String : SKProduct]()
        
        requestProductInfo()
        
//        let receiveURL = NSBundle.mainBundle().appStoreReceiptURL;
//        let receive : NSData? = NSData(contentsOfURL: receiveURL!);
        //let normalReceive : NSString = receive!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        
        //self.view.addGestureRecognizer(UIGestureRecognizer)
        
        //print("url : \(receiveURL), receive : \(normalReceive)");
        
        
    }
    
    func requestProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            let productIdentifiers = NSSet(array: productID!);
            let productRequest = SKProductsRequest( productIdentifiers: productIdentifiers as! Set<String>);
            
            productRequest.delegate = self
            productRequest.start()
            
        }
        else {
            print("Cannot perform In App Purchases.")
        }
        
    }
    
    @IBAction func sendPayment(sender: UIButton) {
        
        print("sended Payment");
        http.setURL(urlLabel.text!);
        for product in selectedProducts!
        {
            let payProduct : SKProduct? = products![product];
            
            print("send : \(payProduct?.productIdentifier)");
            
            let payment = SKPayment(product: payProduct!);
            
            SKPaymentQueue.defaultQueue().addPayment(payment);
            
            //loading
            indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
            indicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            indicator.startAnimating()
            self.view.addSubview(indicator);
            send_btn.enabled = false;
            send_btn.alpha = 0.3;
        }
        
    }
    
    //MARK: skproduct delegate
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        if response.products.count != 0 {
            for product in response.products {
                products?.append(product as SKProduct);
                print("product : \(product.localizedTitle)")
            }
            
            //tblProducts.reloadData()
            tableView.reloadData();
            
        }
        else {
            print("There are no products.")
        }
        
        if response.invalidProductIdentifiers.count != 0 {
            print("invalid :" + response.invalidProductIdentifiers.description);
        }
    }
    
    //MARK: SKPaymentTransitionObserver
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        
        indicator.stopAnimating();
        indicator.removeFromSuperview();
        send_btn.enabled = true;
        send_btn.alpha = 1;
        
        
            for transaction in transactions {
                
                switch transaction.transactionState {
                    
                case SKPaymentTransactionState.Purchased:
                    print("Transaction Approved")
                    print("Product Identifier: \(transaction.payment.productIdentifier)")
                    //self.deliverProduct(transaction)
                    if let receiptUrl = NSBundle.mainBundle().appStoreReceiptURL, let receiptData = NSData(contentsOfURL: receiptUrl) {
                        //if need trance to String
                        //let receiptString = receiptData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0));
                        
                        // send receipt to server
                        http.httpPostToSever(receiptData, callBack:
                            {(data,res,err)->Void in
                            print("response : \(res)");

                        })
                    }
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                    
                case SKPaymentTransactionState.Failed:
                    print("Transaction Failed")
                    print("error msg : \(transaction.error?.localizedDescription)");
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                default:
                    break
                }
            }
        
    }
    
    
    //MARK: table view delegate, datasource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (products?.count)!;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let row = indexPath.row;
        
        
        //add or elimate selection
        if selectedProducts?.count > 0
        {
            for value in selectedProducts!
            {
                if value == row
                {
                    selectedProducts?.removeAtIndex((selectedProducts?.indexOf(value))!);
                    break;
                }else if((selectedProducts?.count)!-1 == row){
                    selectedProducts?.append(row);
                }
            }

        }else
        {
            selectedProducts?.append(row);
        }
        
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = indexPath.row;
        
        let cell : UITableViewCell = UITableViewCell.init(style: .Default, reuseIdentifier: "normalCell1");
        cell.textLabel?.text = products![row].localizedTitle;
        
        cell.detailTextLabel?.text = products![row].description;
        
        return cell;
        
        
    }

    
    //MARK: textview delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

