//
//  MSHomeViewController.m
//  Spectral_Motion
//
//  Created by Kale Evans on 2/21/15.
//  Copyright (c) 2015 Kale Evans. All rights reserved.
//

#import "MSHomeViewController.h"
#import "MSHeaderViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface MSHomeViewController ()
{
    NSArray *m_ImageFileNames;
    NSString *m_SelectedHyperspectralFile;
}

@end

@implementation MSHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.ImageFileTableView.delegate = self;
    self.ImageFileTableView.dataSource = self;
    self.ImageFileTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    
    m_ImageFileNames = [[NSArray alloc]initWithObjects:@"Sample Image 1", @"Sample Image 2", nil];
    
    
    UIImageView *tableViewImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableview_background2.jpeg"]];
    [tableViewImg setFrame:self.ImageFileTableView.frame];
    //self.ImageFileTableView.backgroundView = tableViewImg;
    
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableview_background2.jpeg"]];
    
    self.ImageFileTableView.layer.cornerRadius = 15.0;
    [self.ImageFileTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.ImageFileTableView setSeparatorColor:[UIColor blueColor]];
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource Methods

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageFileCell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"imageFileCell"] ;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
   
    cell.textLabel.text = [m_ImageFileNames objectAtIndex:indexPath.row];
    
   // cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tableview_background2.jpeg"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];

        
    return cell;

    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_ImageFileNames.count;
    
}


#pragma mark - UITableViewDelegate Methods

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    m_SelectedHyperspectralFile = [m_ImageFileNames objectAtIndex:indexPath.row];
    
   // [self performSegueWithIdentifier:@"PushToHeaderVC" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MSHeaderViewController *msHeaderVC = (MSHeaderViewController*)segue.destinationViewController;
    //msHeaderVC.m_HeaderFileName = m_SelectedHyperspectralFile;
    
    //hardcoding file name for now temporarily
    msHeaderVC.m_HeaderFileName = @"f970620t01p02_r03_sc03.a";
    [msHeaderVC parseHeaderFile];

    
}


@end
