//
//  DurationFormat.m
//  LvDemos
//
//  Created by guangbo on 15/3/19.
//
//

#import "DurationFormat.h"

@implementation DurationFormat

+ (NSString *)durationTextForDuration:(NSTimeInterval)duration
{
    if (duration < 0) {
        return @"--:--:--";
    }
    
    NSInteger hours = duration/(60*60);
    NSInteger mins = (duration - hours*60*60)/60;
    NSInteger secs = duration - hours*60*60 - mins*60;
    
    NSMutableString *durationText = [NSMutableString string];
    
    if (hours >= 10) {
        [durationText appendFormat:@"%@:", @(hours)];
    } else {
        [durationText appendFormat:@"0%@:", @(hours)];
    }
    
    if (mins >= 10) {
        [durationText appendFormat:@"%@:", @(mins)];
    } else {
        [durationText appendFormat:@"0%@:", @(mins)];
    }
    
    if (secs >= 10) {
        [durationText appendFormat:@"%@", @(secs)];
    } else {
        [durationText appendFormat:@"0%@", @(secs)];
    }
    
    return durationText;
}

@end
