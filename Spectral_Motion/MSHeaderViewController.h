//
//  MSHeaderViewController.h
//  Spectral_Motion
//
//  Created by Kale Evans on 2/21/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface MSHeaderViewController : UIViewController

@property(strong,nonatomic) NSString *m_HeaderFileName;


-(BOOL)parseHeaderFile;

@end
