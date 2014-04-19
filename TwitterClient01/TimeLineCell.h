//
//  TimeLineCell.h
//  TwitterClient01
//
//  Created by 09support02 on 2014/04/12.
//  Copyright (c) 2014年 09support02. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeLineCell : UITableViewCell
@property UILabel *tweetTextLabel;
@property UILabel *nameLabel;
@property UIImageView *profileImageView;
@property UIImage *image;
@property int tweetTextLabelHeight;
@property CGFloat paddingTop;
@property CGFloat paddingBottom;


@end
