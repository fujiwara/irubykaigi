//
//  FindTableViewController.m
//  iRubyKaigi
//
//  Created by Katsuyoshi Ito on 10/07/23.
//  Copyright 2010 ITO SOFT DESIGN Inc. All rights reserved.
//

#import "FindTableViewController.h"
#import "Property.h"
#import "Region.h"
#import "Day.h"
#import "SessionTableViewCell.h"
#import "Speaker.h"


@interface FindTableViewController(IRKPrivate)
- (void)buildSearchDisplayController;
- (void)buildDateSecmentedController;
@end



@implementation FindTableViewController


@synthesize searchString;


+ (UINavigationController *)navigationController
{
    return [[[UINavigationController alloc] initWithRootViewController:[self findViewController]] autorelease];
}

+ (FindTableViewController *)findViewController
{
    return [[[self alloc] initWithNibName:@"FindTableViewController" bundle:nil] autorelease];
}


- (NSString *)title
{
    return NSLocalizedString(@"Search", nil);
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self buildSearchDisplayController];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)buildSearchDisplayController
{
    searchBar.scopeButtonTitles = [NSArray arrayWithObjects:
                        NSLocalizedString(@"All", nil),
                        NSLocalizedString(@"Session", nil),
                        NSLocalizedString(@"Speaker", nil),
                        nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self performSelector:@selector(beActive) withObject:nil afterDelay:0.1];
}

- (void)beActive
{
    [self.searchDisplayController setActive:YES animated:YES];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Memory management


- (void)dealloc {
    [searchString release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark properties



#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (NSPredicate *)likePredicateForKey:(NSString *)key string:(NSString *)string
{
    NSString *str = [NSString stringWithFormat:@"*%@*", string];
    return [NSPredicate predicateWithFormat:@"%K LIKE[c] %@", key, str];
}

- (NSArray *)sessoinsBySessionQuery
{
    NSMutableArray *predicates = [NSMutableArray array];
    NSArray *keys = [NSArray arrayWithObjects:@"title", @"summary", nil];
    for (NSString *key in keys) {
        [predicates addObject:[self likePredicateForKey:key string:self.searchString]];
    }
    NSPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
    predicates = [NSMutableArray arrayWithObject:predicate];
    [predicates addObject:[NSPredicate predicateWithFormat:@"day.region = %@", self.region]];
    predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    
    NSError *error = nil;
    NSArray *sessions = [Session findAllWithPredicate:predicate error:&error];
#ifdef DEBUG
    if (error) [error showErrorForUserDomains];
#endif
    return sessions;
}

- (NSArray *)sessionsBySpeakerQuery
{
    NSMutableArray *predicates = [NSMutableArray array];
    [predicates addObject:[NSPredicate predicateWithFormat:@"region = %@", self.region]];
    [predicates addObject:[self likePredicateForKey:@"name" string:self.searchString]];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    NSError *error = nil;
    NSArray *speakers = [Speaker findAllWithPredicate:predicate error:&error];
#ifdef DEBUG
    if (error) [error showErrorForUserDomains];
#endif

    NSMutableSet *sessions = [NSMutableSet set];
    for (Speaker *speaker in speakers) {
        [sessions addObjectsFromArray:[speaker.sessions allObjects]];
    }
    return [sessions allObjects];
}

- (void)reloadData
{
    if ([self.searchString length]) {
        NSMutableSet *sessions = [NSMutableSet set];
        if (scopeType == SearchScopeAll || scopeType == SearchScopeSession) {
            [sessions addObjectsFromArray:[self sessoinsBySessionQuery]];
        }
        if (scopeType == SearchScopeAll || scopeType == SearchScopeSpeaker) {
            [sessions addObjectsFromArray:[self sessionsBySpeakerQuery]];
        }
        [self setArrayControllerWithSessionSet:sessions];
    } else {
        [self setArrayControllerWithSessionSet:[NSSet set]];
    }
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    UINavigationController *navigationController = [HistoryTableViewController navigationController];
    HistoryTableViewController *controller = (HistoryTableViewController *)navigationController.visibleViewController;
    controller.propertyKey = @"sessionSearchHistories";
    controller.delegate = self;
    
    [self presentModalViewController:navigationController animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchString = searchText;
    [self reloadData];
}



- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar
{
    NSString *key = aSearchBar.text;
    if ([key length]) {
        Property *property = [Property sharedProperty];
        NSMutableArray *array = [[[property sessionSearchHistories] mutableCopy] autorelease];
        if ([array containsObject:key]) {
            [array removeObject:key];
        }
        [array insertObject:key atIndex:0];
        property.sessionSearchHistories = array;
    }
    [aSearchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    scopeType = selectedScope;
    [self reloadData];
}

- (BOOL)searchBar:(UISearchBar *)aSearchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [aSearchBar resignFirstResponder];
        return NO;
    } else {
        return YES;
    }
}




#pragma mark -
#pragma mark HistoryTableViewControllerDelegate

- (void)didSelectHistoryItem:(NSString *)item
{
    searchBar.text = item;
    [self searchBar:searchBar textDidChange:searchBar.text];
}


@end