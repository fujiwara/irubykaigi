//
//  Speaker.h
//  iRubyKaigiTest
//
//  Created by Katsuyoshi Ito on 10/06/01.
//

/* 

  Copyright 2010 ITO SOFT DESIGN Inc. All rights reserved.

  Redistribution and use in source and binary forms, with or without modification,
  are permitted provided that the following conditions are met:
  
      * Redistributions of source code must retain the above copyright notice,
        this list of conditions and the following disclaimer.
 
      * Redistributions in binary form must reproduce the above copyright notice,
        this list of conditions and the following disclaimer in the documentation
        and/or other materials provided with the distribution.
 
      * Neither the name of ITO SOFT DESIGN Inc. nor the names of its
        contributors may be used to endorse or promote products derived from this
        software without specific prior written permission.
 
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/

#import <CoreData/CoreData.h>

@class LightningTalk;
@class Region;
@class Session;

@interface Speaker :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSSet* lightningTalks;
@property (nonatomic, retain) NSSet* sessions;
@property (nonatomic, retain) Region * region;
@property (nonatomic, retain) NSString * profile;
@property (nonatomic, retain) NSSet* belongings;

@property (assign, readonly) NSArray *sortedSession;
@property (assign, readonly) NSString *firstLetterOfName;
@property (assign, readonly) NSString *upperCaseName;

@property (assign, readonly) NSArray* sortedBelongings;


+ (Speaker *)speakerWithCode:(NSString *)code region:(Region *)region inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Speaker *)speakerWithCode:(NSString *)code region:(Region *)region;

+ (Speaker *)findByName:(NSString *)name region:(Region *)region;
+ (Speaker *)findByName:(NSString *)name region:(Region *)region inManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSArray *)belongingsFromString:(NSString *)string;

- (Speaker *)speakerForRegion:(Region *)region;

@end

// coalesce these into one @interface Speaker (CoreDataGeneratedAccessors) section
@interface Speaker (CoreDataGeneratedAccessors)
- (void)addSessionsObject:(Session *)value;
- (void)removeSessionsObject:(Session *)value;
- (void)addSessions:(NSSet *)value;
- (void)removeSessions:(NSSet *)value;

- (void)addLightningTalksObject:(LightningTalk *)value;
- (void)removeLightningTalksObject:(LightningTalk *)value;
- (void)addLightningTalks:(NSSet *)value;
- (void)removeLightningTalks:(NSSet *)value;

- (void)addBelongingsObject:(NSManagedObject *)value;
- (void)removeBelongingsObject:(NSManagedObject *)value;
- (void)addBelongings:(NSSet *)value;
- (void)removeBelongings:(NSSet *)value;
@end

