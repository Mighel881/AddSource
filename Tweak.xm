#import <headers.h>

%config(generator=internal)

%group AddSources

    %hook SourcesController

            - (void)addButtonClicked {

                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];

                NSString *message = @"";
                NSMutableArray *mySources = [NSMutableArray array];

                NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"(?i)\\b((?:[a-z][\\w-]+:(?:/{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))" options:NSRegularExpressionCaseInsensitive error:NULL];
                NSString *someString = pasteboard.string ?: @"nil";

                NSArray *matches = [expression matchesInString:someString options:NSMatchingCompleted range:NSMakeRange(0, someString.length)];

                NSMutableArray *myCydiaSources = MSHookIvar<NSMutableArray *>(self, "sources_");
                NSMutableArray *myCydiaSources2 = [NSMutableArray array];

                for (Source *source in myCydiaSources) {
                    
                    [myCydiaSources2 addObject:[source rooturi]];
                    
                }

                for (NSTextCheckingResult *result in matches) {

                    NSString *url = [someString substringWithRange:result.range];

                    if (![myCydiaSources2 containsObject:url]) {
                        
                        [mySources addObject:url];
                        message = [[message stringByAppendingString:@"\n"] stringByAppendingString:url];
                    }
                }

                if ([mySources count] != 0){

                    NSString *myActionWithTitle = [[NSString stringWithFormat:@"Add %lu", (unsigned long)[mySources count]] stringByAppendingString:@" Source(s)"];

                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Automatically Add Source" message:[@"Add the following URL found on your pasteboard: \n" stringByAppendingString:message] preferredStyle:UIAlertControllerStyleAlert];

                    UIAlertAction *ok = [UIAlertAction actionWithTitle:myActionWithTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

                        Cydia *cydiaDelegate = (Cydia *)[[UIApplication sharedApplication] delegate];

                        for (NSString* mySource in mySources) {

                            NSURL *source = [NSURL URLWithString:mySource];

                            if (source && source.scheme && source.host){

                                [cydiaDelegate addTrivialSource:mySource];
                            }
                        }

                        [self complete];
                    }];

                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

                    UIAlertAction *Manually = [UIAlertAction actionWithTitle:@"Enter Manually" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {

                        %orig;

                    }];

                    [alert addAction:cancel];
                    [alert addAction:ok];
                    [alert addAction:Manually];
                    [self presentViewController:alert animated:YES completion:nil];

                }
                else {

                    %orig;
                }
            }
    %end
%end
%ctor {

    HBPreferences *Key = [[HBPreferences alloc] initWithIdentifier:@"com.saurik.Cydia"];

    bool Enable = [([Key objectForKey:@"ena1"] ?: @(NO)) boolValue];

    if (Enable) {

        %init(AddSources);

    }
}

%group Source

    %hook SourcesController

        - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

            if (editingStyle == UITableViewCellEditingStyleDelete) {

                HBPreferences *Key = [[HBPreferences alloc] initWithIdentifier:@"com.saurik.Cydia"];
                bool EnableDeleteSource = [([Key objectForKey:@"ena3"] ?: @(NO)) boolValue];

                if (EnableDeleteSource) {

                    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                    [self removeSource:cell];

                }
                else {

                    %orig;
                }

            } else if (editingStyle == UITableViewCellEditingStyleInsert) {

                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                [self copySource:cell];

            }
        }

        %new
        - (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {

            NSMutableArray *myButtons = [NSMutableArray array];

            HBPreferences *Key = [[HBPreferences alloc] initWithIdentifier:@"com.saurik.Cydia"];
            bool EnableCopySource = [([Key objectForKey:@"ena2"] ?: @(NO)) boolValue];

             UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewCellEditingStyleDelete title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){

                 [self tableView:tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
             }];
             deleteAction.backgroundColor = [UIColor redColor];

            [myButtons addObject:deleteAction];

            if (EnableCopySource) {

                UITableViewRowAction *copyAction = [UITableViewRowAction rowActionWithStyle:UITableViewCellEditingStyleInsert title:@"Copy" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){

                    [self tableView:tableView commitEditingStyle:UITableViewCellEditingStyleInsert forRowAtIndexPath:indexPath];
                }];
                copyAction.backgroundColor = [UIColor colorWithRed:0.00 green:0.66 blue:0.71 alpha:1.0];

                [myButtons addObject:copyAction];
            }

            return (NSArray *)myButtons;
        }

        %new
        - (void)copySource:(UITableViewCell *)cell {

            Source *source = MSHookIvar<Source *>(cell, "source_");
            NSString *mySourceRootURI = [source rooturi];
            if (mySourceRootURI == nil) {
              mySourceRootURI = @"";
            }
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = mySourceRootURI;

        }

        %new
        - (void)removeSource:(UITableViewCell *)cell {

            Source *source = MSHookIvar<Source *>(cell, "source_");
            [source _remove];

            Cydia *cydiaDelegate = (Cydia *)[[UIApplication sharedApplication] delegate];
            [cydiaDelegate reloadData];
            [cydiaDelegate reloadData];
            [self viewDidLoad];

        }
    %end
%end
%ctor {

    %init(Source);
}

%group UodateSources

    %hook Cydia
        - (void)applicationDidEnterBackground:(id)arg1 {
            return ;
        }
        - (void)applicationWillResignActive:(id)arg1 {
            return ;
        }
    %end

    %hook UIApplication
        - (void)_applicationDidEnterBackground {
            return ;
        }
    %end

%end
%ctor {

    HBPreferences *Key = [[HBPreferences alloc] initWithIdentifier:@"com.saurik.Cydia"];
    bool Enable = [([Key objectForKey:@"ena4"] ?: @(NO)) boolValue];

    if (Enable) {
        %init(UodateSources);
    }
}

%group Select

    %hook SourcesController

        - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

            UITableView *myTableView = MSHookIvar<UITableView *>(self, "list_");

            if (myTableView.editing) {

            }
            else {
                %orig;
            }
        }

        - (void)editButtonClicked {

            UITableView *myTableView = MSHookIvar<UITableView *>(self, "list_");

            NSArray *indexPathForSelectedRows = [myTableView indexPathsForSelectedRows];

            if (myTableView.editing) {

                myTableView.allowsMultipleSelectionDuringEditing = NO;

                if ([indexPathForSelectedRows count] != 0) {

                    __block NSString *message2 = @"";

                    NSMutableArray *myCydiaSources = MSHookIvar<NSMutableArray *>(self, "sources_");

                    for (NSIndexPath* indexPath in indexPathForSelectedRows) {

                        Source *source = myCydiaSources[indexPath.row];

                        NSString *mySourceRootURI = [source rooturi];

                        message2 = [[message2 stringByAppendingString:@"\n"] stringByAppendingString:mySourceRootURI];
                    }

                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Selected Sources" message:message2 preferredStyle:UIAlertControllerStyleAlert];

                    UIAlertAction *Copy = [UIAlertAction actionWithTitle:[[NSString stringWithFormat:@"Copy %lu", (unsigned long)[indexPathForSelectedRows count]] stringByAppendingString:@" Source(s)"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

                        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                        pasteboard.string = message2;

                        [self deselectAll];
                    }];

                    UIAlertAction *Delete = [UIAlertAction actionWithTitle:[[NSString stringWithFormat:@"Delete %lu", (unsigned long)[indexPathForSelectedRows count]] stringByAppendingString:@" Source(s)"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {

                        for (NSIndexPath* indexPath in indexPathForSelectedRows) {

                            UITableViewCell *cell = [myTableView cellForRowAtIndexPath:indexPath];
                            Source *source = MSHookIvar<Source *>(cell, "source_");
                            [source _remove];
                        }

                        [self deselectAll];

                        Cydia *cydiaDelegate = (Cydia *)[[UIApplication sharedApplication] delegate];
                        [cydiaDelegate reloadData];
                        [cydiaDelegate reloadData];
                        [self viewDidLoad];
                    }];

                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                        [self deselectAll];
                    }];

                    [alert addAction:Copy];

                    [alert addAction:Delete];

                    [alert addAction:cancel];

                    [self presentViewController:alert animated:YES completion:nil];
                }
                %orig;
            }
            else {
                myTableView.allowsMultipleSelectionDuringEditing = YES;
                %orig;
            }
        }

        %new
        - (void)deselectAll {

            UITableView *myTableView = MSHookIvar<UITableView *>(self, "list_");
            for (NSIndexPath *indexPath in myTableView.indexPathsForSelectedRows) {
                [myTableView deselectRowAtIndexPath:indexPath animated:NO];
            }
        }

    %end
%end
%ctor {

    HBPreferences *Key = [[HBPreferences alloc] initWithIdentifier:@"com.saurik.Cydia"];
    bool Enable = [([Key objectForKey:@"ena5"] ?: @(NO)) boolValue];

    if (Enable) {
        %init(Select);
    }
}
