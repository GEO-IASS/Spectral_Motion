//
//  MSHyperspectralDataPlotter.m
//  Spectral_Motion
//
//  Created by Kale Evans on 3/23/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import "MSHyperspectralDataPlotter.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Accelerate/Accelerate.h>

@interface MSHyperspectralDataPlotter()<CPTPlotDataSource, CPTPlotSpaceDelegate>
{
        NSMutableArray *m_XValues;
        NSMutableArray *m_YValues;
        
        NSNumber *m_YMaxValue;
        NSNumber *m_YMinValue;
        
        NSNumber *m_XMaxValue;
        NSNumber *m_XMinValue;
    
        HDRINFO m_HdrInfo;
        MSHyperspectralData *m_HyperspectralData;
}

-(void)createScatterPlot;

@end


@implementation MSHyperspectralDataPlotter
@synthesize m_Graph, m_GraphHostingView, m_BoundPlot, m_PlotSpace;

-(id)initWithHyperpsectralData:(MSHyperspectralData*)hyperspectralData andHeader:(HDRINFO)hdrInfo
{
    if(self = [super init])
    {
        m_XValues = [[hyperspectralData getWavelengthValues] copy];
        
        m_YValues = [[hyperspectralData getPixelValuesForAllBandsAtXCoordinate:10 andYCoordinate:10] copy];
        
        //get max x axis and y axis values for proper scaling of graph
        m_YMaxValue = [m_YValues valueForKeyPath:@"@max.self"];
        m_YMinValue = [m_YValues valueForKeyPath:@"@min.self"];
        
        m_XMaxValue = [m_XValues valueForKeyPath:@"@max.self"];
        m_XMinValue = [m_XValues valueForKeyPath:@"@min.self"];
        
        m_HdrInfo = hdrInfo;
        m_HyperspectralData = hyperspectralData;
        
    }
    
    return self;
    
}

-(void)createScatterPlotWithView:(UIView*)view
{
    
    // Create graph from a custom theme
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme      =  [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [newGraph applyTheme:theme];
    self.m_Graph = newGraph;
    
    newGraph.paddingLeft   = 70.0;
    newGraph.paddingTop    = 50.0;
    newGraph.paddingRight  = 10.0;
    newGraph.paddingBottom = 50.0;
    
    //  CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.view;
    m_GraphHostingView  = [[CPTGraphHostingView alloc]initWithFrame:CGRectMake(100, 100, 500, 500)];
    m_GraphHostingView.hostedGraph = newGraph;
    [view addSubview:m_GraphHostingView];
    
    
    newGraph.plotAreaFrame.masksToBorder = NO;
    
    // Setup plot space
    //CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    m_PlotSpace = (CPTXYPlotSpace *) newGraph.defaultPlotSpace;
    m_PlotSpace.allowsUserInteraction = YES;
    m_PlotSpace.xRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(m_XMinValue.doubleValue) length:CPTDecimalFromDouble(m_XMaxValue.doubleValue)];
    m_PlotSpace.yRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(m_YMinValue.doubleValue) length:CPTDecimalFromDouble(m_YMaxValue.doubleValue)];
    m_PlotSpace.delegate = self;
    
    
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength         = CPTDecimalFromDouble(0.25);
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(m_XMinValue.doubleValue);
    x.minorTicksPerInterval       = 2;
    x.title = @"Wavalength in micrometers(µm)";
    NSArray *exclusionRanges = @[[CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.00) length:CPTDecimalFromDouble(m_XMinValue.doubleValue)],
                                 [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(m_XMaxValue.doubleValue) length:CPTDecimalFromDouble(m_XMaxValue.doubleValue + 0.5)]];
    x.labelExclusionRanges = exclusionRanges;
    
    CPTXYAxis *y = axisSet.yAxis;
    
    //so we can have four intervals for y axis, we divide max value by 4
    y.majorIntervalLength         = CPTDecimalFromDouble((double)(m_YMaxValue.doubleValue/4));
    y.minorTicksPerInterval       = 5;
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(m_XMinValue.doubleValue);
    
    
    // Create a blue plot area
   // CPTScatterPlot *boundLinePlot = [[CPTScatterPlot alloc] init];
    m_BoundPlot = [[CPTScatterPlot alloc]init];
    m_BoundPlot.identifier = @"Blue Plot";
    
    CPTMutableLineStyle *lineStyle = [m_BoundPlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth         = 1.0;
    lineStyle.lineColor         = [CPTColor blueColor];
    m_BoundPlot.dataLineStyle = lineStyle;
    
    m_BoundPlot.dataSource = self;
    [newGraph addPlot:m_BoundPlot];
    
}

-(void)updateScatterPlotForAllBandsWithXCoordinate:(int) xCoordinate andYCoordinate:(int) yCoordinate
{
    m_YValues = nil;
    
    m_YValues = [[m_HyperspectralData getPixelValuesForAllBandsAtXCoordinate:xCoordinate andYCoordinate:yCoordinate] copy];
    
    //get max x axis and y axis values for proper scaling of graph
    m_YMaxValue = [m_YValues valueForKeyPath:@"@max.self"];
    m_YMinValue = [m_YValues valueForKeyPath:@"@min.self"];
    
    [m_BoundPlot reloadData];
}


-(void)graphStartRunLoop
{
    CFRunLoopRun();//for delegate processing
}

-(void)graphStopRunLoop
{
    CFRunLoopStop(CFRunLoopGetCurrent());
}

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldScaleBy:(CGFloat)interactionScale aboutPoint:(CGPoint)interactionPoint
{
    NSLog(@"Should scale called");
    return YES;
}

-(void)createScatterPlot
{
    // Create graph from a custom theme
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme      =  [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [newGraph applyTheme:theme];
    self.m_Graph = newGraph;
    
    newGraph.paddingLeft   = 70.0;
    newGraph.paddingTop    = 50.0;
    newGraph.paddingRight  = 10.0;
    newGraph.paddingBottom = 50.0;
    
    m_GraphHostingView  = [[CPTGraphHostingView alloc]initWithFrame:CGRectMake(100, 100, 500, 500)];
    m_GraphHostingView.hostedGraph = newGraph;
    //[view addSubview:m_GraphHostingView];
    
    
    newGraph.plotAreaFrame.masksToBorder = NO;
    
    // Setup plot space
    //CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    m_PlotSpace = (CPTXYPlotSpace *) newGraph.defaultPlotSpace;
    m_PlotSpace.allowsUserInteraction = YES;
    m_PlotSpace.xRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(m_XMinValue.doubleValue) length:CPTDecimalFromDouble(m_XMaxValue.doubleValue)];
    m_PlotSpace.yRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(m_YMinValue.doubleValue) length:CPTDecimalFromDouble(m_YMaxValue.doubleValue)];
    
    //set global range to constrain scrolling
    m_PlotSpace.globalXRange = m_PlotSpace.xRange;
    m_PlotSpace.globalYRange = m_PlotSpace.yRange;
    m_PlotSpace.delegate = self;
    
    
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength         = CPTDecimalFromDouble(0.25);
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(m_XMinValue.doubleValue);
    x.minorTicksPerInterval       = 2;
    x.title = @"Wavalength in micrometers(µm)";
    NSArray *exclusionRanges = @[[CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.00) length:CPTDecimalFromDouble(m_XMinValue.doubleValue)],
                                 [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(m_XMaxValue.doubleValue) length:CPTDecimalFromDouble(m_XMaxValue.doubleValue + 0.5)]];
    x.labelExclusionRanges = exclusionRanges;
    //locks x axis so it doesn't scroll off the graphhostingview
    x.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];

    
    CPTXYAxis *y = axisSet.yAxis;
    
    //so we can have four intervals for y axis, we divide max value by 4
    y.majorIntervalLength         = CPTDecimalFromDouble((double)(m_YMaxValue.doubleValue/4));
    y.minorTicksPerInterval       = 5;
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(m_XMinValue.doubleValue);
    //locks y axis so it doesn't scroll off the graphhostingview
    y.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];

    
    
    // Create a blue plot area
    // CPTScatterPlot *boundLinePlot = [[CPTScatterPlot alloc] init];
    m_BoundPlot = [[CPTScatterPlot alloc]init];
    m_BoundPlot.identifier = @"Blue Plot";
    
    CPTMutableLineStyle *lineStyle = [m_BoundPlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth         = 1.0;
    lineStyle.lineColor         = [CPTColor blueColor];
    m_BoundPlot.dataLineStyle = lineStyle;
    
    m_BoundPlot.dataSource = self;
    [newGraph addPlot:m_BoundPlot];
    
    [m_PlotSpace scaleToFitPlots:[newGraph allPlots]];


    
    /*
    // Create graph from a custom theme
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme      =  [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [newGraph applyTheme:theme];
    self.m_Graph = newGraph;
    
    newGraph.paddingLeft   = 70.0;
    newGraph.paddingTop    = 50.0;
    newGraph.paddingRight  = 10.0;
    newGraph.paddingBottom = 50.0;
    
    //  CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.view;
    m_GraphHostingView  = [[CPTGraphHostingView alloc]initWithFrame:CGRectMake(100, 100, 500, 500)];
    m_GraphHostingView.hostedGraph = newGraph;
    
    
    newGraph.plotAreaFrame.masksToBorder = NO;
    
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.xRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(m_XMinValue.doubleValue) length:CPTDecimalFromDouble(m_XMaxValue.doubleValue)];
    plotSpace.yRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(m_YMinValue.doubleValue) length:CPTDecimalFromDouble(m_YMaxValue.doubleValue)];
    
    
    
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength         = CPTDecimalFromDouble(0.25);
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(m_XMinValue.doubleValue);
    x.minorTicksPerInterval       = 2;
    x.title = @"Wavalength in micrometers(µm)";
    NSArray *exclusionRanges = @[[CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.00) length:CPTDecimalFromDouble(m_XMinValue.doubleValue)],
                                 [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(m_XMaxValue.doubleValue) length:CPTDecimalFromDouble(m_XMaxValue.doubleValue + 0.5)]];
    x.labelExclusionRanges = exclusionRanges;
    
    CPTXYAxis *y = axisSet.yAxis;
    
    //so we can have four intervals for y axis, we divide max value by 4
    y.majorIntervalLength         = CPTDecimalFromDouble((double)(m_YMaxValue.doubleValue/4));
    y.minorTicksPerInterval       = 5;
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(m_XMinValue.doubleValue);
    
    
    // Create a blue plot area
    CPTScatterPlot *boundLinePlot = [[CPTScatterPlot alloc] init];
    boundLinePlot.identifier = @"Blue Plot";
    
    CPTMutableLineStyle *lineStyle = [boundLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth         = 1.0;
    lineStyle.lineColor         = [CPTColor blueColor];
    boundLinePlot.dataLineStyle = lineStyle;
    
    boundLinePlot.dataSource = self;
    boundLinePlot.delegate = self;
    [newGraph addPlot:boundLinePlot];
     */

}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return m_HdrInfo.bands;
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    
    NSLog(@"number for plot called");
    
    if(fieldEnum == CPTScatterPlotFieldX)
    {
        return m_XValues[idx];
    }
    
    //CPTScatterplotfieldy
    else
    {
        //NSLog(@"y values %@", m_YValues[idx]);
        return m_YValues[idx];
    }
}

-(CPTGraphHostingView*) getGraphView
{
    return m_GraphHostingView;
}

@end
