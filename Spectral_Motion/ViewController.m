//
//  ViewController.m
//  Spectral Motion
//
//  Created by Kale Evans on 12/23/14.
//  Copyright (c) 2014 Kale Evans. All rights reserved.
//

#import "ViewController.h"
#import "MSENVIFileParser.h"
#import "MSHyperspectralData.h"
#import "MVYSideMenuController.h"
#import "UIView+Glow.h"
#import "MSHyperspectralDataPlotter.h"
#import "ImageViewerOptionsPopOver.h"
#import "MSImageInfoPanelVC.h"
#import "SharedHeader.h"



@interface ViewController ()<UIGestureRecognizerDelegate, OptionSelectedDelegate>
{
    MSHyperspectralData * m_HyperspectralData;
    HDRINFO m_HdrInfo;
    UIImage *m_Image;
    int m_ChosenGreyScaleBand;
    UIPanGestureRecognizer *m_PanGestureRecognizer;
    UIPinchGestureRecognizer *m_PinchGestureRecognizer;
    UILongPressGestureRecognizer * m_LongPressGestureRecognizer;
    NSMutableArray *m_PanGestureArray;
    NSMutableArray *m_TapGesutreArray;
    NSDictionary *m_ImageViewInfoViewDict;
    MSImageInfoPanelVC *m_ImageInfoPanelVC;
    UIPopoverController *m_ImageViewerOptionsPopOver;
    CPTGraphHostingView *m_PlotView;
    MSHyperspectralDataPlotter *m_DataPlotter;
    
}
@property(strong,nonatomic) UIImageView *imageView2;

-(void)configureSideMenu;
-(void)setNavigationBarTitle;
-(void)showSideMenu;
-(void)handlePan:(UIPanGestureRecognizer*)panGestureRecognizer;
-(void)handleTap:(UITapGestureRecognizer*)tapGestureRecognizer;
-(void)resizeScrollView:(UIPinchGestureRecognizer*)pinchGestureRecognizer;
-(void)initImageView;
-(void)addPanGestureRecognizerForView:(UIView*)view;
-(void)addPinchGestureRecognizerForView:(UIView*)view;
-(void)addLongPressGestureRecognizerForView:(UIView*)view;
-(void)addTapGestureRecognizerForView:(UIView*)view;
-(void)longPressEventOccurred:(UILongPressGestureRecognizer*)sender;
-(void)setImageViewBorderForView:(UIView*)view;
-(void)addGraphToView;
-(void)addImageInfoPanelToView;
-(void)setImageInfoPanelValuesForXCoordinate:(int) xCoordinate andYCoordinate:(int) yCoordinate withImageView:(UIImageView*)imageView;
-(RGBPixel)getPixelForImage:(UIImage*) image AtXCoordinate:(int)x andYCoordinate:(int)Y;
-(cv::Mat)deblurImage:(cv::Mat)matrix;

@end

@implementation ViewController
@synthesize imageView2;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if(m_ChosenGreyScaleBand == -1)
    {
        self.sliderBackgroundView.hidden = YES;
        self.bandSlider.hidden = YES;
        self.sliderValueLabel.hidden = YES;
    }
    else
    {
        self.sliderBackgroundView.hidden = NO;
        self.bandSlider.hidden = NO;
        self.sliderValueLabel.hidden = NO;

    }
    
    [self initImageView];
    self.sliderValueLabel.text = [NSString stringWithFormat:@"Band %i",m_ChosenGreyScaleBand];
    self.bandSlider.value = m_ChosenGreyScaleBand;
    
    [self addPanGestureRecognizerForView:self.imageView2];
    
    [self addPinchGestureRecognizerForView:self.imageView2];
    
    [self addLongPressGestureRecognizerForView:self.imageView2];
    
    [self addTapGestureRecognizerForView:self.imageView2];
    
    [self setImageViewBorderForView:self.imageView2];
    
    [self configureSideMenu];
    [self setNavigationBarTitle];
    
}

-(void)setNavigationBarTitle
{
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView)
    {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont boldSystemFontOfSize:20.0];
        titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        
        titleView.textColor = [UIColor whiteColor];         
        self.navigationItem.titleView = titleView;
    }
    titleView.text = @"Image Viewer";
    [titleView sizeToFit];
    
    
}

-(void)configureSideMenu
{
    MVYSideMenuController *sideMenuController = [self sideMenuController];
    sideMenuController.options.panFromBezel = YES;
    sideMenuController.options.panFromNavBar = YES;
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_setting"] style:UIBarButtonItemStylePlain target:self action:@selector(showSideMenu)];
    
    
    self.navigationItem.rightBarButtonItem = menuButton;
    
}

-(void)showSideMenu
{
    MVYSideMenuController *sideMenuController = [self sideMenuController];
    if (sideMenuController)
    {
        [sideMenuController openMenu];
    }
    
}

-(void)initImageView
{
    imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, m_Image.size.width, m_Image.size.height)];
    
    imageView2.center = self.view.center;
    
    self.imageView2.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView2.image = m_Image;
    self.imageView2.userInteractionEnabled = YES;
    self.imageView2.multipleTouchEnabled = YES;
    self.imageView2.tag = 27;
    [self.view addSubview:imageView2];
    
    
    //self.scrollViewForImage.minimumZoomScale = 0.5;
    //self.scrollViewForImage.maximumZoomScale = 6.0;
    //self.scrollViewForImage.contentSize = self.imageView.image.size;
    //self.scrollViewForImage.delegate = self;
    
}

-(void)setImageInfoPanelValuesForXCoordinate:(int) xCoordinate andYCoordinate:(int) yCoordinate withImageView:(UIImageView*)imageView
{
    if(m_ImageInfoPanelVC !=nil)
    {
        m_ImageInfoPanelVC.imageTypeLabel.text = @"RGB";
        m_ImageInfoPanelVC.lineLabel.text = [NSString stringWithFormat:@"%i", yCoordinate];
        m_ImageInfoPanelVC.sampleLabel.text = [NSString stringWithFormat:@"%i", xCoordinate];
        RGBPixel pixel = [self getPixelForImage:imageView.image AtXCoordinate:xCoordinate andYCoordinate:yCoordinate];
        
        m_ImageInfoPanelVC.redPixelValLabel.text = [NSString stringWithFormat:@"%i", pixel.red];
        m_ImageInfoPanelVC.greenPixelValueLabel.text = [NSString stringWithFormat:@"%i", pixel.green];
        m_ImageInfoPanelVC.bluePixelValueLabel.text = [NSString stringWithFormat:@"%i", pixel.blue];
        
        m_ImageInfoPanelVC.redPixelValueImageView.backgroundColor =
        [UIColor colorWithRed:pixel.red
                        green:0.0f
                         blue:0.0f
                        alpha:1.0];
        
        m_ImageInfoPanelVC.greenPixelValueImageView.backgroundColor =
        [UIColor colorWithRed:0.0f
                        green:pixel.green
                         blue:0.0f
                        alpha:1.0];
        
        m_ImageInfoPanelVC.bluePixelValueImageView.backgroundColor =
        [UIColor colorWithRed:0.0f
                        green:0.0f
                         blue:pixel.blue
                        alpha:1.0f];
        
    }
    
}

-(RGBPixel)getPixelForImage:(UIImage *)image AtXCoordinate:(int)xCoordinate andYCoordinate:(int)yCoordinate
{
    RGBPixel pixel;
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    const uint8_t* data =  CFDataGetBytePtr(pixelData);
    
    //rgb pixel(no alpha)
    int depth = 3;
    
    uint32_t pixelIdx = (xCoordinate + (yCoordinate * (image.size.width ))) * depth;

    NSLog(@"pixelIdx %i", pixelIdx);
    
    pixel.red = (data[pixelIdx]);
    pixel.green = (data[pixelIdx + 1]);
    pixel.blue = (data[pixelIdx + 2]);
    
    NSLog(@"red: %i", pixel.red);
    NSLog(@"green: %i", pixel.green);
    NSLog(@"blue: %i", pixel.blue);
    CFRelease(pixelData);
    
    return pixel;
}

-(void)addImageInfoPanelToView
{
    if(m_ImageInfoPanelVC == nil)
    {
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
       m_ImageInfoPanelVC = (MSImageInfoPanelVC*) [mainStoryBoard instantiateViewControllerWithIdentifier:@"MSImageInfoPanelVC"];
        
        [self addPanGestureRecognizerForView:m_ImageInfoPanelVC.view];

        [self addChildViewController:m_ImageInfoPanelVC];
        
        m_ImageInfoPanelVC.view.frame = CGRectMake(500.0f, m_PlotView.frame.origin.y, 250, 300);
        [self.view addSubview:m_ImageInfoPanelVC.view];
        [m_ImageInfoPanelVC didMoveToParentViewController:self];
        
        //x = 10 and y = 10 default graphview parameters
        [self setImageInfoPanelValuesForXCoordinate:10
                                     andYCoordinate:10
                                      withImageView:imageView2];
    }
    
}

-(void)handleTap:(UITapGestureRecognizer*)tapGestureRecognizer
{
    
//    if(tapGestureRecognizer.state != UIGestureRecognizerStateBegan)
//    {
//        return;
//    }
    NSLog(@"Handle tap fired");
    
    if(m_PlotView == nil)
    {
        return;
    }
    
    CGPoint location = [tapGestureRecognizer locationInView:tapGestureRecognizer.view];
    
    NSLog(@"x tapped %f y tapped %f", location.x, location.y);

    
    if(location.x > m_HdrInfo.samples || location.y > m_HdrInfo.lines)
    {
        return;
    }
    
    [m_DataPlotter updateScatterPlotForAllBandsWithXCoordinate:(int)location.x andYCoordinate:(int)location.y];
    [self setImageInfoPanelValuesForXCoordinate:(int)location.x andYCoordinate:(int)location.y withImageView:(UIImageView*)tapGestureRecognizer.view];
    
}

-(void)addGraphToView
{
    NSLog(@"add to graph view");
    
   m_DataPlotter = [[MSHyperspectralDataPlotter alloc]initWithHyperpsectralData:m_HyperspectralData andHeader:m_HdrInfo];
    
   // [dataPlotter createScatterPlotWithView:self.view];
    [m_DataPlotter createScatterPlot];
    
    m_PlotView = [m_DataPlotter getGraphView];
    
    [self addPanGestureRecognizerForView:m_PlotView];
    
    [self.view addSubview:m_PlotView];
    
    //add panel for pixel value viewing
    [self addImageInfoPanelToView];
    
    [m_DataPlotter graphStartRunLoop];
}

-(void)addTapGestureRecognizerForView:(UIView*)view
{
    if(m_TapGesutreArray == nil)
    {
        m_TapGesutreArray = [[NSMutableArray alloc]init];
    }
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    
    tapGestureRecognizer.cancelsTouchesInView = YES;
    tapGestureRecognizer.delaysTouchesBegan = YES;
    tapGestureRecognizer.delegate = self;
    
    
    [view addGestureRecognizer:tapGestureRecognizer];
    
    [m_TapGesutreArray addObject:tapGestureRecognizer];
    
}



-(void)addPanGestureRecognizerForView:(UIView*)view
{
    if(m_PanGestureArray == nil)
    {
        m_PanGestureArray = [[NSMutableArray alloc]init];
    }
    
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    
    panGestureRecognizer.delegate = self;
    
    [view addGestureRecognizer:panGestureRecognizer];
    
    [m_PanGestureArray addObject:panGestureRecognizer];
 /*
    if(m_PanGestureRecognizer == nil)
    {
        m_PanGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                  initWithTarget:self
                                  action:@selector(handlePan:)];
    }
    [view addGestureRecognizer:m_PanGestureRecognizer];
  */
    
}
-(void)addPinchGestureRecognizerForView:(UIView*)view
{
    if(m_PinchGestureRecognizer == nil)
    {
        m_PinchGestureRecognizer = [[UIPinchGestureRecognizer alloc]
                                    initWithTarget:self
                                    action:@selector(resizeScrollView:)];
    }
    
    [view addGestureRecognizer:m_PinchGestureRecognizer];
}

-(void)addLongPressGestureRecognizerForView:(UIView*)view
{
    m_LongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressEventOccurred:)];
    [m_LongPressGestureRecognizer setMinimumPressDuration:1];
    [view addGestureRecognizer:m_LongPressGestureRecognizer];
    
}

-(void)longPressEventOccurred:(UILongPressGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        ;
    }
    else if (sender.state == UIGestureRecognizerStateBegan)
    {
        m_ImageViewerOptionsPopOver = nil;
        SourceContext context;
        
        if([sender.view isKindOfClass:UIImageView.class])
        {
            context = ImageViewContext;
        }
        else if ([sender.view isKindOfClass:CPTGraphHostingView.class])
        {
            context = GraphViewContext;
        }
        
        ImageViewerOptionsPopOver *popOverContent = [[ImageViewerOptionsPopOver alloc]initFromContext:context];
        popOverContent.tableView.scrollEnabled = NO;
        popOverContent.delegate = self;
        
        m_ImageViewerOptionsPopOver = [[UIPopoverController alloc]initWithContentViewController:popOverContent];
        [m_ImageViewerOptionsPopOver presentPopoverFromRect:sender.view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
        [m_ImageViewerOptionsPopOver setPopoverContentSize:CGSizeMake(200, 100) animated:YES];
        
        
        /*
        if(m_PlotView ==nil)
        {
            [self addGraphToView];
        }
         */

    }
    
}

-(void)didSelectOption:(NSUInteger)optionSelected
{
    
    [m_ImageViewerOptionsPopOver dismissPopoverAnimated:NO];
    
    switch (optionSelected)
    {
        case 0:
        {
            if(m_PlotView ==nil)
            {
                [self addGraphToView];
                //[self addImageInfoPanelToView];
            }
            
        }
            break;
            
        default:
            break;
    }
    
}



-(void)setImageViewBorderForView:(UIView*)view
{
    UIColor *borderColor = [UIColor colorWithRed:182.0/255.0
                                           green:10.0/255.0
                                            blue:96.0/255.0
                                           alpha:1.0];
    
    [view.layer setBorderColor:borderColor.CGColor];
    [view.layer setBorderWidth:3.0];
    
}
-(void)resizeScrollView:(UIPinchGestureRecognizer*)pinchGestureRecognizer
{
    NSLog(@"pinch fired");
    pinchGestureRecognizer.view.transform = CGAffineTransformScale(pinchGestureRecognizer.view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
    pinchGestureRecognizer.scale = 1;


}



-(void)handlePan:(UIPanGestureRecognizer *)panGestureRecognizer
{
    NSLog(@"pan fired");
    CGPoint translation = [panGestureRecognizer translationInView:self.view];
    
    // Figure out where the user is trying to drag the view.
    CGPoint newCenter = CGPointMake(panGestureRecognizer.view.center.x + translation.x,
                                    panGestureRecognizer.view.center.y + translation.y);
    
    // limit the bounds but always update the center
    newCenter.y = MAX(160, newCenter.y);
    newCenter.y = MIN(800, newCenter.y);
    newCenter.x = MAX(160, newCenter.x);
    newCenter.x = MIN(800, newCenter.x);
    
    
    panGestureRecognizer.view.center = newCenter;
    [panGestureRecognizer setTranslation:CGPointZero inView:self.view];
    
    
#if 0
    
    if(panGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        
        
    }
    
    else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        
        CGPoint center = panGestureRecognizer.view.center;
        CGPoint translation = [panGestureRecognizer translationInView:panGestureRecognizer.view];
        
        if(abs(center.y + translation.y)>850)
        {
            center=CGPointMake(center.x +translation.x,
                               850);
        }
       /*
        if(abs(center.y + translation.y)>200)
        {
            center=CGPointMake(center.x +translation.x,
                               200);
        }
        */
        if(abs(center.x + translation.x)>680)
        {
            center=CGPointMake(680,
                               center.y +translation.y);
        }

     
        else
        {
            center = CGPointMake(center.x + translation.x,
                                 center.y + translation.y);
        
            panGestureRecognizer.view.center = center;
            [panGestureRecognizer setTranslation:CGPointZero inView:panGestureRecognizer.view];
        
        }
    
    }
#endif
}



-(void)viewWillDisappear:(BOOL)animated
{
    //very important to release memory or will run into warnings
    [m_HyperspectralData releaseHypCube];
    m_HyperspectralData = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setImageViewWithImage:(UIImage*)image
{
    m_Image = image;
}

-(void)setHyperspectralDataPointer:(MSHyperspectralData*)hyperspectralData
{
    m_HyperspectralData = hyperspectralData;
}

-(void)setHyperspectralDataHeader:(HDRINFO)hdrInfo
{
    m_HdrInfo = hdrInfo;
}

-(void)testHdrParser
{
    
}

-(void)setGreyScaleBand:(int)greyscaleBand
{
    m_ChosenGreyScaleBand = greyscaleBand;
}

- (IBAction)sliderValueChanged:(id)sender
{
    float bandIdx = self.bandSlider.value;
    
    int bandRoundedValue = roundl(bandIdx); // Rounds float to an integer
    self.sliderValueLabel.text = [NSString stringWithFormat:@"Band %i",bandRoundedValue];
    
    cv::Mat matrix = [m_HyperspectralData createCVMatrixForBand:bandRoundedValue];
    cv::Mat dstMatrix = [self deblurImage:matrix];
    
    UIImage *singleBandGreyScaleImg = [m_HyperspectralData UIImageFromCVMat:dstMatrix];
        
    NSLog(@"image complete..sending image to view");
    
    self.imageView2.contentMode = UIViewContentModeScaleAspectFit;
    
    self.imageView2.image = singleBandGreyScaleImg;
    
    matrix.release();
    dstMatrix.release();
    
}

-(cv::Mat)deblurImage:(cv::Mat)matrix
{
    cv::Mat dstMatrix;
    
    cv::GaussianBlur(matrix, dstMatrix, cv::Size(3, 3), 3);
    cv::addWeighted(matrix, 1.5, dstMatrix, -0.5, 0, dstMatrix);
    
    return dstMatrix;
}



#pragma mark - UIGestureRecognizer Delegate

//to simulataneously recognize UIPanGesturereRecognizers
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}


/*
#pragma mark - Touch event implementation
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //  [super touchesMoved:touches withEvent:event];
    NSArray *touchObjects = [touches allObjects];
    UIImageView *selectedImageview;
    
    for(UITouch * touch in touchObjects)
    {
        //all multispectral images added will be given tag 27 for id purposes
        if(touch.view.tag == 27)
        {
            NSLog(@"did touch uiimageView");
            selectedImageview = (UIImageView*)touch.view;
            break;
        }
    }
    [selectedImageview stopGlowing];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray *touchObjects = [touches allObjects];
    UIImageView *selectedImageview;
    
    for(UITouch * touch in touchObjects)
    {
        //all multispectral images added will be given tag 27 for id purposes
        if(touch.view.tag == 27)
        {
            NSLog(@"did touch uiimageView");
            selectedImageview = (UIImageView*)touch.view;
            break;
        }
    }
    if(selectedImageview != nil)
    {
        [selectedImageview startGlowing];
    }
    //if user clicks somewhere else on screen, stop all objects from glowing
    else
    {
        for(UIView *view in self.view.subviews)
        {
            [view stopGlowing];
        }
    }
    
}
*/



/*
#pragma mark - UIScrollView Delegate methods

-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}
*/
@end
