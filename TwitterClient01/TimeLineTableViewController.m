//
//  TimeLineTableViewController.m
//  TwitterClient01
//
//  Created by 09support02 on 2014/04/12.
//  Copyright (c) 2014年 09support02. All rights reserved.
//

#import "TimeLineTableViewController.h"

@interface TimeLineTableViewController ()

@property dispatch_queue_t mainQueue;
@property dispatch_queue_t imageQueue;
@property NSString *httpErrorMessage;
@property NSArray *timeLineData;



@end

@implementation TimeLineTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerClass:[TimeLineCell class] forCellReuseIdentifier:@"TimeLineCell"];
    
    self.mainQueue = dispatch_get_main_queue();
    self.imageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccount *account = [accountStore accountWithIdentifier:self.identifier];
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                  @"/1.1/statuses/home_timeline.json"];
    NSDictionary *params = @{@"count" : @"100",
                             @"trim_user" : @"0",
                             @"include_entities" : @"0"};
    
    SLRequest *reqest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                           requestMethod:SLRequestMethodGET
                                                     URL:url
                                              parameters:params];
    
    [reqest setAccount:account];
    
    [reqest performRequestWithHandler:^(NSData *responseData,
                                        NSHTTPURLResponse *urlResponse,
                                        NSError *error) {
        if (responseData){
            self.httpErrorMessage = nil;
            if(urlResponse.statusCode >= 200 && urlResponse.statusCode < 300){
                NSError *jsonError;
                self.timeLineData =
                [NSJSONSerialization JSONObjectWithData:responseData
                                                options:NSJSONReadingAllowFragments
                                                  error:&jsonError];
                
                if (self.timeLineData){
                    NSLog(@"TimeLine Responce: %@\n",self.timeLineData);
                    dispatch_async(self.mainQueue, ^{
                        [self.tableView reloadData];
                        NSLog(@"pass reloadData");
                        
                    });
                }
                else{
                    NSLog(@"JSON Error: %@",[jsonError localizedDescription]);
                }
                
            }else{
                self.httpErrorMessage =
                [NSString stringWithFormat:@"The responce status code is %d",
                 urlResponse.statusCode];
                NSLog(@"HTTP Error: %@", self.httpErrorMessage);
                
            }
        }
        dispatch_async(self.mainQueue, ^{
            UIApplication *application = [UIApplication sharedApplication];
            application.networkActivityIndicatorVisible = NO;
        });
    }];
  

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *tweetText = self.timeLineData[indexPath.row][@"text"];
    CGFloat tweetTextLabelHeight = [self labelHeight:tweetText];
    return tweetTextLabelHeight + 35;
    
}

- (CGFloat)labelHeight:(NSString *)labelText;
{
    UILabel *aLabel = [[UILabel alloc] init];
    CGFloat lineHeight = 18.0;
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    paragrahStyle.minimumLineHeight = lineHeight;
    paragrahStyle.maximumLineHeight= lineHeight;
    
    NSString *text = (labelText == nil) ? @"" : labelText;
    UIFont *font = [UIFont fontWithName:@"HirakakuproN-W3" size:14];
    NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragrahStyle,
                                 NSFontAttributeName: font};
    NSAttributedString *aText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    aLabel.attributedText = aText;
    
    CGFloat aHeight =
    [aLabel.attributedText boundingRectWithSize:CGSizeMake(257, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                        context:nil].size.height;
    return aHeight;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
     
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (!self.timeLineData){
        return 1;
    }else{
        return [self.timeLineData count];
        NSLog(@"cell count = %d", self.timeLineData.count);
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimeLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimeLineCell" forIndexPath:indexPath];
    
    // Configure the cell...
    if (self.httpErrorMessage){
        cell.tweetTextLabel.text = self.httpErrorMessage;
        cell.tweetTextLabelHeight = 24;
    } else if (!self.timeLineData){
        cell.tweetTextLabel.text = @"loading....";
        cell.tweetTextLabelHeight = 24;
        
    } else {
            NSLog(@"pass");
        NSString *name = [[[self.timeLineData objectAtIndex:indexPath.row]
                           objectForKey:@"user"]
                          objectForKey:@"screen_name"];
        NSString *text = [[self.timeLineData objectAtIndex:indexPath.row]
                          objectForKey:@"text"];
        
        
        cell.tweetTextLabelHeight = [self labelHeight:text];
        cell.tweetTextLabel.text = text;
        cell.nameLabel.text = name;
        cell.profileImageView.image = [UIImage imageNamed:@"blank.png"];
        
        dispatch_async(self.imageQueue, ^{
            NSString *url;
            NSDictionary *tweetDictionary = [self.timeLineData objectAtIndex:indexPath.row];
            
            if([[tweetDictionary allKeys] containsObject:@"retweeted_status"]){
                url = tweetDictionary[@"retweeted_status"][@"user"][@"profile_image_url"];
                
            }else{
                url = tweetDictionary[@"user"][@"profile_image_url"];
                
            }
            
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            dispatch_async(self.mainQueue, ^{
                UIApplication *application = [UIApplication sharedApplication];
                application.networkActivityIndicatorVisible = NO;
                UIImage *image = [[UIImage alloc] initWithData:data];
                cell.profileImageView.image = image;
                [cell setNeedsLayout];
                
                
            });
            
            
            
            
        });
         [cell setNeedsLayout];
        
    }
    return cell;
}




/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
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
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (void)tableView: (UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimeLineCell *cell = (TimeLineCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    DetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    detailViewController.name = cell.nameLabel.text;
    detailViewController.text = cell.tweetTextLabel.text;
    detailViewController.image = cell.profileImageView.image;
    detailViewController.identifier = self.identifier;
    detailViewController.idStr = [[self.timeLineData objectAtIndex:indexPath.row]objectForKey:@"id_str"];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    
    
                                                  
    
    
    
}


























@end
