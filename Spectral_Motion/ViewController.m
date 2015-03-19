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

@interface ViewController ()
{
    MSHyperspectralData * m_HyperspectralData;
    UIImage *m_Image;
    int m_ChosenGreyScaleBand;
    UIPanGestureRecognizer *m_PanGestureRecognizer;
    UIPinchGestureRecognizer *m_PinchGestureRecognizer;
    
}
@property(strong,nonatomic) UIImageView *imageView2;

-(void)configureSideMenu;
-(void)setNavigationBarTitle;
-(void)showSideMenu;
-(void)handlePan:(UIPanGestureRecognizer*)panGestureRecognizer;
-(void)resizeScrollView:(UIPinchGestureRecognizer*)pinchGestureRecognizer;
-(void)initImageView;
-(void)addPanGestureRecognizerForView:(UIView*)view;
-(void)addPinchGestureRecognizerForView:(UIView*)view;
-(void)setImageViewBorderForView:(UIView*)view;
-(cv::Mat)deblurImage:(cv::Mat)matrix;

@end

@implementation ViewController
@synthesize imageView2;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if(m_ChosenGreyScaleBand == -1)
    {
        self.bandSlider.hidden = YES;
        self.sliderValueLabel.hidden = YES;
    }
    else
    {
        self.bandSlider.hidden = NO;
        self.sliderValueLabel.hidden = NO;

    }
    
    [self initImageView];
    self.sliderValueLabel.text = [NSString stringWithFormat:@"Band %i",m_ChosenGreyScaleBand];
    self.bandSlider.value = m_ChosenGreyScaleBand;
    
    [self addPanGestureRecognizerForView:self.imageView2];
    
    [self addPinchGestureRecognizerForView:self.imageView2];
    
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
    [self.view addSubview:imageView2];
    
    
    //self.scrollViewForImage.minimumZoomScale = 0.5;
    //self.scrollViewForImage.maximumZoomScale = 6.0;
    //self.scrollViewForImage.contentSize = self.imageView.image.size;
    //self.scrollViewForImage.delegate = self;
    
}

-(void)addPanGestureRecognizerForView:(UIView*)view
{
    if(m_PanGestureRecognizer == nil)
    {
        m_PanGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                  initWithTarget:self
                                  action:@selector(handlePan:)];
    }
    [view addGestureRecognizer:m_PanGestureRecognizer];
    
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

/*
#pragma mark - UIScrollView Delegate methods

-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}
*/
@end
