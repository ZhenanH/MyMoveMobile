//
//  MapViewAnnotation.m
//  Molo
//
//  Created by Zhenan Hong on 3/4/13.
//  Copyright (c) 2013 Lean Develop. All rights reserved.
//

#import "MapViewAnnotation.h"

@implementation MapViewAnnotation

- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d {
	if(self = [super init])
    {
	_title = ttl;
    _coordinate = c2d;
    
    }
	return self;
    
    
}



@end
