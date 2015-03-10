//
//  MSBandMappingTableVC.m
//  Spectral_Motion
//
//  Created by Kale Evans on 3/9/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import "MSBandMappingTableVC.h"
#import "MSColorMapPopOver.h"

@interface MSBandMappingTableVC ()<CellSelected>
{
    BOOL m_ColorMapping;
    int m_BandCount;
    float *m_Wavelengths;
    short *m_ColorsMapped;
    UIPopoverController *m_ColorMappingPopOver;
    MSColorMapPopOver * m_ColorMappingPopOverContent;
}
@end

@implementation MSBandMappingTableVC
@synthesize delegate, m_BandsMapped, m_BandsSelected;



-(void)setWavelenghths:(float*)wavelengthArr andBandCount:(int)bandCount
{
    m_Wavelengths = wavelengthArr;
    m_BandCount = bandCount;
}

-(void)setColorMappingBOOL:(BOOL)colorMapBool
{
    m_ColorMapping = colorMapBool;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    m_ColorsMapped = (short*) calloc(m_BandCount, sizeof(short));
    memset(m_ColorsMapped, 0, m_BandCount * sizeof(short));
    self.tableView.allowsMultipleSelection = YES;

     self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return m_BandCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BandInfo" forIndexPath:indexPath];
    
    UILabel *bandLabel = (UILabel*)[cell viewWithTag:2];
    bandLabel.text = [NSString stringWithFormat:@"Band %i",indexPath.row + 1 ];
    UILabel *waveLengthLabel = (UILabel*)[cell viewWithTag:3];
   // waveLengthLabel.text = m_Wavelengths[indexPath.row];
    waveLengthLabel.text = [NSString stringWithFormat:@"%f µm", m_Wavelengths[indexPath.row]];
    UILabel *colorLabel = (UILabel*)[cell viewWithTag:4];
    UIView *colorMappedView = (UIView*)[cell viewWithTag:5];
    switch (m_ColorsMapped[indexPath.row])
    {
            //no color mapped
        case 0:
        {
            colorLabel.text = @"None";
            [colorMappedView setBackgroundColor:[UIColor grayColor]];
            
        }
            break;
            
            //red color mapped
        case 1:
        {
            colorLabel.text = @"Red";
            [colorMappedView setBackgroundColor:[UIColor redColor]];
        }
            break;
            
            //green color mapped
        case 2:
        {
            colorLabel.text = @"Green";
            [colorMappedView setBackgroundColor:[UIColor greenColor]];
            
        }
            break;
            
            //blue color mapped
        case 3:
        {
            colorLabel.text = @"Blue";
            [colorMappedView setBackgroundColor:[UIColor blueColor]];
            
        }
            break;
            
        default:
            break;
    }
  
    if(!m_ColorMapping)
    {
        colorLabel.hidden = YES;
        colorMappedView.hidden = YES;
        UILabel *colorMapLabel = (UILabel*)[tableView viewWithTag:7];
        colorMapLabel.hidden = YES;
    }
   
    return cell;
}

#pragma mark - TableView Delegate methods

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(!m_ColorMapping)
    {
        int count = 0;
        m_BandsSelected = nil;
        m_BandsSelected = [[NSMutableArray alloc]init];
        for(NSIndexPath *path in [self.tableView indexPathsForSelectedRows])
        {
            [m_BandsSelected setObject:[NSNumber numberWithInt:path.row] atIndexedSubscript:count] ;
            count++;
        }
        
        NSLog(@"%@", [self.tableView indexPathsForSelectedRows]);
        
        return;
    }

}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!m_ColorMapping)
    {
        int count = 0;
        m_BandsSelected = nil;
        m_BandsSelected = [[NSMutableArray alloc]init];
        for(NSIndexPath *path in [self.tableView indexPathsForSelectedRows])
        {
            [m_BandsSelected setObject:[NSNumber numberWithInt:path.row] atIndexedSubscript:count] ;
            count++;
        }
        
        NSLog(@"%@", [self.tableView indexPathsForSelectedRows]);
        
        return;
    }

    
    m_ColorMappingPopOverContent = [[MSColorMapPopOver alloc]initWithStyle:UITableViewStyleGrouped];
    m_ColorMappingPopOverContent.delegate = self;
    m_ColorMappingPopOverContent.tableView.scrollEnabled = NO;
    
    
    m_ColorMappingPopOver = [[UIPopoverController alloc]initWithContentViewController:m_ColorMappingPopOverContent];
    
    [m_ColorMappingPopOver presentPopoverFromRect:[tableView cellForRowAtIndexPath:indexPath].frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    [m_ColorMappingPopOver setPopoverContentSize:CGSizeMake(300, 230) animated:YES];
    
    
    
}

#pragma mark - CellSelected Delegate methods
-(void)colorCellSelectedWithIndex:(int)index
{
    [m_ColorMappingPopOver dismissPopoverAnimated:YES];
    
    m_ColorsMapped[[self.tableView indexPathForSelectedRow].row] = index;
    [self.tableView reloadData];
    
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
