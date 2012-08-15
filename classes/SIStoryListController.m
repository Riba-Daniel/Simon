//
//  SIStoryInAppViewController.m
//  Simon
//
//  Created by Derek Clarkson on 9/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>
#import "SIStoryListController.h"
#import "SIStory.h"
#import "NSString+Simon.h"
#import "SIStorySource.h"
#import <dUsefulStuff/DCDialogs.h>
#import "SIStoryDetailsController.h"
#import "SIAppBackpack.h"

@interface SIStoryListController (_private)
-(void) runStories;
-(void) backToStoryList;
-(NSArray *) sourcesToDisplay;
-(void) filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope;
@end

@implementation SIStoryListController

-(void) dealloc {
	DC_LOG(@"Deallocing");
	self.view = nil;
	DC_DEALLOC(searchController);
	DC_DEALLOC(detailsController);
	[super dealloc];
}

-(NSArray *) sourcesToDisplay {
	return [SIAppBackpack backpack].storySources.selectedSources;
}

#pragma mark - UIView methods

-(void) viewDidLoad {
	
	DC_LOG(@"Loading report controller");
	
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
	searchBar.spellCheckingType = UITextSpellCheckingTypeNo;
	searchBar.delegate = self;
	
	searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
	searchController.delegate = self;
	searchController.searchResultsDataSource = self;
	searchController.searchResultsDelegate = self;
	
	self.tableView.tableHeaderView = searchBar;

	SIStorySources *storySources = [SIAppBackpack backpack].storySources;

	// If search terms have been passed in then setup a search.
	NSString *searchTerms = storySources.selectionCriteria;
	if (![NSString isEmpty:searchTerms]) {
		DC_LOG(@"Initialising with search terms: %@", searchTerms);
		[searchController setActive:YES animated:YES];
		searchBar.text = searchTerms;
	}
	
	[searchBar release];
	
	// If we are being asked to show details then do so.
	if (storySources.currentIndexPath != nil) {
		
		DC_LOG(@"Showing details for story at index path: %@", storySources.currentIndexPath);
		
		// And scroll to it.
		if (searchController.isActive) {
			DC_LOG(@"Selecting in search table view");
			[searchController.searchResultsTableView selectRowAtIndexPath:storySources.currentIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
			[searchController.searchResultsTableView.delegate tableView:searchController.searchResultsTableView didSelectRowAtIndexPath:storySources.currentIndexPath];
		} else {
			DC_LOG(@"Selecting in full table view");
			[self.tableView selectRowAtIndexPath:storySources.currentIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
			[self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:storySources.currentIndexPath];
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
	
	// Track the selected story.
	[SIAppBackpack backpack].storySources.currentIndexPath = indexPath;
	
	// Load the controller.
	detailsController = [[SIStoryDetailsController alloc] initWithStyle:UITableViewStylePlain];
	
 	NSArray *sources = [self sourcesToDisplay];
	detailsController.source = [sources objectAtIndex:indexPath.section];
	detailsController.story = (SIStory *)[detailsController.source.stories objectAtIndex:indexPath.row];
	detailsController.navigationItem.title = detailsController.story.title;
	
	UIBarButtonItem *rerunButton = [[UIBarButtonItem alloc] initWithTitle:@"Run" 
																						 style:UIBarButtonItemStylePlain 
																						target:self 
																						action:@selector(runStories)];
	detailsController.navigationItem.rightBarButtonItem = rerunButton;
	[rerunButton release];

	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
																						style:UIBarButtonItemStylePlain
																					  target:self
																					  action:@selector(backToStoryList)];
	detailsController.navigationItem.leftBarButtonItem = backButton;
	[backButton release];

   DC_LOG(@"Loading details for story %@", detailsController.story.title);
   DC_LOG(@"nav %@", super.navigationController);
	[super.navigationController pushViewController:detailsController animated:YES];
}

#pragma mark - Button actions

-(void) backToStoryList {
	// Coming back so clear the selected story. This is the only time we do this.
	DC_LOG(@"Clearing current story and returning to story list");
	[SIAppBackpack backpack].storySources.currentIndexPath = nil;
	[super.navigationController popViewControllerAnimated:YES];
}

-(void) runStories {
	DC_LOG(@"Rerunning stories, run single story only indexPath: %@", [SIAppBackpack backpack].storySources.currentIndexPath);
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:SI_RUN_STORIES_NOTIFICATION object:self userInfo:nil]];
}

#pragma mark - View rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
   return YES;
}

#pragma mark - Search bar delegate

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	DC_LOG(@"Filtering sources for text: %@", searchText);
	[[SIAppBackpack backpack].storySources selectWithPrefix:searchText];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[self filterContentForSearchText:searchText scope:[searchBar.scopeButtonTitles objectAtIndex:searchBar.selectedScopeButtonIndex]];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	DC_LOG(@"Cancelling search function");
	[[SIAppBackpack backpack].storySources selectAll];
	[self.searchDisplayController setActive:NO animated:YES];
	[self.tableView reloadData];
}

#pragma mark - Other stuff

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
