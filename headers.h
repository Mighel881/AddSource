#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIControl.h>
#import <Cephei/HBPreferences.h>
#import <spawn.h>
#import <Twitter/Twitter.h>
#import <substrate.h>

@interface Cydia:UIApplication
- (BOOL)addTrivialSource:(NSString *)href;
- (void)reloadData;
@end

@interface SourcesController:UIViewController
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)copySource:(UITableViewCell *)cell;
- (void)removeSource:(UITableViewCell *)cell;
- (void)complete;
- (void)viewDidLoad;
- (void)deselectAll;
@end

@interface Source:NSObject
- (id)rooturi;
- (void)_remove;
@end
