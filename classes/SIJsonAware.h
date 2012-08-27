//
//  SIJsonAware.h
//  Simon
//
//  Created by Derek Clarkson on 26/08/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

/**
 Classes which implement this protocol can convert to and from JSON strings.
 */
@protocol SIJsonAware <NSObject>

/**
 Init which accepts a dictionary containing the data for this object.
 
 @param data a dctionary containing the data for this object.
 @return an instance of this class populated with the data from the passed dictionary.
 */
-(id) initWithJsonDictionary:(NSDictionary *) data;

/**
 Returns a dictionary populated by the object.
 */
-(NSDictionary *) jsonDictionary;

@end
