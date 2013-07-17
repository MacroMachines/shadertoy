//
//  HistoryLog.m
//  AlfaArkiv
//
//  Created by Ralph Seaman on 11/29/12.
//
//

#import "HistoryLog.h"

@implementation HistoryLog
@synthesize history;

+(HistoryLog*) sharedInstance {
   static HistoryLog *sharedInstance = nil;

   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
      sharedInstance = [[HistoryLog alloc] init];
   });

   return sharedInstance;
}

-(id) init {

   self = [super init];
   if(self ) {

         // make a max o

      limit = 300;
      history = [[NSMutableArray alloc ] initWithCapacity:limit];

   }
   return self;

}


-(void) addLine:(NSString*)line {
   if(history.count < limit){
   } else {
      [history removeObjectAtIndex:0];
   }
   [history addObject:line];
}

-(void) addObject:(id)obj {
   if(history.count < limit){
   } else {
      [history removeObjectAtIndex:0];
   }
   [history addObject:obj];
}

-(id) getObject{
   return [history objectAtIndex:0];
}


- (NSString*) description {
   NSString *returnval = @"";
   for( NSString *str in history){
      returnval = [returnval stringByAppendingString:str];

   }
   return [returnval copy];
}

@end
