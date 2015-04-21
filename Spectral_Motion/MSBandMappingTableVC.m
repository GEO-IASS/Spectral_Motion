//
//  MSBandMappingTableVC.m
//  Spectral_Motion
//
//  Created by Kale Evans on 3/9/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import "MSBandMappingTableVC.h"
#import "MSColorMapPopOver.h"
#import "ImageDisplayTypeTableVC.h"
#import "ViewController.h"

@interface MSBandMappingTableVC ()<CellSelected>
{
    BOOL m_ColorMapping;
    int m_BandCount;
    float *m_Wavelengths;
    short *m_ColorsMapped;
    UIPopoverController *m_ColorMappingPopOver;
    MSColorMapPopOver * m_ColorMappingPopOverContent;
    
    
}

-(void) setNavControllerButtonsForNavController;
-(void)cancelBandSelection;
-(void)saveBandSelection;

@end

@implementation MSBandMappingTableVC
@synthesize delegate, m_ParentNavController,  m_BandsSelected;



-(void)setWavelenghths:(float*)wavelengthArr andBandCount:(int)bandCount
{
    m_Wavelengths = wavelengthArr;
    m_BandCount = bandCount;
}

-(void)setColorMappingBOOL:(BOOL)colorMapBool
{
    m_ColorMapping = colorMapBool;
}

-(short*)getColorsMapped
{
    return m_ColorsMapped;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(m_ColorsMapped == NULL)
    {
        m_ColorsMapped = (short*) calloc(m_BandCount, sizeof(short));
        memset(m_ColorsMapped, 0, m_BandCount * sizeof(short));
    }
    
    self.tableView.allowsMultipleSelection = YES;

    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //this indicates this controller was launched from ImageViewer and not from Header which doesn't require buttons added to its navigation controller since the done button is on the form
    if(m_ParentNavController !=nil)
    {
        [self setNavControllerButtonsForNavController:m_ParentNavController];
    }

    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
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

-(void)saveBandSelection
{
    //here after bands have been selected, create new image and call delegate to add to view
    
    UINavigationController *navController = (UINavigationController*)self.parentViewController;
    
    ImageDisplayTypeTableVC *imageDisplayTypeController = navController.childViewControllers[0];
    
    NSLog(@"controller %@", imageDisplayTypeController.description);
    
    /*set delegate to ImageViewController so it can implement didFinishSelectingImageBands
     to add new image to its view */
    self.delegate = (ViewController<PCABandsSelectedDelegate>*)imageDisplayTypeController.m_ImageViewController;//this is original calling ImageViewController pointer
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
        //mapped colors for PCA
        if(m_ColorMapping)
        {
            
            short *colorsMappedArr = [self getColorsMapped];
            
           int redBandsMappedCountPCA    = 0;
           int greenBandsMappedCountPCA  = 0;
           int blueBandsMappedCountPCA   = 0;
            
            HDRINFO hdrInfo = [(ViewController*)imageDisplayTypeController.m_ImageViewController getHdrInfo];
            
            for(int i = 0; i <  hdrInfo.bands; i++)
            {
                switch (colorsMappedArr[i])
                {
                    case 1:
                        redBandsMappedCountPCA++;
                        break;
                        
                    case 2:
                        greenBandsMappedCountPCA++;
                        break;
                        
                    case 3:
                        blueBandsMappedCountPCA++;
                        break;
                        
                    default:
                        break;
                }
                
            }
            
            int *redBandsMappedPCA = (int*)calloc(redBandsMappedCountPCA, sizeof(int));
            int *greenBandsMappedPCA = (int*)calloc(greenBandsMappedCountPCA, sizeof(int));
            int *blueBandsMappedPCA = (int*)calloc(blueBandsMappedCountPCA, sizeof(int));
            
            for(int i = 0; i < hdrInfo.bands; i++)
            {
                switch (colorsMappedArr[i])
                {
                    case 1:
                        *redBandsMappedPCA = i;
                        redBandsMappedPCA++;
                        break;
                        
                    case 2:
                        *greenBandsMappedPCA = i;
                        greenBandsMappedPCA++;
                        break;
                        
                    case 3:
                        *blueBandsMappedPCA = i;
                        blueBandsMappedPCA++;
                        break;
                        
                    default:
                        break;
                }
            }
            
            //reset pointers to beginning of their array
            redBandsMappedPCA -= redBandsMappedCountPCA;
            greenBandsMappedPCA -= greenBandsMappedCountPCA;
            blueBandsMappedPCA-= blueBandsMappedCountPCA;

        
            [delegate didFinishMappingColorsForPCAWithRedArray:redBandsMappedPCA redArraryCount:redBandsMappedCountPCA greenArray:greenBandsMappedPCA greenArrayCount:greenBandsMappedCountPCA andBlueArray:blueBandsMappedPCA blueArrayCount:blueBandsMappedCountPCA];
            
        }
        else
        {
            //greycale PCA
            int bandsMappedCount = (int)[m_BandsSelected count];
            int *bandsMapped = (int*) calloc(bandsMappedCount, sizeof(int));
            
            for(int i =0; i < bandsMappedCount; i++)
            {
                NSNumber *bandNum = (NSNumber*) m_BandsSelected[i];
                
                bandsMapped[i] = [bandNum intValue];
            }

            
            [delegate didFinishSelectingBandsForPCAWithArray:bandsMapped andBandCount:bandsMappedCount];
            
        }
        
    }];
    
}



-(void)cancelBandSelection
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
        
    }];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BandInfo" forIndexPath:indexPath];
    
    UILabel *bandLabel = (UILabel*)[cell viewWithTag:2];
    bandLabel.text = [NSString stringWithFormat:@"%i",indexPath.row + 1 ];
    UILabel *waveLengthLabel = (UILabel*)[cell viewWithTag:3];
    if(m_Wavelengths != NULL)
    {
        waveLengthLabel.text = [NSString stringWithFormat:@"%f µm",
                                m_Wavelengths[indexPath.row]];
    }
    else
    {
        waveLengthLabel.text = @"";
    }
    UILabel *colorLabel = (UILabel*)[cell viewWithTag:4];
    UIView *colorMappedView = (UIView*)[cell viewWithTag:5];
    UILabel *spectrumLabel = (UILabel*)[cell viewWithTag:8];
    
    if(m_Wavelengths != NULL)
    {
        float wavelength = m_Wavelengths[indexPath.row];
    
        if((wavelength*1000)> 300 &&  (wavelength*1000)< 400)
        {
            spectrumLabel.text = @"Range: Ultraviolet Light";
            spectrumLabel.textColor = [UIColor purpleColor];
        }
        else if((wavelength*1000)> 400 &&  (wavelength*1000)< 700)
        {
            spectrumLabel.text = @"Range: Visible Light";
            spectrumLabel.textColor = [UIColor grayColor];

        }
        else if((wavelength*1000)> 700 &&  (wavelength*1000)< 1300)
        {
            spectrumLabel.text = @"Range: Near Infrared Light";
            spectrumLabel.textColor = [UIColor redColor];
        }
        else  if((wavelength*1000)> 1300 &&  (wavelength*1000)< 3000)
        {
            spectrumLabel.text = @"Range: Mid-Infrared Light";
            spectrumLabel.textColor = [UIColor redColor];
        }
        else if((wavelength*1000)> 3000 &&  (wavelength*1000)< 5000)
        {
            spectrumLabel.text = @"Range: Infrared Light";
            spectrumLabel.textColor = [UIColor redColor];
        }
        else if((wavelength*1000)> 8000 &&  (wavelength*1000)< 14000)
        {
            spectrumLabel.text = @"Range: Infrared Light";
            spectrumLabel.textColor = [UIColor redColor];
        }
        else
        {
            spectrumLabel.text = @"Undefined Range";
            spectrumLabel.textColor = [UIColor blackColor];
        }
    }
    else
    {
        spectrumLabel.text = @"Unspecified Wavelength";
        spectrumLabel.textColor = [UIColor blackColor];

    }
   
    
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
    else
    {
        colorLabel.hidden = NO;
        colorMappedView.hidden = NO;
        UILabel *colorMapLabel = (UILabel*)[tableView viewWithTag:7];
        colorMapLabel.hidden = NO;
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
            [m_BandsSelected setObject:[NSNumber numberWithInt:(int)path.row]
                    atIndexedSubscript:count] ;
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
