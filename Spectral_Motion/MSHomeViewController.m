//
//  MSHomeViewController.m
//  Spectral_Motion
//
//  Created by Kale Evans on 2/21/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import "MSHomeViewController.h"
#import "MSHeaderViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MVYSideMenuController.h"
#import "MSFileDownloader.h"
#import "MSFileBrowser.h"

//dropbox
#import <DBChooser/DBChooser.h>
#import <DBChooser/DBChooserResult.h>


@interface MSHomeViewController ()<UIActionSheetDelegate>
{
    NSMutableArray *m_ImageFileNames;
    NSString *m_SelectedHyperspectralFile;
}

-(void)configureSideMenu;
-(void)showDropboxChooser;
-(void)addSampleFileNames;
-(void)addSavedFileNames;

@end


@implementation MSHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.ImageFileTableView.delegate = self;
    self.ImageFileTableView.dataSource = self;
    self.ImageFileTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    
    [self addSampleFileNames];
    [self addSavedFileNames];
    
    UIImageView *tableViewImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableview_background2.jpeg"]];
    [tableViewImg setFrame:self.ImageFileTableView.frame];
    //self.ImageFileTableView.backgroundView = tableViewImg;
    
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableview_background2.jpeg"]];
    
    self.ImageFileTableView.layer.cornerRadius = 15.0;
    [self.ImageFileTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.ImageFileTableView setSeparatorColor:[UIColor blueColor]];
    
    
}

-(void)addSampleFileNames
{
    m_ImageFileNames = [[NSMutableArray alloc]initWithObjects:
                        @"Sample Image 1",
                        @"Sample Image 2",
                        @"Sample Image 3(Reflectance Data)",
                        @"Sample Image 4(Reflectance Data)", nil];
}

-(void)addSavedFileNames
{
    NSArray *savedFolderNames = [MSFileBrowser getFoldersNamesSavedOnDisk];
    if(savedFolderNames == nil)
    {
        NSLog(@"folder names are nil");
        return;
    }
    [m_ImageFileNames addObjectsFromArray:savedFolderNames];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self configureSideMenu];
}

-(void)configureSideMenu
{
    MVYSideMenuController *sideMenuController = [self sideMenuController];
    sideMenuController.options.panFromBezel = NO;
    sideMenuController.options.panFromNavBar = NO;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource Methods

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageFileCell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"imageFileCell"] ;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
   
    cell.textLabel.text = [m_ImageFileNames objectAtIndex:indexPath.row];
    
   // cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tableview_background2.jpeg"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];

        
    return cell;

    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_ImageFileNames.count;
    
}


#pragma mark - UITableViewDelegate Methods

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    m_SelectedHyperspectralFile = [m_ImageFileNames objectAtIndex:indexPath.row];
    
   // [self performSegueWithIdentifier:@"PushToHeaderVC" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MSHeaderViewController *msHeaderVC = (MSHeaderViewController*)segue.destinationViewController;
    //msHeaderVC.m_HeaderFileName = m_SelectedHyperspectralFile;
    
    //hardcoding file name for now temporarily
    
    switch ([self.ImageFileTableView indexPathForSelectedRow].row)
    {
        case 0:
        {
            msHeaderVC.m_HeaderFileName = @"f970620t01p02_r03_sc03.a";
            [msHeaderVC parseHeaderFile];

        }
            break;
            
        case 1:
        {
            msHeaderVC.m_HeaderFileName = @"sample2.a";
            [msHeaderVC parseHeaderFile];
            
        }
            break;
            
        case 2:
        {
            msHeaderVC.m_HeaderFileName = @"f970619t01p02_r02_sc05.a";
            [msHeaderVC parseHeaderFile];

            
        }
            break;
            
        case 3:
        {
            msHeaderVC.m_HeaderFileName = @"f970619t01p02_r02_sc01.a";
            [msHeaderVC parseHeaderFile];

            
        }
            break;
            
            
            
        default://find header file on disk from filename
        {
            int selectedRow = [self.ImageFileTableView indexPathForSelectedRow].row;
            
            m_SelectedHyperspectralFile = [m_ImageFileNames objectAtIndex: selectedRow];
            msHeaderVC.m_HeaderFileName = m_SelectedHyperspectralFile;
            [msHeaderVC parseHeaderFile];
            
        }
            break;
    }
    /*
    
    if([self.ImageFileTableView indexPathForSelectedRow].row == 0)
    {
        msHeaderVC.m_HeaderFileName = @"f970620t01p02_r03_sc03.a";
        [msHeaderVC parseHeaderFile];
    }
    
    else if ([self.ImageFileTableView indexPathForSelectedRow].row == 1)
    {
        msHeaderVC.m_HeaderFileName = @"sample2.a";
        [msHeaderVC parseHeaderFile];
    }
    
    else if ([self.ImageFileTableView indexPathForSelectedRow].row == 2)
    {
        msHeaderVC.m_HeaderFileName = @"f970619t01p02_r02_sc05.a";
        [msHeaderVC parseHeaderFile];
    }
    */

    
}


- (IBAction)didPressDownloadBtn:(id)sender
{
    UIActionSheet * downloadOptions = [[UIActionSheet alloc] initWithTitle:@"Please Select File Location" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Dropbox", @"Google Drive(Coming Soon)", @"One Drive(Coming soon)", nil];
    [downloadOptions showInView:self.view];
}

#pragma mark UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    switch (buttonIndex)
    {
        case 0://Dropbox
        {
            [self showDropboxChooser];
        }
            break;
            
        case 1://Google Drive
        {
            
        }
            break;
            
        case 2://One Drive
        {
            
        }
            break;
    }
}

-(void)showDropboxChooser
{
    DBChooserLinkType linkType = DBChooserLinkTypeDirect;
    __block NSURL *fileURL = nil;
    __block NSString *fileName = nil;
    
    [[DBChooser defaultChooser] openChooserForLinkType:linkType fromViewController:self
                                            completion:^(NSArray *results)
     {
         if ([results count])
         {
             //_result = results[0];
             DBChooserResult * result = results[0];
             fileName = result.name;
             fileURL = result.link;
             
             
         } else
         {
             //_result = nil;
             [[[UIAlertView alloc] initWithTitle:@"CANCELLED" message:@"user cancelled!"
                                        delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil]
              show];
         }
         
         //download file here
         if(fileURL != nil && fileName != nil)
         {
             MSFileDownloader *fileDownloader = [[MSFileDownloader alloc]initWithURL:fileURL andName:fileName];
             fileDownloader.delegate = self;
             [fileDownloader downloadFileInBackground];
         }
         
         //[[self tableView] reloadData];
     }];
    
}

#pragma mark - MSFileDownloaderDelegate

-(void)downloadDidFinish
{
    NSLog(@"Download did finish");
    [m_ImageFileNames removeAllObjects];
    [self addSampleFileNames];
    [self addSavedFileNames];
    NSLog(@"Image file names %@", m_ImageFileNames);
    [self.ImageFileTableView reloadData];
}


@end
