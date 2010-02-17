// This file is part of babel4iphone.

// Copyright (C) 2009 Giovanni Amati <amatig@gmail.com>

// babel4iphone is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// babel4iphone is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with babel4iphone.  If not, see <http://www.gnu.org/licenses/>.


#import "GameLayer.h"

@implementation GameLayer

-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if ((self = [super init]))
	{
		CCSprite *sprite = [CCSprite spriteWithFile:@"arena.png"];
		sprite.anchorPoint = CGPointZero;
		[self addChild:sprite z:0];
	}
	
	return self;
}

-(void) addMyCharacter:(NSArray *)attr position:(int)p
{
	NSString *fname = [[[NSString alloc] initWithFormat:@"%@", [attr objectAtIndex:1]] stringByAppendingString:@".png"];
	CCSprite *sprite = [CCSprite spriteWithFile:fname];
	sprite.scale = 0.4;
	sprite.anchorPoint = CGPointZero;
	sprite.position = ccp(125 - 25 * p, 150 - 35 * p);
	[self addChild:sprite z:p tag:10+p];
}

-(void) addEnemyCharacter:(NSArray *)attr position:(int)p
{
	NSString *fname = [[[NSString alloc] initWithFormat:@"%@", [attr objectAtIndex:1]] stringByAppendingString:@".png"];
	CCSprite *sprite = [CCSprite spriteWithFile:fname];
	sprite.scale = 0.4;
	sprite.scaleX = -0.4;
	sprite.anchorPoint = CGPointZero;
	sprite.position = ccp(350 + 25 * p, 150 - 35 * p);
	[self addChild:sprite z:p tag:20+p];
}

// on "dealloc" you need to release all your retained objects
-(void) dealloc
{	
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end