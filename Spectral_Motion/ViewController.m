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

@interface ViewController ()
{
    MSHyperspectralData * m_HyperspectralData;
    UIImage *m_Image;
    int m_ChosenGreyScaleBand;
    UIPanGestureRecognizer *m_PanGestureRecognizer;
    
}

-(void)handlePan:(UIPanGestureRecognizer*)panGestureRecognizer;
-(void)addPanGestureRecognizerForView:(UIView*)view;
-(void)setImageViewBorderForView:(UIView*)view;
-(cv::Mat)deblurImage:(cv::Mat)matrix;

@end

@implementation ViewController

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

    
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.image = m_Image;
    
    self.sliderValueLabel.text = [NSString stringWithFormat:@"Band %i",m_ChosenGreyScaleBand];
    self.bandSlider.value = m_ChosenGreyScaleBand;
    
    self.scrollViewForImage.minimumZoomScale = 0.5;
    self.scrollViewForImage.maximumZoomScale = 6.0;
    self.scrollViewForImage.contentSize = self.imageView.image.size;
    self.scrollViewForImage.delegate = self;
    
    [self addPanGestureRecognizerForView:self.scrollViewForImage];
    
    [self setImageViewBorderForView:self.scrollViewForImage];
}

-(void)addPanGestureRecognizerForView:(UIView*)view
{
    if(m_PanGestureRecognizer == nil)
    {
        m_PanGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    }
    
    [view addGestureRecognizer:m_PanGestureRecognizer];
    
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


-(void)handlePan:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if(panGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        
        
    }
    
    else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        
        CGPoint center = panGestureRecognizer.view.center;
        CGPoint translation = [panGestureRecognizer translationInView:panGestureRecognizer.view];
        
        if(abs(center.y +translation.y)>850)
        {
            center=CGPointMake(center.x +translation.x,
                               850);
        }
        else
        {
            center = CGPointMake(center.x + translation.x,
                                 center.y + translation.y);
        
            panGestureRecognizer.view.center = center;
            [panGestureRecognizer setTranslation:CGPointZero inView:panGestureRecognizer.view];
        
        }
    
    }
        
}

-(void)viewWillDisappear:(BOOL)animated
{
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
    self.sliderValueLabel.text = [NSString stringWithFormat:@"%i",bandRoundedValue];
    
    cv::Mat matrix = [m_HyperspectralData createCVMatrixForBand:bandRoundedValue];
    cv::Mat dstMatrix = [self deblurImage:matrix];
    
    
    UIImage *singleBandGreyScaleImg = [m_HyperspectralData UIImageFromCVMat:dstMatrix];
        
    NSLog(@"image complete..sending image to view");
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.imageView.image = singleBandGreyScaleImg;
    
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

#pragma mark - UIScrollView Delegate methods

-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
