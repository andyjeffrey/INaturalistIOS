//
//  ProjectDetailViewController.m
//  iNaturalist
//
//  Created by Ken-ichi Ueda on 3/14/12.
//  Copyright (c) 2012 iNaturalist. All rights reserved.
//

#import "ProjectDetailViewController.h"
#import "Project.h"
#import "List.h"
#import "ListedTaxon.h"
#import "ImageStore.h"
#import "DejalActivityView.h"

static const int ListedTaxonCellImageTag = 1;
static const int ListedTaxonCellTitleTag = 2;
static const int ListedTaxonCellSubtitleTag = 3;

@implementation ProjectDetailViewController

@synthesize project = _project;
@synthesize listedTaxa = _listedTaxa;
@synthesize projectIcon = _projectIcon;
@synthesize projectTitle = _projectTitle;
@synthesize projectSubtitle = _projectSubtitle;
@synthesize loader = _loader;
@synthesize lastSyncedAt = _lastSyncedAt;

- (IBAction)clickedSync:(id)sender {
    [self sync];
}

- (void)sync
{
    [DejalBezelActivityView activityViewForView:self.navigationController.view
                                      withLabel:@"Syncing list..."];
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:[NSString stringWithFormat:@"/lists/%d.json", self.project.listID.intValue]
                                                 objectMapping:[List mapping] 
                                                      delegate:self];
}

- (void)stopSync
{
    [DejalBezelActivityView removeView];
    [[[[RKObjectManager sharedManager] client] requestQueue] cancelAllRequests];
    [self loadData];
    [[self tableView] reloadData];
}

- (void)loadData
{
    self.listedTaxa = [NSMutableArray arrayWithArray:[self.project.projectList.listedTaxa allObjects]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - lifecycle
- (void)viewDidLoad
{
    self.projectIcon.defaultImage = [UIImage imageNamed:@"projects.png"];
    self.projectIcon.urlPath = self.project.iconURL;
    self.projectTitle.text = self.project.title;
    self.projectSubtitle.textColor = [UIColor grayColor];
    self.projectSubtitle.font = [UIFont systemFontOfSize:12.0];
    self.projectSubtitle.text = [TTStyledText textFromXHTML:self.project.desc
                                                 lineBreaks:NO 
                                                       URLs:YES];
    if (!self.listedTaxa) {
        [self loadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.listedTaxa.count == 0 && !self.lastSyncedAt) {
        [self sync];
    }
}

- (void)viewDidUnload {
    [self setProjectIcon:nil];
    [self setProjectTitle:nil];
    [self setProjectSubtitle:nil];
    [super viewDidUnload];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listedTaxa.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListedTaxon *lt = [self.listedTaxa objectAtIndex:[indexPath row]];
    
    NSString *cellIdentifier = [lt.taxonName isEqualToString:lt.taxonDefaultName] ? @"ListedTaxonOneNameCell" : @"ListedTaxonTwoNamesCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    TTImageView *imageView = (TTImageView *)[cell viewWithTag:ListedTaxonCellImageTag];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:ListedTaxonCellTitleTag];
    titleLabel.text = lt.taxonDefaultName;
    imageView.defaultImage = [[ImageStore sharedImageStore] iconicTaxonImageForName:lt.iconicTaxonName];
    imageView.urlPath = lt.photoURL;
    if (![lt.taxonName isEqualToString:lt.taxonDefaultName]) {
        UILabel *subtitleLabel = (UILabel *)[cell viewWithTag:ListedTaxonCellSubtitleTag];
        subtitleLabel.text = lt.taxonName;
    }
    
    return cell;
}

#pragma mark - RKObjectLoaderDelegate
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    NSLog(@"loaded %d objects", objects.count);
    if (objects.count == 0) return;
    NSDate *now = [NSDate date];
    for (INatModel *o in objects) {
        [o setSyncedAt:now];
    }
    
    NSArray *rejects = [ListedTaxon objectsWithPredicate:
                        [NSPredicate predicateWithFormat:@"listID = %d AND syncedAt < %@", 
                         self.project.listID.intValue, now]];
    for (ListedTaxon *lt in rejects) {
        [lt deleteEntity];
    }
    
    [[[RKObjectManager sharedManager] objectStore] save];
    
    [self stopSync];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    // was running into a bug in release build config where the object loader was 
    // getting deallocated after handling an error.  This is a kludge.
    self.loader = objectLoader;
    
    [self stopSync];
    NSString *errorMsg;
    bool jsonParsingError = false, authFailure = false;
    switch (objectLoader.response.statusCode) {
            // UNPROCESSABLE ENTITY
        case 422:
            errorMsg = @"Unprocessable entity";
            break;
            
        default:
            // KLUDGE!! RestKit doesn't seem to handle failed auth very well
            jsonParsingError = [error.domain isEqualToString:@"JKErrorDomain"] && error.code == -1;
            authFailure = [error.domain isEqualToString:@"NSURLErrorDomain"] && error.code == -1012;
            errorMsg = error.localizedDescription;
    }
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Whoops!" 
                                                 message:[NSString stringWithFormat:@"Looks like there was an error: %@", errorMsg]
                                                delegate:self 
                                       cancelButtonTitle:@"OK" 
                                       otherButtonTitles:nil];
    [av show];
}
@end