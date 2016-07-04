//
//  UserStorage.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/10/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import ObjectMapper

struct e_storage_state {
    
    static let e_storage_key = "com.ermineAuthentication.User"
    static var e_cur_user_id : Int? = nil
    
}

extension UserProtocol {
    
    func saveLocally() -> Void {
        
        let data = Mapper().toJSONString(self)
        
        ///updating base identifier value
        e_storage_state.e_cur_user_id = self.identifier
        
        ///updating User storage value to notify parties about changes
        self.saveEntity()
        
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: e_storage_state.e_storage_key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    
    static func loginWithData(data: AnyObject) -> Self {
        
        let mapper : Mapper<Self> = Mapper()
        
        guard let user = mapper.map(data)
            else {
                assert(false, "Couldn't map json to User. Please check mapping between JSON and User");
                return self.currentUser()!
        }
        user.saveLocally()
        
        return user
        
    }
    
    static func currentUser() -> Self? {
        
        if let currentUserId = e_storage_state.e_cur_user_id,
           let user = User.entityByIdentifier(currentUserId) {
            return user as? Self
        }
        
        guard let storedValue = NSUserDefaults.standardUserDefaults().objectForKey(e_storage_state.e_storage_key) as? NSString else {
            return nil
        }
        
        let mapper : Mapper<Self> = Mapper()
        guard let cachedUser = mapper.map(storedValue) else {
            fatalError("Disk user entry is incompatible with Mappable model")
        }
        e_storage_state.e_cur_user_id = cachedUser.identifier
        cachedUser.saveEntity()
        
        return cachedUser
    }
    
    func logout() {
        User.currentUser()?.removeFromStorage()
        
        e_storage_state.e_cur_user_id = nil
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey(e_storage_state.e_storage_key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
}
