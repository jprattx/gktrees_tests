//
//  TestingView.h
//  gktrees_tests
//
//

#import <Cocoa/Cocoa.h>
#import <GameplayKit/GKRTree.h>
#import <GameplayKit/GKQuadtree.h>

@class TestingViewController;

@interface TestingView : NSView <NSControlTextEditingDelegate>
{
    TestingViewController *testingViewController;
    
    NSMutableArray *allObjects;
    GKRTree *rTree;
    
    GKQuadtree *quadtree;
    
    NSBezierPath *roamingRectBPath;
    NSRect updateRect1;
    
    IBOutlet NSTextField *objectCountTextField;
    IBOutlet NSTextField *roamingWidthTextField;
    IBOutlet NSTextField *roamingHeightTextField;
    
    IBOutlet NSTextField *maxBoxWidthTextField;
    IBOutlet NSTextField *maxBoxHeightTextField;
    IBOutlet NSTextField *boxesGeneratedTextField;
    
    IBOutlet NSSlider *roamingWidthSlider;
    IBOutlet NSSlider *roamingHeightSlider;
    
    IBOutlet NSSlider *maxBoxWidthSlider;
    IBOutlet NSSlider *maxBoxHeightSlider;
    IBOutlet NSSlider *boxesGeneratedSlider;
    
    IBOutlet NSTextField *quadtreeMinCSTextField;
    IBOutlet NSTextField *rTreeMaxChTextField;
    
    IBOutlet NSPopUpButton *rTreeSplitStrategyPopUpButton;
    
    GKRTreeSplitStrategy rTreeSplitStrategy;
    
    float maxBoxWidth;
    float maxBoxHeight;
    int boxesGenerated;
}

typedef NS_ENUM(NSUInteger, SpatialTreeType) {
    Quadtree = 0,
    RTree = 1,
};

@property SpatialTreeType spatialIndexType;


- (IBAction) makeTreesAndGenerateBoxesForTrees:(id) sender;


- (IBAction) changeSpatialTreeType:(id) sender;

- (IBAction)changeRectWidth:(id)sender;
- (IBAction)changeRectHeight:(id)sender;

- (IBAction)changeMaxBoxWidth:(id)sender;
- (IBAction)changeMaxBoxHeight:(id)sender;
- (IBAction)changeBoxesGenerated:(id)sender;

- (IBAction)changeRTSplitStrategy:(id)sender;
- (IBAction)changeRTMaxChildren:(id)sender;
- (IBAction)changeQTMinCSize:(id)sender;





- (void) scrollViewDidLiveScrollNotification:(NSNotification *) note;
- (void) scrollViewDidEndLiveMagnifyNotification:(NSNotification *) note;


@property TestingViewController *testingViewController;

@property float roamingRectWidth;
@property float roamingRectHeight;


@property NSTextField *objectCountTextField;
@property NSTextField *roamingWidthTextField;
@property NSTextField *roamingHeightTextField;

@property float maxBoxWidth;
@property float maxBoxHeight;
@property int boxesGenerated;

@property int rTreeMaxChildren;
@property float quadtreeMinCellSize;

@property GKRTreeSplitStrategy rTreeSplitStrategy;

@end
