//
//  MenuOptionsViewController.m
//  Spectral_Motion
//
//  Created by Kale Evans on 3/15/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import "MenuOptionsViewController.h"

@interface MenuOptionsViewController ()
{
    NSArray *m_MenuOptions;
}

@end

@implementation MenuOptionsViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //parse plist file that has menu options
    NSString *pathToPlist = [NSString stringWithFormat:@"%@/MenuOptions.plist",[[NSBundle mainBundle]resourcePath]];

     m_MenuOptions = [NSArray arrayWithContentsOfFile: pathToPlist];
    
    self.tableView.layer.cornerRadius = 15.0f;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [m_MenuOptions count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuOptionCell" forIndexPath:indexPath];
    
    NSDictionary *menuOption = [m_MenuOptions objectAtIndex:indexPath.row];
    
    //cell background image
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"mainbackground"] drawInRect:self.view.bounds];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [cell setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];

    
    //cell title
    UILabel *cellTitle = (UILabel*)[cell viewWithTag:2];
    cellTitle.text = [menuOption valueForKey:@"MenuOptionName"];
    
    //cell image
    UIImageView *cellImageView = (UIImageView*)[cell viewWithTag:3];
    [cellImageView setImage:[UIImage imageNamed:[menuOption valueForKey:@"MenuOptionImage"]]];
    
   
    //cell description
    UITextView *cellTextView = (UITextView*)[cell viewWithTag:4];
    [cellTextView setText:[menuOption valueForKey:@"MenuOptionDesc"]];
    cellTextView.backgroundColor = [UIColor clearColor];
    
    cell.contentView.layer.cornerRadius = 15.0f;
    cell.contentView.layer.masksToBounds = YES;
    
    
    return cell;
}

#pragma mark- TableView delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.delegate didSelectOptionWithIndex:indexPath.row];
    
    /*
    switch (indexPath.row)
    {
            //Add image with different image parameters
        case 0:
        {
    
            ;
        }
            break;
            
            //Edit existing image parameters
        case 1:
        {
         
            ;
        }
            break;
            
            
        default:
            break;
    }
     */
    
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
