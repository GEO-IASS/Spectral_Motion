//
//  ImageDisplayTypeTableVC.h
//  Spectral_Motion
//
//  Created by Kale Evans on 4/7/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSENVIFileParser.h"

@interface ImageDisplayTypeTableVC : UITableViewController
{
    HDRINFO m_HdrInfo;
}
@property (strong,nonatomic) UINavigationController *m_ParentNavigationController;
@property (strong,nonatomic) UIViewController * m_ImageViewController;



-(void)setHdrInfo:(HDRINFO) hdrInfo;
@end
