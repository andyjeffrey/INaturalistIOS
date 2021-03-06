//
//  Analytics.h
//  iNaturalist
//
//  Created by Alex Shepard on 10/7/14.
//  Copyright (c) 2014 iNaturalist. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Analytics : NSObject

+ (Analytics *)sharedClient;

- (void)event:(NSString *)name;
- (void)event:(NSString *)name withProperties:(NSDictionary *)properties;
- (void)logAllPageViewForTarget:(UIViewController *)target;

- (void)timedEvent:(NSString *)name;
- (void)timedEvent:(NSString *)name withProperties:(NSDictionary *)properties;
- (void)endTimedEvent:(NSString *)name;
- (void)endTimedEvent:(NSString *)name withProperties:(NSDictionary *)properties;

- (void)debugLog:(NSString *)logMessage;

@end

#pragma mark Event Names For Analytics

extern NSString *kAnalyticsEventAppLaunch;

// navigation
extern NSString *kAnalyticsEventNavigateExploreGrid;
extern NSString *kAnalyticsEventNavigateExploreMap;
extern NSString *kAnalyticsEventNavigateExploreList;
extern NSString *kAnalyticsEventNavigateExploreObsDetails;
extern NSString *kAnalyticsEventNavigateExploreTaxonDetails;

extern NSString *kAnalyticsEventNavigateGuides;             // list of guides
extern NSString *kAnalyticsEventNavigateGuideCollection;    // collection of taxa photos in guide
extern NSString *kAnalyticsEventNavigateGuideMenu;          // guide details menu
extern NSString *kAnalyticsEventNavigateGuideTaxon;         // taxon details in a guide
extern NSString *kAnalyticsEventNavigateGuidePhoto;         // custom photo viewer for taxon photos

extern NSString *kAnalyticsEventNavigateSettings;
extern NSString *kAnalyticsEventNavigateTutorial;
extern NSString *kAnalyticsEventNavigateLogin;

extern NSString *kAnalyticsEventNavigateMap;

extern NSString *kAnalyticsEventNavigateObservationActivity;
extern NSString *kAnalyticsEventNavigateObservationDetail;
extern NSString *kAnalyticsEventNavigateObservations;
extern NSString *kAnalyticsEventNavigatePhoto;
extern NSString *kAnalyticsEventNavigateAddComment;
extern NSString *kAnalyticsEventNavigateAddIdentification;
extern NSString *kAnalyticsEventNavigateEditLocation;
extern NSString *kAnalyticsEventNavigateProjectChooser;     // in obs details, choose project

extern NSString *kAnalyticsEventNavigateProjectDetail;      // project details
extern NSString *kAnalyticsEventNavigateProjectList;        // project obs list
extern NSString *kAnalyticsEventNavigateProjects;           // list of projects

extern NSString *kAnalyticsEventNavigateTaxaSearch;
extern NSString *kAnalyticsEventNavigateTaxonDetails;

// search in explore
extern NSString *kAnalyticsEventExploreSearchPeople;
extern NSString *kAnalyticsEventExploreSearchProjects;
extern NSString *kAnalyticsEventExploreSearchPlaces;
extern NSString *kAnalyticsEventExploreSearchCritters;

extern NSString *kAnalyticsEventExploreSearchNearMe;
extern NSString *kAnalyticsEventExploreSearchMine;


// add comments & ids in explore
extern NSString *kAnalyticsEventExploreAddComment;
extern NSString *kAnalyticsEventExploreAddIdentification;

// share in explore
extern NSString *kAnalyticsEventExploreObservationShare;

// observations activites
extern NSString *kAnalyticsEventCreateObservation;
extern NSString *kAnalyticsEventSyncObservation;
extern NSString *kAnalyticsEventObservationsPullToRefresh;

// login
extern NSString *kAnalyticsEventLogin;
extern NSString *kAnalyticsEventSignup;

// model integrity
extern NSString *kAnalyticsEventObservationlessOFVSaved;
