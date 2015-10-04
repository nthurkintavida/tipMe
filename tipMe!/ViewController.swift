//
//  ViewController.swift
//  tipMe!
//
//  Created by Naseer on 10/3/15.
//  Copyright (c) 2015 Naji. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var billTotalAmountField: UITextField!
    
    @IBOutlet weak var tipSlider: UISlider!
    @IBOutlet weak var tipPercentageLabel: UILabel!
    @IBOutlet weak var tipAmountLabel: UILabel!
    
    @IBOutlet weak var tipAndSplitView: UIView!
    
    @IBOutlet weak var splitTextField: UITextField!
    @IBOutlet weak var splitAddRemoveSegment: UISegmentedControl!
    
    @IBOutlet weak var totalView: UIView!
    
    @IBOutlet weak var totalWithTipLabel: UILabel!
    @IBOutlet weak var totalPerPersonWithTipLabel: UILabel!
    
    @IBOutlet weak var settingsViewController: SettingsViewController!
    
    //MARK: - Initialization
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.initialize()
        tipValueChanged(tipSlider)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)

        self.initializeFromDefaults()
        tipValueChanged(tipSlider)
    }
    
    func initialize()
    {
        self.initializeFromDefaults()

        self.billTotalAmountField.becomeFirstResponder()
        
        self.tipAndSplitView.alpha = 0.0;
        self.totalView.alpha = 0.0;
    }
    
    func initializeFromDefaults()
    {
        self.billTotalAmountField.text = NSUserDefaults.standardUserDefaults().valueForKey(kDefaultBillAmountKey) as? String
        let defaultTipValue = (NSUserDefaults.standardUserDefaults().valueForKey(kDefaultTipPercentageKey) as? String ?? "0.20")._bridgeToObjectiveC().floatValue
        self.tipSlider.value =  defaultTipValue
        self.splitTextField.text = NSUserDefaults.standardUserDefaults().valueForKey(kDefaultSplitValueKey) as? String ?? "1"
    }
    
    func updateValuesToDefaults()
    {
        NSUserDefaults.standardUserDefaults().setObject(billTotalAmountField.text, forKey: kDefaultBillAmountKey)
        NSUserDefaults.standardUserDefaults().setObject(splitTextField.text, forKey: kDefaultSplitValueKey)
        
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - IBAction Methods
    
    @IBAction func onEditing(sender: UITextField)
    {
        self.updateValuesToDefaults()
        
        let enteredBillTotalAmount = billTotalAmountField.text!._bridgeToObjectiveC().doubleValue
        
        let tip = enteredBillTotalAmount * (tipValue()._bridgeToObjectiveC().doubleValue/100)
        tipAmountLabel.text = "\(tip)"
        
        let totalBill = enteredBillTotalAmount + tip
        totalWithTipLabel.text = "\(totalBill)"

        let numberOfPersons = splitTextField.text!._bridgeToObjectiveC().doubleValue
        let totalBillPerPerson = totalBill / numberOfPersons
        
        totalPerPersonWithTipLabel.text = "\(totalBillPerPerson)"
        
        //Show or Hide Tip & Split View
        showOrHideTipAndSplitView((!billTotalAmountField.text!.isEmpty))

        //Show or Hide Total View
        showOrHideTotalView((totalBill > 0))
        
        //formatTextField(billTotalAmountField, formatterStyle: NSNumberFormatterStyle.CurrencyStyle)
    }
    
    
    @IBAction func tipValueChanged(sender: UISlider)
    {
        let tipPercentage = String (format: "(%.0f%%)", tipValue())
        
        tipPercentageLabel.text = "\(tipPercentage)"
        
        onEditing(billTotalAmountField)
    }
    
    
    @IBAction func addRemoveSplit(sender: UISegmentedControl)
    {
        let isAddSegmentPressed = (sender.selectedSegmentIndex == 0);
        
        var numberOfPersons = splitTextField.text!._bridgeToObjectiveC().integerValue
        
        if(isAddSegmentPressed == true)
        {
            //Add
            numberOfPersons++;
        }
        else if(numberOfPersons > 0)
        {
            //Remove
            numberOfPersons--;
        }
        
        splitTextField.text = "\(numberOfPersons)"
        
        onEditing(billTotalAmountField)
    }
    
    @IBOutlet weak var sadSmiley: UIImageView!
    @IBOutlet weak var happySmiley: UIImageView!
    
    
    @IBAction func onTapSadSmiley(sender: AnyObject) {
        onTapSmiley(sadSmiley);
    }
    
    @IBAction func onTapHappySmiley(sender: AnyObject) {
        onTapSmiley(happySmiley);
    }
    
    func onTapSmiley(smileyVew: UIImageView) {
        
        if(smileyVew == happySmiley) //Happy
        {
            tipSlider.value = tipSlider.value + 0.01
        }
        else if(smileyVew == sadSmiley)    //Sad
        {
            tipSlider.value = tipSlider.value - 0.01
        }
        
        tipValueChanged(tipSlider)
    }
    
    
    @IBAction func onTapMainView(sender: AnyObject)
    {
        view.endEditing(true)
    }
    
    //MARK: - UITextFieldDelegate
    // return NO to not change text
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if(textField == billTotalAmountField)
        {
            let rangeOfDots = textField.text!.rangeOfString(".", options: NSStringCompareOptions.LiteralSearch, range: nil, locale: nil)
            return !(rangeOfDots?.isEmpty == false && string == ".")
        }

        return true;
    }
    
    //MARK: - Misc methods
    func tipValue() -> Float
    {
        return tipSlider.value*100
    }

    func formatTextField(label: AnyObject, formatterStyle : NSNumberFormatterStyle)
    {
        var numberFromField = 0.00
        let formatter = NSNumberFormatter()
        
        formatter.numberStyle = formatterStyle
        
        let localeIdentiier = NSUserDefaults.standardUserDefaults().valueForKey(kDefaultLocaleIdentifierKey) as? String ?? "es_US"
        
        formatter.locale = NSLocale(localeIdentifier: localeIdentiier)
        
        if let myLabel = label as? UILabel
        {
            numberFromField = myLabel.text!._bridgeToObjectiveC().doubleValue
            myLabel.text = formatter.stringFromNumber(numberFromField)
        }
        else if let myLabel = label as? UITextField
        {
            numberFromField = myLabel.text!._bridgeToObjectiveC().doubleValue
            myLabel.text = formatter.stringFromNumber(numberFromField)
        }
    }
    
    func showOrHideTipAndSplitView(showTipAndSplitView: Bool)
    {
        UIView.animateWithDuration(0.8, animations: {
            //Display tipAndSplitView
            if(showTipAndSplitView)
            {
                self.tipAndSplitView.alpha = 1.0;
                
                //Format all the labels
                self.formatTextField(self.tipAmountLabel, formatterStyle: NSNumberFormatterStyle.CurrencyStyle)
            }
            else
            {
                self.tipAndSplitView.alpha = 0.0;
            }
        });
    }
    
    func showOrHideTotalView(showTotalView: Bool)
    {
        UIView.animateWithDuration(1.2, animations: {
            if(showTotalView)
            {
                self.totalView.alpha = 1.0;
                
                //Format all the labels
                self.formatTextField(self.totalWithTipLabel, formatterStyle: NSNumberFormatterStyle.CurrencyStyle)
                self.formatTextField(self.totalPerPersonWithTipLabel, formatterStyle: NSNumberFormatterStyle.CurrencyStyle)
            }
            else
            {
                //Hide totalView
                self.totalView.alpha = 0.0;
            }
        });
    }
    

}

