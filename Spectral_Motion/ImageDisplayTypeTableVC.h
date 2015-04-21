//
//  ImageDisplayTypeTableVC.h
//  Spectral_Motion
//
//  Created by Kale Evans on 4/7/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSENVIFileParser.h"
#import "MSBandMappingTableVC.h"

@interface ImageDisplayTypeTableVC : UITableViewController
{
    HDRINFO m_HdrInfo;
}
@property (strong,nonatomic) UINavigationController *m_ParentNavigationController;
@property (strong,nonatomic) UIViewController * m_ImageViewController;
@property (strong, nonatomic) MSBandMappingTableVC *m_BandMappingTableVC;



-(void)setHdrInfo:(HDRINFO) hdrInfo;
@end
