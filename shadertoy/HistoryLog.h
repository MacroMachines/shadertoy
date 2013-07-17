//
//  HistoryLog.h
//  AlfaArkiv
//
//  Created by Ralph Seaman on 11/29/12.
//
//

#import <Foundation/Foundation.h>

@interface HistoryLog : NSObject {
   NSMutableArray *history;
   int limit;
}

@property (nonatomic, retain) NSMutableArray *history;

+(HistoryLog*) sharedInstance;
-(void) addLine:(NSString*)line;
-(void) addObject:(id)obj;
-(id) getObject; // return first one



@end
