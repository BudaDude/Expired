//
//  AddFoodViewController.swift
//  Expired
//
//  Created by George Nance on 5/6/16.
//  Copyright © 2016 George Nance. All rights reserved.
//

import UIKit
import RealmSwift

class AddFoodViewController: UITableViewController, UIPickerViewDelegate,UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var foodTypeLabel: UILabel!
    @IBOutlet weak var foodTypePicker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBAction func deleteButtonPressed(sender: AnyObject) {
        
        let ac = UIAlertController(title: "Delete \(food.name)", message: "Are you sure you want to delete this food item?", preferredStyle: .ActionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let delete = UIAlertAction(title: "Delete", style: .Destructive, handler:{
            (action) in
            self.store.removeItem(self.food)
            self.navigationController?.popToRootViewControllerAnimated(true)
        })
        ac.addAction(cancel)
        ac.addAction(delete)
        presentViewController(ac, animated: true, completion: nil)

    }
    

    
    var store:FoodStore!
    var food: FoodItem!
    
    let realm = try! Realm()
    
    var date: NSDate = NSDate()
    
    let dateFormatter : NSDateFormatter = {
        let dateFormat = NSDateFormatter()
        dateFormat.dateStyle = .MediumStyle
        dateFormat.timeStyle = .NoStyle
        return dateFormat
    }()
    
    var editingFood: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if (food == nil){
            food = FoodItem()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        foodTypePicker.dataSource = self
        foodTypePicker.delegate = self
        nameTextField.delegate = self
        datePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard:"))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        nameTextField.addTarget(self, action: Selector("textFieldChanged:"), forControlEvents: UIControlEvents.EditingChanged)
    }

    override func viewWillAppear(animated: Bool) {
        foodTypePicker.hidden = true
        datePicker.hidden = true

        if editingFood == false{

            
        }
        //MARK: Set fields equl to food values
        if (editingFood){
            nameTextField.text = food!.name
            foodTypePicker.selectRow(store.foodTypes.indexOf(food.foodType)!, inComponent: 0, animated: false)
            datePicker.date = food!.expirationDate
            
            date = food.expirationDate

        }else{
            deleteButton.hidden = true
            saveButton.enabled = false
            let tomorrow = 60 * 60 * 24 * 7.0
            datePicker.date = NSDate(timeIntervalSinceNow: tomorrow)
        }
        foodTypeLabel.text = store.foodTypes[foodTypePicker.selectedRowInComponent(0)].name
        dateLabel.text = dateFormatter.stringFromDate(datePicker.date)
        
    }
    
    func dismissKeyboard(gesture: UITapGestureRecognizer) {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldChanged(textField:UITextField){
        saveButton.enabled=textField.text!.characters.count > 0
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert , .Badge , .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        if (editingFood){
            try! realm.write(){
            food.name = nameTextField.text!
            food.expirationDate = date
            food.foodType = store.foodTypes[foodTypePicker.selectedRowInComponent(0)]
            }
        }else{
            food.name = nameTextField.text!
            food.expirationDate = date
            food.foodType = store.foodTypes[foodTypePicker.selectedRowInComponent(0)]
            store.addFood(food)
        }
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func validateFields()-> Bool{
        return (nameTextField.text != nil)
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat = 44;
        
        if indexPath.row == 1{
            height = foodTypePicker.hidden ? 0:216
        }else if indexPath.row == 3{
            height = datePicker.hidden ? 0:216
        }
        
        if indexPath == NSIndexPath(forItem: 0, inSection: 2){
            height = editingFood ? 44:0
        }
        return height;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        
        if indexPath.row == 0 {
            
            foodTypePicker.hidden = !foodTypePicker.hidden
            datePicker.hidden = true

        }else if indexPath.row == 2{
            datePicker.hidden = !datePicker.hidden
            foodTypePicker.hidden = true
        }else{
            datePicker.hidden = true
            foodTypePicker.hidden = true
        }
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.tableView.beginUpdates()
            // apple bug fix - some TV lines hide after animation
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            self.tableView.endUpdates()
        })
    }
    
    func datePickerChanged(datePicker: UIDatePicker){
        date = datePicker.date
        dateLabel.text = dateFormatter.stringFromDate(date)
    }
    

    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return store.foodTypes.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return store.foodTypes[row].name
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        foodTypeLabel.text = store.foodTypes[row].name
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
