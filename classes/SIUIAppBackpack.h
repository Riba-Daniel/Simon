//
//  SIUIAppBackpack.h
//  Simon
//
//  Created by Derek Clarkson on 9/08/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIAppBackpack.h"
#import "SIUIReportManager.h"

/**
 SIAppBackpack implementation which is used when Simon is running in a standalone mode.
 */
@interface SIUIAppBackpack : SIAppBackpack {
	@private
	SIUIReportManager *ui;
}

@end
