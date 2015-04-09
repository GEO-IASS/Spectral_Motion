//
//  ImageDisplayTypeTableVC.m
//  Spectral_Motion
//
//  Created by Kale Evans on 4/7/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import "ImageDisplayTypeTableVC.h"
#import "MSBandPickerViewsVC.h"

@interface ImageDisplayTypeTableVC ()
{
    NSArray *m_ImageDisplayTypes;
}

-(void)saveBandSelection;
-(void)cancelBandSelection;

-(void)setNavControllerButtonsForNavController:(UINavigationController*)navController;

@end

@implementation ImageDisplayTypeTableVC
@synthesize m_ParentNavigationController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //parse plist file that has display type options
    NSString *pathToPlist = [NSString stringWithFormat:@"%@/ImageDisplayTypes.plist",[[NSBundle mainBundle]resourcePath]];
    m_ImageDisplayTypes = [NSArray arrayWithContentsOfFile:pathToPlist];
    
}

-(void)setHdrInfo:(HDRINFO)hdrInfo
{
    m_HdrInfo = hdrInfo;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return m_ImageDisplayTypes.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageDisplayOptionCell" forIndexPath:indexPath];
    
    cell.textLabel.text = m_ImageDisplayTypes[indexPath.row];
    
    
    return cell;
}

#pragma mark - Tableview Delegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //push to controller for choosing bands
    
    switch (indexPath.row)
    {
            //greyscale image selected
        case 0:
        {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            MSBandPickerViewsVC *bandPickerViewsVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"MSBandPickerViewsVC"];
            
            bandPickerViewsVC.m_ShouldShowColorOptions = [NSNumber numberWithBool:NO];
            bandPickerViewsVC.m_NumberOfBands = [NSNumber numberWithInt: m_HdrInfo.bands];
            
            [self setNavControllerButtonsForNavController:m_ParentNavigationController];
            
            [m_ParentNavigationController pushViewController:bandPickerViewsVC animated:YES];
        }
            
        break;
            
            //rgb image selected
         case 1:
        {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            MSBandPickerViewsVC *bandPickerViewsVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"MSBandPickerViewsVC"];
            
            bandPickerViewsVC.m_ShouldShowColorOptions = [NSNumber numberWithBool:YES];
            bandPickerViewsVC.m_NumberOfBands = [NSNumber numberWithInt: m_HdrInfo.bands];
            
            [self setNavControllerButtonsForNavController:m_ParentNavigationController];
            
            [m_ParentNavigationController pushViewController:bandPickerViewsVC animated:YES];
            
        }
            
        break;
            
            //grayscale pca selected
        case 2:
        {
            
        }
            
            break;
            
            //color pca selected
        case 3:
        {
            
        }
            
            break;
            
        default:
            break;
    }
}

-(void)saveBandSelection
{
    //here after bands have been selected, add new image to view
    
}

-(void)cancelBandSelection
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
        
    }];
}

-(void)setNavControllerButtonsForNavController:(UINavigationController*)navController
{
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Done"
                                   style:UIBarButtonItemStylePlain
                                   target:self
   
                                   action:@selector(saveBandSelection)];
    
   
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"Cancel"
                                                                    style:UIBarButtonItemStylePlain target:self
                                                                   action:@selector(cancelBandSelection)];
    
    
    navController.topViewController.navigationItem.rightBarButtonItem = saveButton;
    navController.topViewController.navigationItem.leftBarButtonItem = cancelButton;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
