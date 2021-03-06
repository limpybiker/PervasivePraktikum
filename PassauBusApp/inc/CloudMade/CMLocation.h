//
//  CMLocation.h
//  LBA
//
//  Created by user on 12/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
* A CMLocation object stores location data for a given latitude and longitude. Location data includes information such as the country, state, city, 
* and street address associated with the specified coordinate. CMLocation objects are typically generated by a CMGeocoder object, 
* although you can also create them explicitly yourself.
*/
@interface CMLocation : NSObject
{
	NSDictionary*   addressDictionary;	
	CLLocationCoordinate2D coordinate;
	NSArray* geometry;
}

/** 
* The location’s coordinate.
*/
@property (readwrite) CLLocationCoordinate2D coordinate;
/** 
* The location’s geometry.
* \par Discussion:
* The array of NSNumber objects which describe location geo 
*/
@property (nonatomic, retain) NSArray *geometry;

/**
* Returns a location created and initialized with the given properties dictionary.
* @param properties  Location's properties dictionary.
* @return A location object.  
* \par Discussion:
* Normally you don't have to create this object directly. It will be created by CMGeododer
*/
+(id) locationWithProperties:(NSDictionary*) properties;
/**
* Initializes the location with the given property.
* @param properties  Location's properties dictionary.
* @return A location object.  
*/
-(id) initWithProperties:(NSDictionary*) properties;
/**
* Returns city name if any is found
* @return A city name  or nil if no city is found.  
*/
-(NSString*) city;
/**
* Returns country name if any is found
* @return A country name or nil if no country is found.  
*/
-(NSString*) country;
/**
* Returns county name if any is found (for US it is a state )
* @return A county name or nil if no county is found. 
*/
-(NSString*) county;
/**
* Returns street name if any is found
* @return A country street name or nil if no street is found.  
*/
-(NSString*) street;
/**
* Returns a house number if any is found
* @return A house number or nil if no house number is found.
*/
-(NSString*) house;

@end