//
//  LightningTalk.h
//  iRubyKaigi2009Test
//
//  Created by Katsuyoshi Ito on 09/07/08.
//

/* 

  Copyright 2009 ITO SOFT DESIGN Inc. All rights reserved.

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

#import <Foundation/Foundation.h>

@class Session;
@class Speaker;
@class Room;
@class Day;
@class Region;
@class Archive;

@interface LightningTalk : NSManagedObject {

}

@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;

@property (nonatomic, retain) Session * session;
@property (nonatomic, retain) NSSet* speakers;

@property (assign, readonly) NSString *code;
@property (nonatomic, retain) NSSet* archives;

// Session
@property (assign, readonly) Day *day;
@property (assign, readonly) NSString *time;
@property (assign, readonly) NSString *dayTimeTitle;
@property (assign, readonly) Room *room;

@property (assign, readonly) NSArray *sortedSpeakers;
@property (assign, readonly) NSArray *sortedArchives;

- (LightningTalk *)lightningTalkForRegion:(Region *)region;

@end

// coalesce these into one @interface LightningTalk (CoreDataGeneratedAccessors) section
@interface LightningTalk (CoreDataGeneratedAccessors)
- (void)addSpeakersObject:(Speaker *)value;
- (void)removeSpeakersObject:(Speaker *)value;
- (void)addSpeakers:(NSSet *)value;
- (void)removeSpeakers:(NSSet *)value;

- (void)addArchivesObject:(Archive *)value;
- (void)removeArchivesObject:(Archive *)value;
- (void)addArchives:(NSSet *)value;
- (void)removeArchives:(NSSet *)value;
@end

