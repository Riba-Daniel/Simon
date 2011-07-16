//
//  DetailViewController.h
//  Test Navigation App
//
//  Created by Derek Clarkson on 7/16/11.
//  Copyright 2011 Sensis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
