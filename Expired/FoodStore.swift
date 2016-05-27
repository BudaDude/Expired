//
//  FoodStore.swift
//  Expired
//
//  Created by George Nance on 3/23/16.
//  Copyright © 2016 George Nance. All rights reserved.
//

import Foundation
import RealmSwift


class FoodStore {
    
    lazy var allFoods: Results<FoodItem> = {self.realm.objects(FoodItem)}()
    let realm = try! Realm()
    
    lazy var foodTypes : Results<FoodType> = {self.realm.objects(FoodType)}()
    
    init(){
        
        populateFoodTypes()
    }
    
    func populateFoodTypes(){
        if foodTypes.count == 0{
            try! realm.write(){
                let defaultFoodTypes = ["Fruit","Dairy","Grain","Meat","Vegetable"]
                for type in defaultFoodTypes{
                    let newType = FoodType()
                    newType.name = type
                    self.realm.add(newType)
                }
            }
            foodTypes = realm.objects(FoodType)
        }
    }
    
    
    func addFood(food:FoodItem){
        try! realm.write(){
            food.id = NSUUID().UUIDString
            self.realm.add(food)
            setNotification(food)
        }

        allFoods = realm.objects(FoodItem)
        
    }
    func getItem(index:Int)->FoodItem{
        return allFoods[index]
        
    }
    
    func removeItem(food:FoodItem){
        try! realm.write(){
        realm.delete(food)
        }
        allFoods = realm.objects(FoodItem)
    }
    
    func expiredFoods()->[FoodItem]{
        var foods = [FoodItem]()
        
        for item in allFoods {
            if (item.isExpired()){
                foods.append(item)
            }
        }
        return foods
    }
    
    func setNotification(food:FoodItem){
        
        guard let settings = UIApplication.sharedApplication().currentUserNotificationSettings() else { return }
        
        let calendar = NSCalendar.currentCalendar()
        let date = calendar.components([.Day , .Month , .Year], fromDate: food.expirationDate)
        
        let components = NSDateComponents()
        components.year = date.year
        components.month = date.month
        components.day = date.day
        components.hour = 11
        components.minute = 00
        components.second = 0
        
        let notifyDate = calendar.dateFromComponents(components)
        
        let notification = UILocalNotification()
        notification.fireDate = notifyDate
        notification.alertBody = "\(food.name) will be expiring soon!"
        notification.alertAction = "view"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["Object": food.id]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func expiringThisWeek()->[FoodItem]{
        var foods = [FoodItem]()
        
        for item in allFoods {
            if (item.expirationDate.numberOfDaysUntilDateTime(NSDate()) < 7){
                foods.append(item)
            }
        }
        foods.sortInPlace({$0.expirationDate.compare($1.expirationDate)==NSComparisonResult.OrderedAscending})
        return foods
    }
    
    func itemsNotListedYet(foodItems:[FoodItem])->[FoodItem]{
        var foods = [FoodItem]()
        
        for item in allFoods {
            if (!foodItems.contains(item)){
                foods.append(item)
            }
        }
        return foods
    }
}




