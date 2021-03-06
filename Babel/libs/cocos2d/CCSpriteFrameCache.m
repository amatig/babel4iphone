/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Jason Booth
 * Copyright (C) 2009 Robert J Payne
 * Copyright (C) 2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

/*
 * To create sprite frames and texture atlas, use this tool:
 * http://zwoptex.zwopple.com/
 */

#import "ccMacros.h"
#import "CCTextureCache.h"
#import "CCSpriteFrameCache.h"
#import "CCSpriteFrame.h"
#import "CCSprite.h"
#import "Support/CCFileUtils.h"


@implementation CCSpriteFrameCache

#pragma mark CCSpriteFrameCache - Alloc, Init & Dealloc

static CCSpriteFrameCache *sharedSpriteFrameCache_=nil;

+ (CCSpriteFrameCache *)sharedSpriteFrameCache
{
	if (!sharedSpriteFrameCache_)
		sharedSpriteFrameCache_ = [[CCSpriteFrameCache alloc] init];
		
	return sharedSpriteFrameCache_;
}

+(id)alloc
{
	NSAssert(sharedSpriteFrameCache_ == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

+(void)purgeSharedSpriteFrameCache
{
	[sharedSpriteFrameCache_ release];
}

-(id) init
{
	if( (self=[super init]) ) {
		spriteFrames = [[NSMutableDictionary alloc] initWithCapacity: 100];
	}
	
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | num of sprite frames =  %i>", [self class], self, [spriteFrames count]];
}

-(void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
	
	[spriteFrames release];
	[super dealloc];
}

#pragma mark CCSpriteFrameCache - loading sprite frames

-(void) addSpriteFramesWithDictionary:(NSDictionary*)dictionary texture:(CCTexture2D*)texture
{
	/*
	Supported Zwoptex Formats:
		enum {
			ZWTCoordinatesListXMLFormat_Legacy = 0
			ZWTCoordinatesListXMLFormat_v1_0,
		};
	*/
	NSDictionary *metadataDict = [dictionary objectForKey:@"metadata"];
	NSDictionary *framesDict = [dictionary objectForKey:@"frames"];
	int format = 0;
	
	// get the format
	if(metadataDict != nil) {
		format = [[metadataDict objectForKey:@"format"] intValue];
	}
	
	// check the format
	if(format < 0 || format > 1) {
		NSAssert(NO,@"cocos2d: WARNING: format is not supported for CCSpriteFrameCache addSpriteFramesWithDictionary:texture:");
		return;
	}
	
	for(NSString *frameDictKey in framesDict) {
		NSDictionary *frameDict = [framesDict objectForKey:frameDictKey];
		CCSpriteFrame *spriteFrame;
		if(format == 0) {
			float x = [[frameDict objectForKey:@"x"] floatValue];
			float y = [[frameDict objectForKey:@"y"] floatValue];
			float w = [[frameDict objectForKey:@"width"] floatValue];
			float h = [[frameDict objectForKey:@"height"] floatValue];
			float ox = [[frameDict objectForKey:@"offsetX"] floatValue];
			float oy = [[frameDict objectForKey:@"offsetY"] floatValue];
			int ow = [[frameDict objectForKey:@"originalWidth"] intValue];
			int oh = [[frameDict objectForKey:@"originalHeight"] intValue];
			// check ow/oh
			if(!ow || !oh) {
				CCLOG(@"cocos2d: WARNING: originalWidth/Height not found on the CCSpriteFrame. AnchorPoint won't work as expected. Regenrate the .plist");
			}
			// abs ow/oh
			ow = abs(ow);
			oh = abs(oh);
			// create frame
			spriteFrame = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(x, y, w, h) offset:CGPointMake(ox, oy) originalSize:CGSizeMake(ow, oh)];
		} else if(format == 1) {
			CGRect frame = CGRectFromString([frameDict objectForKey:@"frame"]);
			CGPoint offset = CGPointFromString([frameDict objectForKey:@"offset"]);
			CGSize sourceSize = CGSizeFromString([frameDict objectForKey:@"sourceSize"]);
			/*
			CGRect sourceColorRect = CGRectFromString([frameDict objectForKey:@"sourceColorRect"]);
			int leftTrim = sourceColorRect.origin.x;
			int topTrim = sourceColorRect.origin.y;
			int rightTrim = sourceColorRect.size.width + leftTrim;
			int bottomTrim = sourceColorRect.size.height + topTrim;
			*/
			// create frame
			spriteFrame = [CCSpriteFrame frameWithTexture:texture rect:frame offset:offset originalSize:sourceSize];
		}
		// add sprite frame
		[spriteFrames setObject:spriteFrame forKey:frameDictKey];
	}
	
}

-(void) addSpriteFramesWithFile:(NSString*)plist texture:(CCTexture2D*)texture
{
	NSString *path = [CCFileUtils fullPathFromRelativePath:plist];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];

	return [self addSpriteFramesWithDictionary:dict texture:texture];
}

-(void) addSpriteFramesWithFile:(NSString*)plist
{
	NSString *path = [CCFileUtils fullPathFromRelativePath:plist];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	
	NSString *texturePath = [NSString stringWithString:plist];
	texturePath = [texturePath stringByDeletingPathExtension];
	texturePath = [texturePath stringByAppendingPathExtension:@"png"];
	
	CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:texturePath];
	
	return [self addSpriteFramesWithDictionary:dict texture:texture];
}

-(void) addSpriteFrame:(CCSpriteFrame*)frame name:(NSString*)frameName
{
	[spriteFrames setObject:frame forKey:frameName];
}

#pragma mark CCSpriteFrameCache - removing

-(void) removeSpriteFrames
{
	[spriteFrames removeAllObjects];
}

-(void) removeUnusedSpriteFrames
{
	NSArray *keys = [spriteFrames allKeys];
	for( id key in keys ) {
		id value = [spriteFrames objectForKey:key];		
		if( [value retainCount] == 1 ) {
			CCLOG(@"cocos2d: removing sprite frame: %@", key);
			[spriteFrames removeObjectForKey:key];
		}
	}	
}

-(void) removeSpriteFrameByName:(NSString*)name
{
	[spriteFrames removeObjectForKey:name];
}

#pragma mark CCSpriteFrameCache - getting

-(CCSpriteFrame*) spriteFrameByName:(NSString*)name
{
	return [spriteFrames objectForKey:name];
}

#pragma mark CCSpriteFrameCache - sprite creation

-(CCSprite*) createSpriteWithFrameName:(NSString*)name
{
	CCSpriteFrame *frame = [spriteFrames objectForKey:name];
	return [CCSprite spriteWithSpriteFrame:frame];
}
@end
