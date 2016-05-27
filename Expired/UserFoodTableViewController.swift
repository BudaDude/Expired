//
//  UserFoodTableViewController.swift
//  Expired
//
//  Created by George Nance on 5/6/16.
//  Copyright © 2016 George Nance. All rights reserved.
//

import UIKit

class UserFoodTableViewController: UITableViewController {

    var store: FoodStore!
    
    let dateFormatter : NSDateFormatter = {
        let dateFormat = NSDateFormatter()
        dateFormat.dateStyle = .MediumStyle
        dateFormat.timeStyle = .NoStyle
        return dateFormat
    }()
    
    var expiredItems = [FoodItem]()
    var expiringSoonItems = [FoodItem]()
    var remainingItems = [FoodItem]()
    
    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        expiredItems.removeAll()
        expiringSoonItems.removeAll()
        remainingItems.removeAll()
        
        for item in store.allFoods {
            if (item.isExpired()){
                expiredItems.append(item)
            }else if (item.daysUntillExpiration() < 7){
                expiringSoonItems.append(item)
            }else{
                remainingItems.append(item)
            }
        }
        expiredItems.sortInPlace({$0.daysUntillExpiration() < $1.daysUntillExpiration()})
        expiringSoonItems.sortInPlace({$0.daysUntillExpiration() < $1.daysUntillExpiration()})
        remainingItems.sortInPlace({$0.daysUntillExpiration() < $1.daysUntillExpiration()})
        tableView.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addFood"{
         let addView = segue.destinationViewController as? AddFoodViewController
            addView?.navigationItem.title = "Add New Food"
            addView?.store = store
            addView?.editingFood = false
        }else if segue.identifier == "editFood"{
            let addView = segue.destinationViewController as? AddFoodViewController
            addView?.navigationItem.title = "Editing Food"
            addView?.store = store
            addView?.editingFood = true
            
            if let path = tableView.indexPathForSelectedRow{
                switch(path.section){
                case 0:
                    addView?.food = self.expiredItems[path.row]
                case 1:
                    addView?.food = self.expiringSoonItems[path.row]
                case 2:
                    addView?.food = self.remainingItems[path.row]
                default:
                    break
                }
            }

        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections

        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch(section){
        case 0:
            return expiredItems.count
  
        case 1:
            return expiringSoonItems.count
        case 2:
            return remainingItems.count
        default:
            break
        }
        return 0
    }
    

    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch(section){
        case 0:
            return (expiredItems.count > 0) ? 44:0
        case 1:
            return (expiringSoonItems.count > 0) ? 44:0
        default:
            return (remainingItems.count > 0) ? 22:0
        }

    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("foodCell", forIndexPath: indexPath) as! FoodCell
        

        



        
        switch(indexPath.section){
        case 0:
            let food = expiredItems[indexPath.row]
            cell.foodNameLabel?.text = food.name
            cell.expirationDateLabel?.text = "Expired \(abs(food.daysUntillExpiration())) days ago"
            cell.expirationDateLabel?.textColor = UIColor.redColor()
            
            if let image = UIImage(named:food.foodType.name) {
                cell.foodImage.image = image
            }
        case 1:
            let food = expiringSoonItems[indexPath.row]
            cell.foodNameLabel?.text = food.name
            cell.expirationDateLabel?.text = "Expiring in \(food.daysUntillExpiration()) days"
            cell.expirationDateLabel?.textColor = UIColor.orangeColor()
            
            if let image = UIImage(named:food.foodType.name) {
                cell.foodImage.image = image
            }
        default:
            let food = remainingItems[indexPath.row]
            cell.foodNameLabel?.text = food.name
            cell.expirationDateLabel?.text = "Expiring in \(food.daysUntillExpiration()) days"
            cell.expirationDateLabel?.textColor = UIColor.blackColor()
            timeAhead(food.expirationDate)
            if let image = UIImage(named:food.foodType.name) {
                cell.foodImage.image = image
            }
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var name = ""
        
        switch(section){
        case 0:
            name = "Expired"
        case 1:
            name = "Expiring Soon"
        case 2:
            name = "Foods"
        default:
            break
        }
        
        return name
    }
    

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            var food: FoodItem
            
            switch(indexPath.section){
            case 0:
                food = expiredItems[indexPath.row]
                expiredItems.removeAtIndex(indexPath.row)
                break
            case 1:
                food = expiringSoonItems[indexPath.row]
                expiringSoonItems.removeAtIndex(indexPath.row)
                break
            default:
                food = remainingItems[indexPath.row]
                remainingItems.removeAtIndex(indexPath.row)
                break
            }

            store.removeItem(food)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.reloadData()

            
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
