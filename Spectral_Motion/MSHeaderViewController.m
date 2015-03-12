//
//  MSHeaderViewController.m
//  Spectral_Motion
//
//  Created by Kale Evans on 2/21/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import "MSHeaderViewController.h"
#import "ViewController.h"
#import "MSENVIFileParser.h"
#import "MSHyperspectralData.h"
#import "MSImageBlur.h"
#import "MBProgressHUD.h"
#import "MSBandMappingTableVC.h"

@interface MSHeaderViewController ()<ImageViewerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIPopoverControllerDelegate>
{
    HDRINFO hdrInfo;
    MSENVIFileParser *m_EnviFileParser;
    MSHyperspectralData *m_HyperspectralData;
    UIImageView *m_BlurredImageView;
    NSArray *displayTypeOptions;
    MBProgressHUD *m_ProgressHud;
    UIPopoverController *m_PopOverVC;
    UINavigationController *m_NavControllerForBandTVC;
    MSBandMappingTableVC *m_MSBandMappingTableVC;
    int *m_BandsMapped;
    int m_BandsMappedCount;
    
    int *m_RedBandsMappedPCA;
    int m_RedBandsMappedCountPCA;
    int *m_GreenBandsMappedPCA;
    int m_GreenBandsMappedCountPCA;
    int *m_BlueBandsMappedPCA;
    int m_BlueBandsMappedCountPCA;

}
@property (weak, nonatomic) IBOutlet UITextField *samplesTextField;
@property (weak, nonatomic) IBOutlet UITextField *linesTextField;
@property (weak, nonatomic) IBOutlet UITextField *interleaveTypeTextField;
@property (weak, nonatomic) IBOutlet UITextField *bandsTextField;
@property (weak, nonatomic) IBOutlet UITextField *dataTypeTextField;
@property (weak, nonatomic) IBOutlet UILabel *dataLengthLabel;
@property (weak, nonatomic) IBOutlet UITextField *byteOrderTextField;
@property (weak, nonatomic) IBOutlet UITextField *redBandTextField;
@property (weak, nonatomic) IBOutlet UITextField *greenBandTextField;
@property (weak, nonatomic) IBOutlet UITextField *blueBandTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *displayTypePickerView;
@property (weak, nonatomic) IBOutlet UILabel *redBand_greyBand_label;
@property (weak, nonatomic) IBOutlet UILabel *greenBandLabel;
@property (weak, nonatomic) IBOutlet UILabel *blueBandLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *loadDataProgressView;
@property (weak, nonatomic) IBOutlet UILabel *loadingImageLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) IBOutlet UIButton *setBandsForPCAButton;

- (IBAction)setBandsForPCAButtonTapped:(id)sender;

- (IBAction)doneButtonTapped:(id)sender;

-(cv::Mat)deblurImage:(cv::Mat)matrix;

-(void)setViewControllerFields;
-(void)setBackgroundImage;
-(void)hideRGBGUIElements:(BOOL)hide;
-(void)changeGUIBasedOnPickerviewSelection:(int)rowSelected;
-(void)setNavControllerButtonsForNavController:(UINavigationController*)navController;

-(void)saveBandSelection;
-(void)CancelBandSelection;



@end


@implementation MSHeaderViewController
@synthesize m_HeaderFileName;

-(void)viewWillAppear:(BOOL)animated
{
    self.loadDataProgressView.hidden = YES;
    self.loadingImageLabel.hidden = YES;
    [self.view setUserInteractionEnabled:YES];
    m_HyperspectralData = nil;
    
    int rowSelected = (int)[self.displayTypePickerView selectedRowInComponent:0];
    [self changeGUIBasedOnPickerviewSelection:rowSelected];
    
    

}

-(void)viewWillDisappear:(BOOL)animated
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 10.0f);
    self.loadDataProgressView.transform = transform;
    [self setViewControllerFields];
    self.doneButton.showsTouchWhenHighlighted = YES;
    self.displayTypePickerView.dataSource = self;
    self.displayTypePickerView.delegate = self;
    displayTypeOptions = [[NSArray alloc]initWithObjects:@"1-Channel GreyScale", @"3-Channel RGB", @" GreyScale Principal Component Analysis", @"3-Channel RGB Principal Component Analysis", nil];
    
    [self setBackgroundImage];
}

-(void)viewDidAppear:(BOOL)animated
{
    if(m_BlurredImageView ==nil)
    {
        //watch these methods. Causes a warning
        /*BSXPCMessage received error for message: Connection interrupted*/

        UIImage *blurredImage = [MSImageBlur takeSnapshotOfView:self.view];
        blurredImage = [MSImageBlur blurWithCoreImage:blurredImage andView:self.view];
        
        m_BlurredImageView = [[UIImageView alloc]initWithImage:blurredImage];
    }

}

-(void)setBackgroundImage
{
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"tableview_background2.jpeg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
   
}
-(void)hideRGBGUIElements:(BOOL)hide
{
    if(hide)
    {
        self.redBand_greyBand_label.text = @"Greyscale Channel";
        self.greenBandLabel.hidden = YES;
        self.greenBandTextField.hidden = YES;
        self.blueBandLabel.hidden = YES;
        self.blueBandTextField.hidden = YES;
    }
    else
    {
        self.redBand_greyBand_label.text = @"Red Band";
        self.greenBandLabel.hidden = NO;
        self.greenBandTextField.hidden = NO;
        self.blueBandLabel.hidden = NO;
        self.blueBandTextField.hidden = NO;

    }
    
}

-(void)changeGUIBasedOnPickerviewSelection:(int)rowSelected;
{
    switch (rowSelected)
    {
            //greychannel display option selected
        case 0:
        {
            [self hideRGBGUIElements:YES];
            self.redBandTextField.hidden = NO;
            self.redBand_greyBand_label.hidden = NO;
            self.setBandsForPCAButton.hidden = YES;
            
        }
            break;

            //rgb display option selected
        case 1:
        {
            [self hideRGBGUIElements:NO];
            self.redBandTextField.hidden = NO;
            self.redBand_greyBand_label.hidden = NO;
            self.setBandsForPCAButton.hidden = YES;
        }
            break;
    
            //princiapl component grey image option selected
        case 2:
            
        {
            [self hideRGBGUIElements:YES];
            self.redBandTextField.hidden = YES;
            self.redBand_greyBand_label.hidden = YES;
            self.setBandsForPCAButton.hidden = NO;
          
          //  self.redBand_greyBand_label.text = @"Maximum Band";
           // int * defaultBands = [m_EnviFileParser getDefaultBands];
            
           // NSArray *numbers = [NSArray arrayWithObjects:[NSNumber numberWithInt:(*defaultBands)],[NSNumber numberWithInt:((*(defaultBands+1))) ],[NSNumber numberWithInt:((*(defaultBands+2)))], nil];
            
          //  int max = [[numbers valueForKeyPath:@"@max.intValue"] intValue];
           // self.redBandTextField.text =[NSString stringWithFormat:@"%i", max];
        }
            
            break;
            
            //principal component rgb image option selected 
            case 3:
        {
            [self hideRGBGUIElements:YES];
            self.redBandTextField.hidden = YES;
            self.redBand_greyBand_label.hidden = YES;
            self.setBandsForPCAButton.hidden = NO;

        }
            break;
            
        default:
            break;
    }

}

-(void)setNavControllerButtonsForNavController:(UINavigationController*)navController
{
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveBandSelection)];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(CancelBandSelection)];
    
    navController.topViewController.navigationItem.rightBarButtonItem=saveButton;
    navController.topViewController.navigationItem.leftBarButtonItem=cancelButton;
}

- (IBAction)setBandsForPCAButtonTapped:(id)sender
{
    if(m_MSBandMappingTableVC == nil)
    {
        m_MSBandMappingTableVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BandMappingTableVC"];
        
        m_NavControllerForBandTVC = [[UINavigationController alloc]initWithRootViewController:m_MSBandMappingTableVC];
        m_NavControllerForBandTVC.modalPresentationStyle = UIModalPresentationFormSheet;
        [self setNavControllerButtonsForNavController:m_NavControllerForBandTVC];
        
        
        float *wavelengths = hdrInfo.wavelength;
        [m_MSBandMappingTableVC setWavelenghths:wavelengths andBandCount:hdrInfo.bands];
    }
    
    BOOL colorMappingBool = ([self.displayTypePickerView selectedRowInComponent:0] == 2)? NO : YES;
    [m_MSBandMappingTableVC setColorMappingBOOL:colorMappingBool];

    
    [self presentViewController:m_NavControllerForBandTVC animated:YES completion:^{
        
    }];
    
    
    m_NavControllerForBandTVC.view.superview.center =CGPointMake(self.view.center.x, self.view.center.y);
    
}

-(void)saveBandSelection
{
    if(m_BandsMapped != NULL)
    {
        free(m_BandsMapped);
    }
    
    //Greyscale PCA
    if([self.displayTypePickerView selectedRowInComponent:0] == 2)
    {
    
        m_BandsMappedCount = (int)[m_MSBandMappingTableVC.m_BandsSelected count];
        m_BandsMapped = (int*) calloc(m_BandsMappedCount, sizeof(int));
    
        for(int i =0; i < m_BandsMappedCount; i++)
        {
            NSNumber *bandNum = (NSNumber*) m_MSBandMappingTableVC.m_BandsSelected[i];
        
            m_BandsMapped[i] = [bandNum intValue];
        }
    
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
    //RGB PCA
    else if ([self.displayTypePickerView selectedRowInComponent:0] == 3)
    {
        if(m_RedBandsMappedPCA != NULL)
        {
            free(m_RedBandsMappedPCA);
        }
        if(m_GreenBandsMappedPCA != NULL)
        {
            free(m_GreenBandsMappedPCA);
        }
        if(m_BlueBandsMappedPCA != NULL)
        {
            free(m_BlueBandsMappedPCA);
        }
        
        short *colorsMappedArr = [m_MSBandMappingTableVC getColorsMapped];
        m_RedBandsMappedCountPCA    = 0;
        m_GreenBandsMappedCountPCA  = 0;
        m_BlueBandsMappedCountPCA   = 0;
        
        for(int i = 0; i < hdrInfo.bands; i++)
        {
            switch (colorsMappedArr[i])
            {
                case 1:
                    m_RedBandsMappedCountPCA++;
                    break;
                    
                case 2:
                    m_GreenBandsMappedCountPCA++;
                    break;
                    
                case 3:
                    m_BlueBandsMappedCountPCA++;
                    break;
                    
                default:
                    break;
            }
            
        }
        
        m_RedBandsMappedPCA = (int*)calloc(m_RedBandsMappedCountPCA, sizeof(int));
        m_GreenBandsMappedPCA = (int*)calloc(m_GreenBandsMappedCountPCA, sizeof(int));
        m_BlueBandsMappedPCA = (int*)calloc(m_BlueBandsMappedCountPCA, sizeof(int));
        
        for(int i = 0; i < hdrInfo.bands; i++)
        {
            switch (colorsMappedArr[i])
            {
                case 1:
                    *m_RedBandsMappedPCA = i;
                    m_RedBandsMappedPCA++;
                    break;
                    
                case 2:
                    *m_GreenBandsMappedPCA = i;
                    m_GreenBandsMappedPCA++;
                    break;
                    
                case 3:
                    *m_BlueBandsMappedPCA = i;
                    m_BlueBandsMappedPCA++;
                    break;
                    
                default:
                    break;
            }
        }
        
        //reset pointers to beginning of their array
        m_RedBandsMappedPCA-=m_RedBandsMappedCountPCA;
        m_GreenBandsMappedPCA-=m_GreenBandsMappedCountPCA;
        m_BlueBandsMappedPCA-=m_BlueBandsMappedCountPCA;
        
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];
        
    }
    
}

-(void)CancelBandSelection
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];


}

- (IBAction)doneButtonTapped:(id)sender
{
    //TODO: Create public setters for m_EnviFileparser for modifying hdr info before image load
        //m_HyperspectralData = [[MSHyperspectralData alloc]initWithMSFileParser:m_EnviFileParser];
    
    if([self.displayTypePickerView selectedRowInComponent:0] == 1)
    {
        if(([self.redBandTextField.text intValue] > (hdrInfo.bands-1) ||
            [self.greenBandTextField.text intValue] > (hdrInfo.bands-1))||
            [self.blueBandTextField.text intValue] > (hdrInfo.bands-1))
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please choose bands within range" delegate:nil cancelButtonTitle:@"" otherButtonTitles: nil];
            [alert show];
            
            return;
        }
    }
    
    if([ self.displayTypePickerView selectedRowInComponent:0]==2)
    {
        if([self.redBandTextField.text length]==0)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please Enter Max Band Value" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
            return;
        }
       
        if( m_BandsMappedCount > 150)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please choose less than 151 bands" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
            return;
        }
    }
    
    if([ self.displayTypePickerView selectedRowInComponent:0]==3)
    {
        if(m_BlueBandsMappedCountPCA <= 1   ||
           m_RedBandsMappedCountPCA <= 1    ||
           m_GreenBandsMappedCountPCA <= 1)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please select at least 2 per color Channel for PCA" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
            return;

            
        }
    }

    NSOperation *startOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           
                           [self.view addSubview:m_BlurredImageView];
                           [self.view setUserInteractionEnabled:NO];
                           
                           [self.view addSubview:self.loadDataProgressView];
                           [self.view addSubview:self.loadingImageLabel];
                           self.loadDataProgressView.progress = 0.0f;
                           self.loadDataProgressView.hidden = NO;
                           self.loadingImageLabel.hidden = NO;
                           
                       });

        m_HyperspectralData = [[MSHyperspectralData alloc]initWithMSFileParser:m_EnviFileParser];
        
        m_HyperspectralData.delegate = self;
        
        //hardcoding image file name for now
        NSString *hyperspectralImageFile = [m_HeaderFileName stringByAppendingString:@".bip"];
        [m_HyperspectralData loadHyperspectralImageFile:hyperspectralImageFile];

       // [m_HyperspectralData loadHyperspectralImageFile:@"f970620t01p02_r03_sc03.a.bip"];
        
    }];
    
    NSOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self performSegueWithIdentifier:@"PushToImageViewer" sender:self];
            [m_BlurredImageView removeFromSuperview];

        });

    }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    [completionOperation addDependency:startOperation];
    [queue addOperation:startOperation];
    [queue addOperation:completionOperation];
    
    
    //free(m_BandsMapped);
    
}

-(void)setViewControllerFields
{
    self.samplesTextField.text =  [NSString stringWithFormat:@"%i",[m_EnviFileParser getSampleSize]];
    self.linesTextField.text =    [NSString stringWithFormat:@"%i",[m_EnviFileParser getLineSize]];
    self.interleaveTypeTextField.text = [NSString stringWithFormat:@"%s",[m_EnviFileParser getInterleaveType]];
    
    self.bandsTextField.text = [NSString stringWithFormat:@"%i",[m_EnviFileParser getBandSize]];
    
    int dataType = [m_EnviFileParser getDataType];
    
    switch (dataType)
    {
        case 0:
            ;
            break;
            case 1:
            ;
            break;
            case 2:
            self.dataTypeTextField.text = @"16-bit Signed";
            break;
            
            /*Fill in for other data types*/
            
        default:
            break;
    }
    
    self.dataLengthLabel.text = [NSString stringWithFormat:@"%i Total Samples", [m_EnviFileParser getSampleSize] * [m_EnviFileParser getLineSize] * [m_EnviFileParser getBandSize]];
    
    int byteOrder = [m_EnviFileParser getByteOrder];
    if(byteOrder == 0)
    {
        self.byteOrderTextField.text = @"Little Endian";
        
    }
    else
    {
        self.byteOrderTextField.text = @"Big Endian";
        
    }
    
    int *defaultBands = [m_EnviFileParser getDefaultBands];
    
    if(defaultBands != NULL)
    {
        self.redBandTextField.text = [NSString stringWithFormat:@"%i",(int)*defaultBands];
        self.greenBandTextField.text = [NSString stringWithFormat:@"%i",(int)*(defaultBands+1)];
        self.blueBandTextField.text = [NSString stringWithFormat:@"%i",(int)*(defaultBands+2)];
    }

    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)parseHeaderFile
{
    BOOL rc = NO;
    
    if(m_HeaderFileName.length == 0)
    {
        return rc;
    }
    
    m_EnviFileParser = [[MSENVIFileParser alloc]initWithFileName:m_HeaderFileName];
    
    rc = [m_EnviFileParser hdrReadSuccess];
    if(!rc)
    {
        return rc;
    }
    
    hdrInfo.dataType = [m_EnviFileParser getDataType];
    hdrInfo.bands = [m_EnviFileParser getBandSize];
    hdrInfo.lines = [m_EnviFileParser getLineSize];
    hdrInfo.interleave = [m_EnviFileParser getInterleaveType];
    hdrInfo.header_Offset = [m_EnviFileParser getHeaderOffset];
    hdrInfo.byteOrder = [m_EnviFileParser getByteOrder];
    hdrInfo.fileType = [m_EnviFileParser getFileType];
    hdrInfo.defaultBands = [m_EnviFileParser getDefaultBands];
    hdrInfo.wavelength = [m_EnviFileParser getWaveLength];
    hdrInfo.samples = [m_EnviFileParser getSampleSize];

    rc = YES;
    
    return rc;
    
}

-(cv::Mat)deblurImage:(cv::Mat)matrix
{
    cv::Mat dstMatrix;
    
    cv::GaussianBlur(matrix, dstMatrix, cv::Size(3, 3), 3);
    cv::addWeighted(matrix, 1.5, dstMatrix, -0.5, 0, dstMatrix);
    
    return dstMatrix;
}

#pragma mark - UIPickerView Data Source Methods

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return displayTypeOptions.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

#pragma mark - UIPickerView Delegate Methods
/*
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return displayTypeOptions[row];
}
 */

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 44)];
    label.backgroundColor = [UIColor lightGrayColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    label.text = displayTypeOptions[row];
    return label;
}



- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self changeGUIBasedOnPickerviewSelection:(int)row];

    
}


#pragma mark - Progress View update delegate(called in MSHyperspectralData class during image load)

-(void)updateProgressView:(float)progress
{
    
    [self.loadDataProgressView setProgress:progress animated:YES];

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    cv::Mat matrix;
    cv::Mat dstMatix;
    
    ViewController *imageViewer = (ViewController*)[segue destinationViewController];

    
    //single greyscale band
    int selectedRow = (int)[self.displayTypePickerView selectedRowInComponent:0];
    switch (selectedRow)
    {
            //push to imageviewer with grayscale
        case 0:
        {
            
            matrix = [m_HyperspectralData createCVMatrixForBand:[self.redBandTextField.text intValue]];
            dstMatix = [self deblurImage:matrix];

            [imageViewer setGreyScaleBand:[self.redBandTextField.text intValue]];
            
        }
        break;
            
            //push to imageviewer with rgb
        case 1:
        {
            int redBand = [self.redBandTextField.text intValue];
            int greenBand = [self.greenBandTextField.text intValue];
            int blueBand = [self.blueBandTextField.text intValue];
            
            matrix = [m_HyperspectralData createCVBGRMatrixWithBlueBand:blueBand greenBand:greenBand andRedBand:redBand];
            dstMatix = [self deblurImage:matrix];

            [imageViewer setGreyScaleBand:-1];
        }
        break;
           
            //push to imageviewer with grayscale PCA
        case 2:
        {
            /*
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               
                               self.loadDataProgressView.hidden = YES;
                               self.loadingImageLabel.hidden = YES;

                               m_ProgressHud = [[MBProgressHUD alloc]initWithView:self.view];
                               
                               m_ProgressHud.labelText =@"Running Principal Component Analysis";
                               
                               [m_BlurredImageView addSubview:m_ProgressHud];
                               
                               [m_ProgressHud show:YES];
                           });
            
             */
            
           //matrix = [m_HyperspectralData createPrincipalComponentMatrixWithMaxBand:self.redBandTextField.text.intValue];
            
            matrix = [m_HyperspectralData createPrincipalComponentMatrixWithBandArray:m_BandsMapped andBandArraySize:m_BandsMappedCount];
            dstMatix = [self deblurImage:matrix];
            
            [imageViewer setGreyScaleBand:-1];
            
        }
            break;
            
            //push to imageviewer with rgb PCA
        case 3:
        {
            matrix = [m_HyperspectralData createPrincipalComponentMatrixWithRedBandArray:m_RedBandsMappedPCA
                                                                            redBandsSize:m_RedBandsMappedCountPCA
                                                                    greenBands:m_GreenBandsMappedPCA greenBandsSize:m_GreenBandsMappedCountPCA
                                                                    blueBands:m_BlueBandsMappedPCA blueBandsSize:m_BlueBandsMappedCountPCA];
           
           dstMatix = [self deblurImage:matrix];
            
        [imageViewer setGreyScaleBand:-1];

        }
            break;
            
        default:
            break;
    }
    
    [m_ProgressHud removeFromSuperview];

    
    UIImage *image = [m_HyperspectralData UIImageFromCVMat:dstMatix];
    
    [imageViewer setHyperspectralDataPointer:m_HyperspectralData];
    [imageViewer setImageViewWithImage:image];
    
    matrix.release();
    dstMatix.release();
}


@end
