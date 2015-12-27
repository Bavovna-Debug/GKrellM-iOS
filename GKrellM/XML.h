//
//  GKrellM
//
//  Copyright (c) 2014-2015 Meine Werke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(MD5)

- (NSString *)MD5;

@end

@class XMLElement;

@interface XMLDocument : NSObject

@property (nonatomic, strong, readonly) NSString *target;
@property (nonatomic, strong, readonly) NSString *documentVersion;

@property (nonatomic, strong, readwrite) XMLElement *forest;

+ (XMLDocument *)documentWithTarget:(NSString *)target
                            version:(NSString *)documentVersion;

+ (XMLDocument *)documentFromData:(NSData *)data;

- (NSData *)xmlData;

- (NSString *)string;

@end

@interface XMLElement : NSObject

@property (nonatomic, strong, readwrite) NSString             *name;
@property (nonatomic, strong, readwrite) NSMutableDictionary  *attributes;
@property (nonatomic, strong, readwrite) NSString             *content;
@property (nonatomic, strong, readonly)  NSMutableArray       *elements;

+ (XMLElement *)elementWithName:(NSString *)name;

- (void)addElement:(XMLElement *)element;

- (XMLElement *)elementByPath:(NSString *)path;

@end
