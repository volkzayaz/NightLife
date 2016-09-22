//
//  CommentsByLocationViewModel.swift
//  GlobBar
//
//  Created by Anna Gorobchenko on 22.09.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import Alamofire
import RxAlamofire
import ObjectMapper
import CoreLocation

extension Array {
    
    func filterDuplicates(@noescape includeElement: (lhs:Element, rhs:Element) -> Bool) -> [Element]{
        var results = [Element]()
        
        forEach { (element) in
            let existingElements = results.filter {
                return includeElement(lhs: element, rhs: $0)
            }
            //if existingElements.count == 0 {
                results.append(element)
            //}
        }
        
        return results
    }
}


struct CommentsByLocationViewModel {
    
    private let geoCoder = CLGeocoder()
    var cityLocation : String?
    
    var displayData: Variable<[CommentsSection]> = Variable([])
   // let detailMessageViewModel: Variable<MessageViewModel?> = Variable(nil)
    
    var indexArray : Int = 0
    
    //var commentTemp : Comment?
    
    private let bag = DisposeBag()
    
//    var commentCountObservable : Observable<Int> {
//        
//        return Observable.just((InMemoryStorageArray.storage[indexArray]?.value.count)!)
//        
//    }
//    
    init() {
        
        
        let commentedMessages = MessagesContext.messages
            .asObservable()
            .flatMapLatest { (messages : [Message]) -> Observable<[Message]> in
                messages
                    .flatMap { (message : Message) in
                        message.observableEntity()?.asObservable()
                    }
                    .combineLatest { commentedMessages in
                        
                        let commentedMessages : [Message] = commentedMessages.filter { InMemoryStorageArray.storage[$0.id]?.value.count > 0
                            
                        }
                   
                        return commentedMessages
                }
        }
        
        
        let commentsLocated = commentedMessages.map { (messages : [Message]) -> [Comment] in
            return messages.flatMap { (message : Message) -> [Comment] in
               return (InMemoryStorageArray.storage[message.id]?.value)!
               
            }
           
        }
        
            
//        let sortedComments = commentsLocated.map{ (comments : [Comment]) -> [Comment] in
//          
//           return comments.sort{ $0.0.location == $0.1.location }
//
//        }
        
        commentsLocated.map { (comments : [Comment]) -> [ViewModelCommentCell] in
            
            let viewModelCommentCells : [ViewModelCommentCell] = comments.map { (comment : Comment) -> ViewModelCommentCell in
                return ViewModelCommentCell(comment: comment)
            }
            
            return viewModelCommentCells
            }.map { (cells : [ViewModelCommentCell]) -> [CommentsSection] in
                
                let a = cells.filterDuplicates{ $0.0.comment.location == $0.1.comment.location }
                
                
                        var data = [CommentsSection]()

                
                        data.append(CommentsSection(header : String(a.first?.comment.location!.coordinate), items : a))
                        print(data.count)
                
                        
                        return data
                
//                self.geoCoder.reverseGeocodeLocation((a.first?.comment.location!)!)
//                {
//                    (placemarks, error) -> Void in
//                    
//                    let placeArray = placemarks as [CLPlacemark]!
//                    let placeMark: CLPlacemark! = placeArray.first
//                    
//                    
//                    if let city = placeMark.addressDictionary?["City"] as? String
//                    {
//                      self.cityLocation = city
//                        //print(city)
//                        print(self.cityLocation)
//
//                       
//                        
//                    }
//                    
//                    
//                }

               // return [CommentsSection (header : "Comments", items : a)]
            }
            .subscribeNext { (sections: [CommentsSection]) in
                
                self.displayData.value = sections
            }
            .addDisposableTo(bag)
        
    }
    
    
}



extension CommentsByLocationViewModel {
    
//    TODO : segue to Detail Message View Controller with selected comment
    
    func selectedComment(atIndexPath ip: NSIndexPath) {
//        let message = displayData.value.first?.items[ip.row].message
//        detailMessageViewModel.value = MessageViewModel(message: message!)
        
    }
    
    func deleteComment(row: Int, value : ViewModelCommentCell) {
        
        let comment = value.comment
        
        //indexArray = row
        let index = InMemoryStorageArray.storage[comment.messageId]?.value.indexOf(comment)
        
        //print(index)
        
        InMemoryStorageArray.storage[comment.messageId]?.value.removeAtIndex(index!)
        
    }
    
    
}

