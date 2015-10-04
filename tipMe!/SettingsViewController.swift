//
//  SettingsViewController.swift
//  tipMe!
//
//  Created by Naseer on 10/3/15.
//  Copyright (c) 2015 Naji. All rights reserved.
//

import UIKit

class SettingsViewController : UIViewController, UIPickerViewDataSource {
    
    @IBOutlet weak var currencyPickerView: UIPickerView!
    
    @IBOutlet weak var defaultTipSegment: UISegmentedControl!
    var pickerData: [String] = [String]()

    //MARK: - Initialization
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Initialize View Controller
        self.initialize()
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func initialize()
    {
        // Input data into the Array:
        pickerData = self.allAvailableCountries() as NSArray as! [String]
        
        //Choose default value for defaultTipPercentage
        let tipValueToChoose = NSUserDefaults.standardUserDefaults().objectForKey(kDefaultTipPercentageKey) as! String! ?? defaultTipPercentages[0]

        defaultTipSegment.selectedSegmentIndex = defaultTipPercentages.indexOf(tipValueToChoose)!

        //Choose default picker value
        let pickerValueToChoose = NSUserDefaults.standardUserDefaults().objectForKey(kDefaultLocaleIdentifierKey) ?? "es_US"
        
        let rowIndex = pickerData.indexOf(pickerValueToChoose as! String) ?? 0
        currencyPickerView.selectRow(rowIndex, inComponent: 0, animated: true)
    }
    
    func allAvailableCountries() -> NSMutableArray
    {
        let availableIdentifiers = NSLocale.availableLocaleIdentifiers()
        
        let mutableFinalArray : NSMutableArray = NSMutableArray(array: [])
        let mutableCountryNameArray : NSMutableArray = NSMutableArray(array: [])
        
        for localeIdentifier: String in availableIdentifiers
        {
            let locale = NSLocale.init(localeIdentifier : localeIdentifier)
            let usLocale = NSLocale.init(localeIdentifier : "en_US")
            let countryCode : String? = locale.objectForKey(NSLocaleCountryCode) as! String!
            let countryName = (countryCode != nil) ? usLocale.displayNameForKey(NSLocaleCountryCode, value: countryCode!)  as String! : ""
            
            if(!countryName.isEmpty && !mutableCountryNameArray.containsObject(countryName))
            {
                mutableCountryNameArray.addObject(countryName)
                mutableFinalArray.addObject(localeIdentifier)
            }
        }
        
        return NSMutableArray(array: mutableFinalArray.sortedArrayUsingComparator({obj1, obj2 -> NSComparisonResult in

            let usLocale = NSLocale.init(localeIdentifier : "en_US")

            let locale1 = NSLocale.init(localeIdentifier : obj1 as! String)
            let countryCode1 : String? = locale1.objectForKey(NSLocaleCountryCode) as! String!
            let countryName1 = usLocale.displayNameForKey(NSLocaleCountryCode, value: countryCode1!)  as String!

            let locale2 = NSLocale.init(localeIdentifier : obj2 as! String)
            let countryCode2 : String? = locale2.objectForKey(NSLocaleCountryCode) as! String!
            let countryName2 = usLocale.displayNameForKey(NSLocaleCountryCode, value: countryCode2!)  as String!

            return countryName1.compare(countryName2)
        }))
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - IBActions
    
    @IBAction func onSelectDefaultTipSegment(sender: UISegmentedControl)
    {
        NSUserDefaults.standardUserDefaults().setObject(defaultTipPercentages[sender.selectedSegmentIndex] as String, forKey: kDefaultTipPercentageKey)
    }
    
    //MARK: - UIPickerViewDataSource
    
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        let localeIdentifier = pickerData[row]
        let locale = NSLocale.init(localeIdentifier : localeIdentifier)
        
        let usLocale = NSLocale.init(localeIdentifier : "en_US")
        let countryCode : String? = locale.objectForKey(NSLocaleCountryCode) as! String!
        
        let countryName = (countryCode != nil) ? usLocale.displayNameForKey(NSLocaleCountryCode, value: countryCode!)  as String! : ""
        
        let displayValue = String (format: "%@ (%@)", countryName ?? "", locale.objectForKey(NSLocaleCurrencySymbol) as! String)
        
        return displayValue
    }
    
    //Capture the picker view selection
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        
        NSUserDefaults.standardUserDefaults().setObject(pickerData[row], forKey: kDefaultLocaleIdentifierKey)
    }
}
