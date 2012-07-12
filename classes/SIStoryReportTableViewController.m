//
//  SIStoryInAppViewController.m
//  Simon
//
//  Created by Derek Clarkson on 9/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import "SIStoryReportTableViewController.h"
#import <Simon-core/SIStory.h>
#import <Simon-core/NSString+Simon.h>
#import <Simon-core/SIStorySource.h>
#import <dUsefulStuff/DCDialogs.h>
#import "SIStoryDetailsTableViewController.h"

@interface SIStoryReportTableViewController (_private)
-(void) rerunStories;
-(NSArray *) sourcesForTableView:(UITableView *) tableView;
-(void) filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope;
@end

@implementation SIStoryReportTableViewController

@synthesize storySources = storySources_;
@synthesize searchTerms = searchTerms_;
@synthesize showDetailsForStory = showDetailsForStory_;

-(void) dealloc {
	DC_LOG(@"Deallocing");
	self.view = nil;
	self.storySources = nil;
	self.searchTerms = nil;
	DC_DEALLOC(filteredSources);
	DC_DEALLOC(searchController);
	DC_DEALLOC(detailsController);
	[super dealloc];
}

-(NSArray *) sourcesForTableView:(UITableView *) tableView {
	if (tableView == searchController.searchResultsTableView) {
		return filteredSources;
	} 
	return self.storySources;
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
	
	// Create the filtered list.
	filteredSources = [[NSMutableArray arrayWithCapacity:[self.storySources count]] retain];
	
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
	if (self.searchTerms != nil) {
		DC_LOG(@"Initialising with search terms: %@", self.searchTerms);
		[searchController setActive:YES animated:YES];
		searchBar.text = self.searchTerms;
	}
	
	[searchBar release];
	
	// If we are being asked to show details then do so.
	if (self.showDetailsForStory != nil) {
		
		DC_LOG(@"Showing details for story: %@", [self.showDetailsForStory.stories objectAtIndex:0]);
		
		// First find the story is the sources.
		// Find the surce index.
		NSArray *sources = searchController.isActive ? filteredSources : self.storySources;
		NSUInteger sourceIndex = [sources indexOfObjectPassingTest: ^(id obj, NSUInteger idx, BOOL *stop) {
			return [((SIStorySource *) obj).source isEqualToString:self.showDetailsForStory.source];
		}];
		
		// Now the story index.
		SIStorySource *foundSource = [sources objectAtIndex:sourceIndex];
		SIStory *story = [self.showDetailsForStory.stories objectAtIndex:0];
		NSUInteger storyIndex = [foundSource.stories indexOfObjectPassingTest: ^(id obj, NSUInteger idx, BOOL *stop) {
			return [((SIStory *) obj).title isEqualToString:story.title];
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
		
		self.showDetailsForStory = nil;
	}
}

- (void)viewWillAppear:(BOOL)animated {
	// Clear the reference to the details controller.
	DC_DEALLOC(detailsController);
}

#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[self sourcesForTableView:tableView] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *sources = [self sourcesForTableView:tableView];
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
	NSArray *sources = [self sourcesForTableView:tableView];
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
	NSArray *sources = [self sourcesForTableView:tableView];
	return [((SIStorySource *)[sources objectAtIndex:section]).source lastPathComponent];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Load the controller.
	detailsController = [[SIStoryDetailsTableViewController alloc] initWithStyle:UITableViewStylePlain];
	
 	NSArray *sources = [self sourcesForTableView:tableView];
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
	
	// Send the notification
	NSArray *sources = searchController.isActive ? filteredSources : self.storySources;
	DC_LOG(@"Number of stories to run: %i", [(NSArray *)[sources valueForKeyPath:@"@unionOfArrays.stories"] count]);
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									  sources, SI_UI_STORIES_TO_RUN_LIST, 
									  [NSNumber numberWithBool:NO], SI_UI_RETURN_TO_DETAILS, 
									  self.searchDisplayController.searchBar.text, SI_UI_SEARCH_TERMS, 
									  nil];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:SI_RUN_STORIES_NOTIFICATION object:nil userInfo:userInfo]];
}

-(void) rerunStory {
	
	// Recreate the source with just a single story.
	SIStorySource *source = [[SIStorySource alloc] init];
	source.source = detailsController.source.source;
	[source.stories addObject:detailsController.story];
	
	// Now send that.
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									  [NSArray arrayWithObject:source], SI_UI_STORIES_TO_RUN_LIST, 
									  [NSNumber numberWithBool:YES], SI_UI_RETURN_TO_DETAILS, 
									  self.searchDisplayController.searchBar.text, SI_UI_SEARCH_TERMS,
									  nil];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:SI_RUN_STORIES_NOTIFICATION object:nil userInfo:userInfo]];
	[source release];
}

#pragma mark - View rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
   return YES;
}

#pragma mark - Search bar delegate

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	
	// Clear old search results.
	[filteredSources removeAllObjects];
	
	// Loop through each story source.
	SIStorySource *tmpSource = nil;
	NSString *fileName;
	
	DC_LOG(@"Filtering sources for search terms: %@", searchText);
	for (SIStorySource *source in self.storySources) {
		
		// First test the file name.
		fileName = [source.source lastPathComponent];
		// Check length first to avoid exceptions.
		if ([fileName hasPrefix:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)]) {
			DC_LOG(@"Adding source: %@", [source.source lastPathComponent]);
			[filteredSources addObject:source];
		} else {
			
			// File name is a no go so test each story name.
			for (SIStory *story in source.stories) {
				
				// Check length first to avoid exceptions.
				if ([story.title hasPrefix:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)]) {
					
					DC_LOG(@"Adding story: %@", story.title);
					
					// Add a source if there is not one.
					if (tmpSource == nil) {
						tmpSource = [[SIStorySource alloc] init];
						tmpSource.source = source.source;
					}
					[tmpSource.stories addObject:story];
				}
			}
			
			// Now add the source if there are matching stories.
			if (tmpSource != nil) {
				[filteredSources addObject:tmpSource];
				DC_DEALLOC(tmpSource);
			}
		}
	}
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	[self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
	
	// Return YES to cause the search result table view to be reloaded.
	return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
	[self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
	
	// Return YES to cause the search result table view to be reloaded.
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
