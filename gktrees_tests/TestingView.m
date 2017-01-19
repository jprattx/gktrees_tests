//
//  TestingView.m
//  gktrees_tests
//
//

#import "TestingView.h"

@implementation TestingView

@synthesize testingViewController;
@synthesize spatialIndexType;

@synthesize roamingRectWidth;
@synthesize roamingRectHeight;

@synthesize roamingWidthTextField;
@synthesize roamingHeightTextField;

@synthesize objectCountTextField;


@synthesize maxBoxWidth;
@synthesize maxBoxHeight;
@synthesize boxesGenerated;

@synthesize rTreeMaxChildren;
@synthesize quadtreeMinCellSize;

@synthesize rTreeSplitStrategy;


- (void) awakeFromNib
{
    [self setRoamingRectWidth:200];
    [roamingWidthSlider setFloatValue:[self roamingRectWidth]];
    [roamingWidthTextField setFloatValue:[self roamingRectWidth]];
    
    [self setRoamingRectHeight:200];
    [roamingHeightSlider setFloatValue:[self roamingRectHeight]];
    [roamingHeightTextField setFloatValue:[self roamingRectHeight]];
    
    [self setRTreeSplitStrategy:GKRTreeSplitStrategyHalve];
    [rTreeSplitStrategyPopUpButton selectItemAtIndex:[self rTreeSplitStrategy]];
    
    
    roamingRectBPath = [[NSBezierPath alloc] init];

    [roamingRectBPath appendBezierPathWithRect:NSMakeRect(0,0, 1, 1)];
    
    [roamingRectBPath setLineWidth:5];
    
    [self setMaxBoxWidth:400];
    [maxBoxWidthSlider setFloatValue:[self maxBoxWidth]];
    [maxBoxWidthTextField setFloatValue:[self maxBoxWidth]];

    
    [self setMaxBoxHeight:400];
    [maxBoxHeightSlider setFloatValue:[self maxBoxHeight]];
    [maxBoxHeightTextField setFloatValue:[self maxBoxHeight]];
    

    [self setBoxesGenerated:200];
    [boxesGeneratedTextField setIntValue:[self boxesGenerated]];
    [boxesGeneratedSlider setIntValue:[self boxesGenerated]];
    

    [objectCountTextField setStringValue:@"objects count"];
    
    [self setRTreeMaxChildren:4];
    [rTreeMaxChTextField setIntValue:[self rTreeMaxChildren]];
    [self setQuadtreeMinCellSize:200];
    
    [quadtreeMinCSTextField setFloatValue:[self quadtreeMinCellSize]];
    
    
    // objects to be searched by tree
    allObjects = [[NSMutableArray alloc] init];
    
    [self makeTreesAndGenerateBoxesForTrees:nil];
    
    // notifications for updating display
    // when scrolling or mag.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollViewDidLiveScrollNotification:) name:NSScrollViewDidLiveScrollNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollViewDidEndLiveMagnifyNotification:) name:NSScrollViewDidEndLiveMagnifyNotification object:nil];
    
    
    NSScrollView *scrollView = (NSScrollView *)[[self superview] superview];
    [scrollView setScrollsDynamically:YES];
    

}

- (void) viewDidLoad
{
    NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:[self bounds] options:NSTrackingActiveInKeyWindow | NSTrackingMouseEnteredAndExited owner:self userInfo:nil];  
    
    [self addTrackingArea:area];
    
}

- (void) mouseEntered
{
    [[self window] makeFirstResponder:self];
}


- (IBAction) makeTreesAndGenerateBoxesForTrees:(id) sender
{
    // clear previously generated paths
    [allObjects removeAllObjects];
    
    // rTree
    rTree = [GKRTree treeWithMaxNumberOfChildren:[self rTreeMaxChildren]];
    
    // quadtree
    GKQuad boundingQuadForView;
    boundingQuadForView.quadMin = (vector_float2){NSMinX([self bounds]),NSMinY([self bounds])};
    boundingQuadForView.quadMax = (vector_float2){NSMaxX([self bounds]),(float)NSMaxY([self bounds])};
    
    quadtree = [GKQuadtree quadtreeWithBoundingQuad:boundingQuadForView minimumCellSize:[self quadtreeMinCellSize]];
    
    
    time_t t;
    srand((unsigned) time(&t));
    
    for (int i = 0; i < [self boxesGenerated]; i = i + 1) {
        
        float width = (rand() % (int)[self maxBoxWidth]);
        float height = (rand() % (int)[self maxBoxHeight]);
     
        NSBezierPath *boxPath = [[NSBezierPath alloc] init];
        [boxPath appendBezierPathWithRect:NSMakeRect((float)(rand() % (int)[self bounds].size.width), (rand() % (int)[self bounds].size.height), width, height)];
        [allObjects addObject:boxPath];
        
        
        GKQuad quad;
        quad.quadMin = (vector_float2){(float)NSMinX([boxPath bounds]), (float)NSMinY([boxPath bounds])};
        quad.quadMax = (vector_float2){(float)NSMaxX([boxPath bounds]),(float)NSMaxY([boxPath bounds])};
        
        [quadtree addElement:boxPath  withQuad:quad];
        
        [rTree addElement:boxPath 
          boundingRectMin:quad.quadMin 
          boundingRectMax:quad.quadMax 
            splitStrategy:GKRTreeSplitStrategyHalve
         ];

    }

    [objectCountTextField setStringValue:@"objects count"];
    
    [self setNeedsDisplay:YES];
}


- (IBAction) changeSpatialTreeType:(id) sender
{
    [self setSpatialIndexType:[sender selectedSegment]];
    [self setNeedsDisplay:YES];
}

- (void) mouseMoved:(NSEvent *) event
{

    NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
    
    [roamingRectBPath removeAllPoints];
    
    [roamingRectBPath appendBezierPathWithRect:
     NSMakeRect(p.x-([self roamingRectWidth]/2) , 
                p.y-([self roamingRectHeight]/2), 
                [self roamingRectWidth] , 
                [self roamingRectHeight])
     ];
    
    
    NSRect updateRect2 = [roamingRectBPath bounds];
    updateRect2.origin.x -= 5;
    updateRect2.origin.y -= 5;
    updateRect2.size.width += 10;
    updateRect2.size.height += 10;
    [self setNeedsDisplayInRect:NSUnionRect(updateRect2,updateRect1)];
 
    updateRect1 = updateRect2;
    
}

- (void) mouseDown:(NSEvent *)event
{
    
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
    
    
    // display all objects generated originally
    [[NSColor colorWithCalibratedRed:0 green:0 blue:1.0 alpha:.3] setFill];
    
    for(NSBezierPath *boxPath in allObjects)
    {
        [boxPath fill];
    }
    
    if(roamingRectBPath != nil)
    {

        NSArray *roamingRectHitArray;
        if([self spatialIndexType] == Quadtree)
        {
            GKQuad quadR;
            
            quadR.quadMin = (vector_float2){[roamingRectBPath bounds].origin.x,[roamingRectBPath bounds].origin.y};
            quadR.quadMax = (vector_float2){NSMaxX([roamingRectBPath bounds]),NSMaxY([roamingRectBPath bounds])};
            
            roamingRectHitArray = [quadtree elementsInQuad: quadR]; 
        }
        else if([self spatialIndexType] == RTree)
        {
            vector_float2 rectMin = (vector_float2){[roamingRectBPath bounds].origin.x,[roamingRectBPath bounds].origin.y};
            vector_float2 rectMax = (vector_float2){NSMaxX([roamingRectBPath bounds]),NSMaxY([roamingRectBPath bounds])};
            
            roamingRectHitArray = [rTree elementsInBoundingRectMin:rectMin rectMax:rectMax];
        }
        
        
        NSString *hitCountString = [NSString 
         stringWithFormat:@"%lu / %lu objects",
         (unsigned long)[roamingRectHitArray count], 
                                    (unsigned long)[allObjects count]];
        
        [objectCountTextField 
         setStringValue:hitCountString];
        
        if(roamingRectHitArray != nil)
        {
            [[NSColor colorWithRed:1.0 green:0 blue:0 alpha:.7] setFill];
        
            for(NSBezierPath *boxPath in roamingRectHitArray)
             {
                 [boxPath fill];
                 updateRect1 = NSUnionRect(updateRect1, [boxPath bounds]);
             }
        }
        
        
        [[NSColor blackColor] setStroke];
        [roamingRectBPath stroke];
        
    }

}



- (void) scrollViewDidLiveScrollNotification:(NSNotification *) note;
{
    NSScrollView *sV = (NSScrollView *)[[self superview] superview];
    
    NSRect documentVisibleRect = [sV documentVisibleRect];
    [self setNeedsDisplayInRect:documentVisibleRect];

}


- (void) scrollViewDidEndLiveMagnifyNotification:(NSNotification *) note
{
    NSScrollView *sV = (NSScrollView *)[[self superview] superview];
    
    NSRect documentVisibleRect = [sV documentVisibleRect];
    [self setNeedsDisplayInRect:documentVisibleRect];
    
}

- (IBAction)changeRectWidth:(id)sender
{
    [self setRoamingRectWidth:[sender floatValue]];
    [roamingWidthTextField setFloatValue:[sender floatValue]];
    
}

- (IBAction)changeRectHeight:(id)sender
{
    [self setRoamingRectHeight:[sender floatValue]];
    [roamingHeightTextField setFloatValue:[sender floatValue]];
}

- (IBAction)changeMaxBoxWidth:(id)sender
{
    [self setMaxBoxWidth:[sender floatValue]];
    
    [maxBoxWidthSlider setFloatValue:[sender floatValue]];
    [maxBoxWidthTextField setFloatValue:[sender floatValue]];
    
}

- (IBAction)changeMaxBoxHeight:(id)sender
{
    [self setMaxBoxHeight:[sender floatValue]];
    
    [maxBoxHeightSlider setFloatValue:[sender floatValue]];
    [maxBoxHeightTextField setFloatValue:[sender floatValue]];
}

- (IBAction)changeBoxesGenerated:(id)sender
{
    [self setBoxesGenerated:[sender intValue]];
    
    [boxesGeneratedTextField setFloatValue:[sender intValue]];
    [boxesGeneratedSlider setFloatValue:[sender intValue]];
    
}

- (IBAction)changeRTSplitStrategy:(id)sender
 {
     [self setRTreeSplitStrategy:[sender indexOfSelectedItem]];
 }

- (IBAction)changeRTMaxChildren:(id)sender
{
    [self setRTreeMaxChildren:[sender intValue]];
    
}

- (IBAction)changeQTMinCSize:(id)sender
{
    [self setQuadtreeMinCellSize:[sender floatValue]];
   
}


- (BOOL) acceptsFirstResponder
{
    return YES;
}

- (BOOL) becomeFirstResponder
{
    [[self window] setAcceptsMouseMovedEvents:YES];
    
    return YES;
}

- (BOOL)control:(NSControl *)control didFailToFormatString:(NSString *)string errorDescription:(NSString *)error
{
    NSNumberFormatter *formatter = (NSNumberFormatter *)[control formatter];
    
    [control setIntValue:(int)[formatter minimum]];
    
    return NO;
}
@end
