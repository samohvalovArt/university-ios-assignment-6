//
//  RecordsViewController.m
//  PasswordManager
//
//  Created by Maxim Zabelin on 20/02/14.
//  Copyright (c) 2014 Noveo. All rights reserved.
//

#import "NewRecordViewController.h"
#import "Record.h"
#import "RecordsManager.h"
#import "RecordsViewController.h"
#import "PasswordManagerSettingsViewController.h"
#import "Preferences.h"

static NSString *const DefaultFileNameForLocalStore = @"AwesomeFileName.dat";
static NSString *const DefaultFileNameForDB = @"DataBase.db";

@interface RecordsViewController ()
    <UITableViewDataSource,
     UITableViewDelegate,
     NewRecordViewControllerDelegate,
     PasswordManagerSettingsVCDelegat>

@property (nonatomic, readonly) RecordsManager *recordsManager;
@property (nonatomic, readonly) RecordsManager *recordManagerDB;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)didTouchAddBarButtonItem:(UIBarButtonItem *)sender;

@end

@implementation RecordsViewController

@synthesize recordsManager = recordsManager_;
@synthesize recordManagerDB = recordsManagerDB_;

@synthesize tableView = tableView_;

-(id) init
{
    self = [super init];
    
    if(self)
    {
        NSURL *const documentDirectoryURL =
        [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                inDomains:NSUserDomainMask] lastObject];
        
        // default recordMeneger
        NSURL *const fileURLForLocalStore =
        [documentDirectoryURL URLByAppendingPathComponent:DefaultFileNameForLocalStore];
        
        recordsManager_ = [[RecordsManager alloc] initWithURL:fileURLForLocalStore
                           passwordStorageMode:PasswordStorageMethodDefault];
        
        // record manager for DB
        NSURL *const fileURLForDB =
        [documentDirectoryURL URLByAppendingPathComponent:DefaultFileNameForDB];
        
        recordsManagerDB_ = [[RecordsManager alloc] initWithURL:fileURLForDB
                             passwordStorageMode:PasswordStorageMethodDataBase];
        
    }
    
    return self;
}



#pragma mark - Getters

- (RecordsManager *)recordsManager
{
    if ([[Preferences standardPreferences] passwordStorageMethod] == PasswordStorageMethodDataBase)
        return recordsManagerDB_;
    else
        return recordsManager_;
}

#pragma mark - Actions

- (IBAction)didTouchAddBarButtonItem:(UIBarButtonItem *)sender
{
    NewRecordViewController *const rootViewController = [[NewRecordViewController alloc] init];
    rootViewController.delegate = self;

    UINavigationController *const navigationController =
        [[UINavigationController alloc] initWithRootViewController:rootViewController];
    [self presentViewController:navigationController animated:YES completion:NULL];
}
- (IBAction)didTouchSettingsBarItem:(UIBarButtonItem *)sender {
    PasswordManagerSettingsViewController *const rootViewController = [[PasswordManagerSettingsViewController alloc] init];
    rootViewController.delegate = self;
    
    
    UINavigationController *const navigationController =
    [[UINavigationController alloc] initWithRootViewController:rootViewController];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - UITableViewDataSource implementation

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[self.recordsManager records] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#define REUSABLE_CELL_ID @"ReusableCellID"

    UITableViewCell *tableViewCell =
        [tableView dequeueReusableCellWithIdentifier:REUSABLE_CELL_ID];
    if (!tableViewCell) {
        tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                               reuseIdentifier:REUSABLE_CELL_ID];
    }
    NSDictionary *const record =
        [[self.recordsManager records] objectAtIndex:indexPath.row];
    tableViewCell.textLabel.text = [record valueForKey:kServiceName];
    tableViewCell.detailTextLabel.text = [record valueForKey:kPassword];

    return tableViewCell;

#undef REUSABLE_CELL_ID
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - UITableViewDelegate implementation

-       (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *record = [[self.recordsManager records] objectAtIndex:indexPath.row];
    [self.recordsManager deleteRecord:record];
    
    NewRecordViewController *const rootViewController = [[NewRecordViewController alloc] init];
    [rootViewController setRecord:record];
    rootViewController.delegate = self;
    
    UINavigationController *const navigationController =
    [[UINavigationController alloc] initWithRootViewController:rootViewController];
    [self presentViewController:navigationController animated:YES completion:NULL];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSDictionary *record = [[self.recordsManager records] objectAtIndex:indexPath.row];
        
        [self.recordsManager deleteRecord:record];
        [self.recordsManager synchronize];
        
        [tableView reloadData];
    }
}

#pragma mark - NewRecordViewControllerDelegate implementation

- (void)newRecordViewController:(NewRecordViewController *)sender
            didFinishWithRecord:(NSDictionary *)record
{
    if (record) {
        [self.recordsManager registerRecord:record];
        [self.recordsManager synchronize];

        [self.tableView reloadData];
    }
    [self dismissViewControllerAnimated:YES
                             completion:NULL];
}

#pragma mark - NewRecordViewControllerDelegate implementation

-(void)newSettingsViewController:(PasswordManagerSettingsViewController *)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:NULL];
}

@end
