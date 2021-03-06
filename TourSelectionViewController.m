//
//  TourSelectionViewController.m
//  WalkingTours
//
//  Created by Cynthia Whitlatch on 12/14/15.
//  Copyright © 2015 Lindsey Boggio. All rights reserved.
//

#import "ParseLoginViewController.h"
#import "ParseSignUpViewController.h"
#import "TourSelectionViewController.h"
#import "FindToursViewController.h"

@interface TourSelectionViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectButtonTopConstraint;
@property BOOL constraintAdjusted;

@end

@implementation TourSelectionViewController

- (IBAction)logoutPressed:(UIButton *)sender {
    
    [PFUser logOut];
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"LoginNavigationController"];
        if ([navController.viewControllers.firstObject isKindOfClass:[ParseLoginViewController class]]) {
            ParseLoginViewController *loginVC = (ParseLoginViewController *)navController.viewControllers.firstObject;
            loginVC.completion = ^ {
                [self dismissViewControllerAnimated:YES completion:nil];
            };
            [self presentViewController:navController animated:YES completion:nil];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.constraintAdjusted = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.view.frame.size.height < 500.0 && self.constraintAdjusted == NO) {
        self.selectButtonTopConstraint.constant -= 40;
        self.constraintAdjusted = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"LoginNavigationController"];
        if ([navController.viewControllers.firstObject isKindOfClass:[ParseLoginViewController class]]) {
            ParseLoginViewController *loginVC = (ParseLoginViewController *)navController.viewControllers.firstObject;
            loginVC.completion = ^ {
                [self dismissViewControllerAnimated:YES completion:^ {
                    if (self.linkedTour != nil) {
                        if ([[[PFUser currentUser] objectForKey:@"favorites"] isKindOfClass:[NSArray class]]) {
                            NSArray *favorites = (NSArray *)[[PFUser currentUser] objectForKey:@"favorites"];
                            if (![favorites containsObject:self.linkedTour]) {
                                [[PFUser currentUser] addObject:self.linkedTour forKey:@"favorites"];
                                [[PFUser currentUser] saveInBackground];
                            }
                        }
                        FindToursViewController *findToursVC = [[FindToursViewController alloc] init];
                        [self.navigationController pushViewController:findToursVC animated:NO];
                        [findToursVC performSegueWithIdentifier:@"TabBarController" sender:self.linkedTour];
                    }
                }];
            };
            [self presentViewController:navController animated:YES completion:nil];
        }
    } else {
        if (self.linkedTour != nil) {
            if ([[[PFUser currentUser] objectForKey:@"favorites"] isKindOfClass:[NSArray class]]) {
                NSArray *favorites = (NSArray *)[[PFUser currentUser] objectForKey:@"favorites"];
                if (![favorites containsObject:self.linkedTour]) {
                    [[PFUser currentUser] addObject:self.linkedTour forKey:@"favorites"];
                    [[PFUser currentUser] saveInBackground];
                }
            }
            [self performSegueWithIdentifier:@"FindToursViewController" sender:self];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier  isEqual: @"FindToursViewController"]) {
        if ([segue.destinationViewController isKindOfClass:[FindToursViewController class]]) {
            FindToursViewController *findToursVC = (FindToursViewController *)segue.destinationViewController;
            findToursVC.linkedTour = self.linkedTour;
            self.linkedTour = nil;
        }
    }
}

@end
