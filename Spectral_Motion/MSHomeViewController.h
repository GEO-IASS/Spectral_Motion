//
//  MSHomeViewController.h
//  Spectral_Motion
//
//  Created by Kale Evans on 2/21/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSFileDownloader.h"


@interface MSHomeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,
MSFileDownloaderDelegate>

@property (weak, nonatomic) IBOutlet UITableView *ImageFileTableView;
- (IBAction)didPressDownloadBtn:(id)sender;

@end
