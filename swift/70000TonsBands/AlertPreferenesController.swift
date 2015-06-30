//
//  AlertPreferenesController.swift
//  70K Bands
//
//  Created by Ron Dorn on 2/14/15.
//  Copyright (c) 2015 Ron Dorn. All rights reserved.
//

import Foundation
import UIKit

class AlertPreferenesController: UIViewController, UITextFieldDelegate {
    
    var mustSeeAlertValue = Bool()
    var mightSeeAlertValue = Bool()
    var alertForShowsValue = Bool()
    var alertForSpecialValue = Bool()
    var alertForMandGValue = Bool()
    var alertForClinicsValue = Bool()
    var alertForListeningValue = Bool()
    var minBeforeAlertValue = Double()
    
    var minBeforeAlertLabel = String()
    
    @IBOutlet weak var AlertOnMustSee: UISwitch!
    @IBOutlet weak var AlertOnMightSee: UISwitch!
    @IBOutlet weak var AlertForShows: UISwitch!
    @IBOutlet weak var AlertForSpecialEvents: UISwitch!
    @IBOutlet weak var AlertForMeetAndGreets: UISwitch!
    @IBOutlet weak var AlertForClinic: UISwitch!
    @IBOutlet weak var AlertForListeningEvent: UISwitch!
    @IBOutlet weak var MinBeforeAlert: UITextField!
    @IBOutlet weak var UseLastYearsData: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setExistingValues()
        
    }
    
    func setExistingValues (){
        
        mustSeeAlertValue = defaults.boolForKey("mustSeeAlert")
        mightSeeAlertValue = defaults.boolForKey("mightSeeAlert")
        alertForShowsValue = defaults.boolForKey("alertForShows")
        alertForSpecialValue = defaults.boolForKey("alertForSpecial")
        alertForMandGValue = defaults.boolForKey("alertForMandG")
        alertForClinicsValue = defaults.boolForKey("alertForClinics")
        alertForListeningValue = defaults.boolForKey("alertForListening")
        minBeforeAlertValue = Double(defaults.integerForKey("minBeforeAlert"))
        
        AlertOnMustSee.on = mustSeeAlertValue
        AlertOnMightSee.on = mightSeeAlertValue
        
        MinBeforeAlert.text = String(format: "%.0f", minBeforeAlertValue)
        AlertForShows.on = alertForShowsValue
        AlertForSpecialEvents.on = alertForSpecialValue
        AlertForMeetAndGreets.on = alertForMandGValue
        AlertForClinic.on = alertForClinicsValue
        AlertForListeningEvent.on = alertForListeningValue
        
        self.MinBeforeAlert.delegate = self
        
        if (defaults.stringForKey("scheduleUrl") == lastYearsScheduleUrlDefault){
            UseLastYearsData.on = true
        } else {
            UseLastYearsData.on = false
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
    @IBAction func MinBeforeAlertAction() {
        
        var minBeforeAlertTemp = MinBeforeAlert.text.toInt()
        
        if (minBeforeAlertTemp >= 0 && minBeforeAlertTemp <= 60){
            defaults.setInteger(minBeforeAlertTemp!, forKey: "minBeforeAlert")
            MinBeforeAlert.resignFirstResponder()
            
        } else {
            
            MinBeforeAlert.resignFirstResponder()
            MinBeforeAlert.text = String(format: "%.0f", minBeforeAlertValue)
            let alert = UIAlertView()
            alert.title = "Number Provided Is Invalid"
            alert.message =  "Number Provided Is Invalid\nMust be a value between 0 and 60"
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
        
    }
    
    @IBAction func MustSeeChange() {
        defaults.setBool(AlertOnMustSee.on, forKey: "mustSeeAlert")
    }
    
    @IBAction func MightSeeChange() {
        defaults.setBool(AlertOnMightSee.on, forKey: "mightSeeAlert")
    }
    
    @IBAction func AlertForShowsChange() {
        defaults.setBool(AlertForShows.on, forKey: "alertForShows")
    }
    
    @IBAction func AlertForSpecialEventChange() {
        defaults.setBool(AlertForSpecialEvents.on, forKey: "alertForSpecial")
    }
    
    @IBAction func AlertForMeetAndGreetChange() {
        defaults.setBool(AlertForMeetAndGreets.on, forKey: "alertForMandG")
    }
    
    @IBAction func AlertForClinicChange() {
        defaults.setBool(AlertForClinic.on, forKey: "alertForClinics")
    }
    
    @IBAction func AlertForListeningEventChange() {
        defaults.setBool(AlertForListeningEvent.on, forKey: "alertForListening")
    }
    
    @IBAction func backgroundTap (sender: UIControl){
        MinBeforeAlert.resignFirstResponder()
    }
    
    @IBAction func UseLastYearsDataAction() {
        
        let alert: UIAlertView = UIAlertView()
        alert.title = "Restart Required"
        alert.message = "DO NOT DO THIS ON THE CRUISE. INTERENT CONNECTION REQUIRED.\nThis change requires restarting the application.\n70K Bands will now quit. Relaunch to see the new data"
        let yesBut = alert.addButtonWithTitle("Cancel")
        let noBut = alert.addButtonWithTitle("Ok")
        alert.delegate = self  // set the delegate here
        alert.show()
        
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        let buttonTitle = alertView.buttonTitleAtIndex(buttonIndex)
        println("\(buttonTitle) pressed")
        if buttonTitle == "Ok" {
            
            var convertDates = ConvertScheduleToCurrentWeek()
            
            //remove existing schedule file
            String().writeToFile(scheduleFile, atomically: false, encoding: NSUTF8StringEncoding)
            schedule = scheduleHandler()
            
            if (UseLastYearsData.on == true){
                defaults.setValue(lastYearsartistUrlDefault, forKey: "artistUrl")
                defaults.setValue(lastYearsScheduleUrlDefault, forKey: "scheduleUrl")
                byPassCsvDownloadCheck = true
                schedule.DownloadCsv()
                convertDates.convertScheduleCSV()
                
            } else {
                defaults.setValue(artistUrlDefault, forKey: "artistUrl")
                defaults.setValue(scheduleUrlDefault, forKey: "scheduleUrl")
            }
            
            //clear all existing notifications
            var localNotification = localNoticationHandler()
            localNotification.clearNotifications();
            
            exit(0)
            
        } else {
            if (UseLastYearsData.on == true){
                UseLastYearsData.on = false
                
            } else {
                UseLastYearsData.on = true
            }
        }
    }
    
}