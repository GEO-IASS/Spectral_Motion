//
//  MSSpectralSignatureSelectorTableVC.m
//  Spectral_Motion
//
//  Created by Kale Evans on 4/26/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

/*Sections:
1. Vegetation
2. Man-Made
3. Rocks
4. Soil

 */

#import "MSSpectralSignatureSelectorTableVC.h"

@interface MSSpectralSignatureSelectorTableVC ()
{
    NSDictionary *m_SpectralMaterials;
    NSMutableArray *m_SelectedSpectralMaterialsIndexPaths;
    NSArray *m_checkBoxArray;
}

-(void)checkBoxTapped:(id) sender ;
-(void)saveSpectralMaterialsSelection;
-(void)cancelSpectralMaterialSelection;

@end

@implementation MSSpectralSignatureSelectorTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.allowsMultipleSelection = YES;
    
    NSString *pathToPlist = [NSString stringWithFormat:@"%@/SpectralLibrary.plist",[[NSBundle mainBundle]resourcePath]];
    m_SpectralMaterials = [NSDictionary dictionaryWithContentsOfFile:pathToPlist];
    self.title = @"Select Spectral Signatures To Plot To Graph";
    [self setNavControllerButtons];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return m_SpectralMaterials.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section)
    {
            //vegatation section
        case 0:
        {
          return ((NSArray *)[m_SpectralMaterials objectForKey:@"Vegetation"]).count;
        }
        break;
            
            //Man-Made section
        case 1:
        {
            return ((NSArray *)[m_SpectralMaterials objectForKey:@"Man-Made"]).count;

        }
        break;
            
            //Rocks Section
        case 2:
        {
            return ((NSArray *)[m_SpectralMaterials objectForKey:@"Rocks"]).count;

            
        }
            break;
            
            //Soil Section
        case 3:
        {
            return ((NSArray *)[m_SpectralMaterials objectForKey:@"Soil"]).count;

        }
            break;
            
            
        default:
            break;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    NSString * title;
    switch (section)
    {
        case 0:
        {
            title = @"Vegetation";
        }
            
            break;
            
            case 1:
        {
            title = @"Man-Made";
        }
            break;
            
            case 2:
        {
            title = @"Rocks";
        }
            break;
            
            case 3:
        {
            title = @"Soil";
        }
            break;
            
        default:
            break;
    }
    
    return title;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIButton *checkBox = (UIButton *)[cell viewWithTag:2];
    
    
    [checkBox setBackgroundImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
    
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIButton *checkBox = (UIButton *)[cell viewWithTag:2];

    
   [checkBox setBackgroundImage:[UIImage imageNamed:@"checkblank.png"] forState:UIControlStateNormal];

    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SpectralSignatureOptionCell" forIndexPath:indexPath];
    
   
    UILabel *materialName = (UILabel *)[cell viewWithTag:3];
    NSArray *materialArray;

//    NSArray *spectralMaterialsArray = [m_SpectralMaterials allKeys];
    
    switch (indexPath.section)
    {
        case 0://vegetation
        {
            
            materialArray = [m_SpectralMaterials objectForKey:@"Vegetation"];
            
            materialName.text = [materialArray objectAtIndex:indexPath.row];
            
        }
            
            break;
            
            case 1: //Man-Made
        {
            materialArray = [m_SpectralMaterials objectForKey:@"Man-Made"];
            
            materialName.text = [materialArray objectAtIndex:indexPath.row];

            
        }
            break;
            
            
            case 2:// Rocks
        {
            materialArray = [m_SpectralMaterials objectForKey:@"Rocks"];
            
            materialName.text = [materialArray objectAtIndex:indexPath.row];

            
            
        }
            
            break;
            
            case 3: // Soil
        {
            materialArray = [m_SpectralMaterials objectForKey:@"Soil"];
            
            materialName.text = [materialArray objectAtIndex:indexPath.row];

        }
            
            break;
            
        default:
            break;
    }
    
    
    UIButton *checkBoxButton = (UIButton *)[cell viewWithTag:2];
    
   // [checkBoxButton setBackgroundImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateSelected];

   // [checkBoxButton setBackgroundImage:[UIImage imageNamed:@"checkblank.png"] forState:UIControlStateNormal];
    checkBoxButton.userInteractionEnabled = NO;//temporary. Only set checkmark if select row
    
    if(cell.isSelected)
    {
        [checkBoxButton setBackgroundImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
    }
    else
    {
        
        [checkBoxButton setBackgroundImage:[UIImage imageNamed:@"checkblank.png"] forState:UIControlStateNormal];
    }
    
   // [checkBoxButton addTarget:self action:@selector(checkBoxTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    return cell;
}

-(void)checkBoxTapped:(id)sender
{
    UIButton *button = (UIButton *) sender;
    
   // UITableViewCell *cell = (UITableViewCell *)button.superview;
    
    //cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    
    button.selected = !button.selected;
    
    
}

-(void)setNavControllerButtons
{
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Done"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   
                                   action:@selector(saveSpectralMaterialsSelection)];
    
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"Cancel"
                                                                    style:UIBarButtonItemStylePlain target:self
                                                                   action:@selector(cancelSpectralMaterialSelection)];
    
    
    self.navigationController.topViewController.navigationItem.rightBarButtonItem = saveButton;
    self.navigationController.topViewController.navigationItem.leftBarButtonItem = cancelButton;
}


-(void)saveSpectralMaterialsSelection
{
    m_SelectedSpectralMaterialsIndexPaths = [NSMutableArray array];
    
    //iterate thru all cells to get button selected state
    for (NSInteger j = 0; j < [self.tableView numberOfSections]; ++j)
    {
        for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:j]; ++i)
        {
            NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:i inSection:j];
            
            UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:cellIndexPath];
            
          //  UIButton *checkBoxButton = (UIButton *)[cell viewWithTag:2];
            
            if(cell.selected)
            {
                [m_SelectedSpectralMaterialsIndexPaths addObject:cellIndexPath];
            }
        }
    }
    
    [self.delegate didSelectSpectralSignaturesWithIndexPaths:m_SelectedSpectralMaterialsIndexPaths];
}
-(void)cancelSpectralMaterialSelection
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
        
    }];
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
