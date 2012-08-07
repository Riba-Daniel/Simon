//
//  SIStoryInAppViewController.m
//  Simon
//
//  Created by Derek Clarkson on 9/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>
#import "SIStoryReportTableViewController.h"
#import "SIStory.h"
#import "NSString+Simon.h"
#import "SIStorySource.h"
#import <dUsefulStuff/DCDialogs.h>
#import "SIStoryDetailsTableViewController.h"
#import "NSArray+Simon.h"
#import "SIAppBackpack.h"

@interface SIStoryReportTableViewController (_private)
-(void) rerunStories;
-(NSArray *) sourcesToDisplay;
-(void) filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope;
@end

@implementation SIStoryReportTableViewController

-(void) dealloc {
	DC_LOG(@"Deallocing");
	self.view = nil;
	DC_DEALLOC(searchController);
	DC_DEALLOC(detailsController);
	[super dealloc];
}

-(NSArray *) sourcesToDisplay {
	return searchController.isActive ? [SIAppBackpack backpack].state.filteredSources : [SIAppBackpack backpack].storySources;
}

#pragma mark - UIView methods

-(void) viewDidLoad {
	
	DC_LOG(@"Loading report controller");
	
	SIState *state = [SIAppBackpack backpack].state;
	
	// This should stop extra divider lines from appearing down the screen when
	// there are not enough cells.
	UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
	footerView.backgroundColor = [UIColor clearColor];
	[self.tableView setTableFooterView:footerView];
	[footerView	release];
	
	// Add a search bar.
	UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	searchBar.showsCancelButton = YES;
	searchBar.spellCheckingType = UITextSpellCheckingTypeNo;
	searchBar.delegate = self;
	
	searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
	searchController.delegate = self;
	searchController.searchResultsDataSource = self;
	searchController.searchResultsDelegate = self;
	
	self.tableView.tableHeaderView = searchBar;
	
	// If search terms have been passed in then setup a search.
	if (state.searchTerms != nil) {
		DC_LOG(@"Initialising with search terms: %@", state.searchTerms);
		[searchController setActive:YES animated:YES];
		searchBar.text = state.searchTerms;
	}
	
	[searchBar release];
	
	// If we are being asked to show details then do so.
	if (state.viewStory != nil) {
		
		DC_LOG(@"Showing details for story: %@", state.viewStory);
		
		// Find the indexs we need
		__block NSUInteger storyIndex = NSNotFound;
		NSUInteger sourceIndex = [[self sourcesToDisplay] indexOfObjectPassingTest: ^BOOL (id srcObj, NSUInteger srcIdx, BOOL *srcStop) {
			storyIndex = [((SIStorySource *) srcObj).stories indexOfObjectPassingTest: ^BOOL (id obj, NSUInteger idx, BOOL *stop) {
				return [((SIStory *) obj).title isEqualToString:state.viewStory.title];
			}];
			return storyIndex != NSNotFound;
		}];
		
		// Build a path.
		NSIndexPath *storyIndexPath = [NSIndexPath indexPathForRow:storyIndex inSection:sourceIndex];
		DC_LOG(@"Index path of story: %@", storyIndexPath);

		// And scroll to it.
		if (searchController.isActive) {
			DC_LOG(@"Selecting in search table view");
			[searchController.searchResultsTableView selectRowAtIndexPath:storyIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
			[searchController.searchResultsTableView.delegate tableView:searchController.searchResultsTableView didSelectRowAtIndexPath:storyIndexPath];
		} else {
			DC_LOG(@"Selecting in full table view");
			[self.tableView selectRowAtIndexPath:storyIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
			[self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:storyIndexPath];
		}
		
	}
}

- (void)viewWillAppear:(BOOL)animated {
	// Clear the reference to the details controller.
	DC_DEALLOC(detailsController);
}

#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[self sourcesToDisplay] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *sources = [self sourcesToDisplay];
	NSInteger count = [((SIStorySource *)[sources objectAtIndex:section]).stories count];
	DC_LOG(@"There are %i stories in section %i", count, section);
	return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Story cell"];
	if (cell == nil) { 
		// Create one.
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Story cell"] autorelease];
	}
	
	// Get the source and story.
	NSArray *sources = [self sourcesToDisplay];
	NSArray *stories = ((SIStorySource *)[sources objectAtIndex:indexPath.section]).stories;
	SIStory *story = (SIStory *)[stories objectAtIndex:indexPath.row];
   
   // Setup the cell.
	cell.textLabel.text = story.title;
	cell.detailTextLabel.text = [NSString stringStatusWithStory:story];
   cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	switch (story.status) {
		case SIStoryStatusError:
			cell.textLabel.textColor = [UIColor redColor];
			cell.detailTextLabel.textColor = [UIColor blackColor];
			break;
		case SIStoryStatusNotMapped:
			cell.textLabel.textColor = [UIColor lightGrayColor];
			cell.detailTextLabel.textColor = [UIColor lightGrayColor];
			break;
		default:
			cell.textLabel.textColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];
			cell.detailTextLabel.textColor = [UIColor blackColor];
			break;
	}
	
	DC_LOG(@"returning %@ cell", story.title);
	return cell;
}

#pragma mark - Table view delegate

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSArray *sources = [self sourcesToDisplay];
	return [((SIStorySource *)[sources objectAtIndex:section]).source lastPathComponent];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Load the controller.
	detailsController = [[SIStoryDetailsTableViewController alloc] initWithStyle:UITableViewStylePlain];
	
 	NSArray *sources = [self sourcesToDisplay];
	detailsController.source = [sources objectAtIndex:indexPath.section];
	detailsController.story = (SIStory *)[detailsController.source.stories objectAtIndex:indexPath.row];
	detailsController.navigationItem.title = detailsController.story.title;
	
	UIBarButtonItem *rerunButton = [[UIBarButtonItem alloc] initWithTitle:@"Run" 
																						 style:UIBarButtonItemStylePlain 
																						target:self 
																						action:@selector(rerunStory)];
	
	detailsController.navigationItem.rightBarButtonItem = rerunButton;
	[rerunButton release];
	
   DC_LOG(@"Loading details for story %@", detailsController.story.title);
   DC_LOG(@"nav %@", super.navigationController);
	[super.navigationController pushViewController:detailsController animated:YES];
}

#pragma mark - Running stories

-(void) rerunStories {	
	DC_LOG(@"Rerunning stories, search is active: %@", DC_PRETTY_BOOL(searchController.isActive));
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:SI_RUN_STORIES_NOTIFICATION object:nil userInfo:nil]];
}

-(void) rerunStory {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:SI_RUN_STORIES_NOTIFICATION object:nil userInfo:nil]];
}

#pragma mark - View rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
   return YES;
}

#pragma mark - Search bar delegate

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	[SIAppBackpack backpack].state.filteredSources = [[SIAppBackpack backpack].storySources filter:searchText];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	[self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
	return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
	[self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
	return YES;
}

/**
 This dirty trick fools the search bar into not hiding the navigation bar above it.
 This code also works:
 -(void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
 [self.navigationController setNavigationBarHidden:NO animated:NO];
 }
 */
- (UINavigationController *)navigationController {
	return nil;
}

@end
