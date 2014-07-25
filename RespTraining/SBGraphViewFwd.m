//
//  SBGraphViewFwd.m
//  SimplyBreathe
//     - based on Apple's AccelerometerGraph demo
//
//  Created by Joseph Cheng on 1/15/14.
//  Copyright (c) 2014 Joseph Y Cheng. All rights reserved.
//

#import "SBGraphViewFwd.h"

#pragma mark SBGraphView Constants

// Constants to set the different dimensions
#define SBGraphViewPadY 10
// Width of Marker
#define SBGraphViewMarkerWidthPx 20
// Width of delta t
#define SBGraphViewDeltaX 6
// Number of points in SBGraphViewSegment
#define SBGraphViewSegmentSize 32
// Overlap between graph segments
#define SBGraphViewSegmentOverlap 1
// Number of grid lines to draw
#define SBGraphViewNumLines 6
// Line width
#define SBGraphViewGraphLineWidth 4
#define SBGraphViewGridLineWidth 2


#pragma mark Quartz Helpers

// Functions used to draw all content

CGColorRef CreateDeviceGrayColor(CGFloat w, CGFloat a)
{
	CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();
	CGFloat comps[] = {w, a};
	CGColorRef color = CGColorCreate(gray, comps);
	CGColorSpaceRelease(gray);
	return color;
}

CGColorRef CreateDeviceRGBColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a)
{
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	CGFloat comps[] = {r, g, b, a};
	CGColorRef color = CGColorCreate(rgb, comps);
	CGColorSpaceRelease(rgb);
	return color;
}

CGColorRef graphMarkerColor()
{
	static CGColorRef c = NULL;
	if (c == NULL)
        c = [[UIColor blueColor] CGColor];
	return c;
}


CGColorRef graphBackgroundColor()
{
	static CGColorRef c = NULL;
	if (c == NULL)
		c = CreateDeviceGrayColor(0.8, 1.0);
	return c;
}

CGColorRef gridLineColor()
{
	static CGColorRef c = NULL;
	if (c == NULL)
        c = [[UIColor lightGrayColor] CGColor];
	return c;
}

CGColorRef graphLineColor()
{
	static CGColorRef c = NULL;
	if (c == NULL)
        c = [[UIColor blueColor] CGColor];
	return c;
}


CGColorRef graphXColor()
{
	static CGColorRef c = NULL;
	if (c == NULL)
	{
		c = CreateDeviceRGBColor(0.0, 0.0, 1.0, 1.0);
        //c = (__bridge CGColorRef)([UIColor blueColor]);
	}
	return c;
}

CGColorRef colorBoundary()
{
    static CGColorRef c = NULL;
    if (c == NULL)
        c = [[UIColor yellowColor] CGColor];
    return c;
}

void DrawGridlines(CGContextRef context, CGFloat x, CGPoint size, CGPoint pad, int nlines)
{
    CGFloat ymax = 0.5*(size.y - 2*pad.y);
    CGFloat dy = (size.y - 2*pad.y)/nlines;
    for (CGFloat y = -ymax; y <= ymax; y += dy)
	{
		CGContextMoveToPoint(context, x + pad.x, y);
		CGContextAddLineToPoint(context, x + size.x - 2*pad.x, y);
	}
	CGContextSetStrokeColorWithColor(context, gridLineColor());
    CGContextSetLineWidth(context, SBGraphViewGridLineWidth);
	CGContextStrokePath(context);
    CGContextSetAllowsAntialiasing(context, true);
}

void DrawBoundaryPos(CGContextRef context, CGPoint size, CGFloat padY, CGFloat percent, CGColorRef color)
{
    CGFloat y = (size.y/2 - padY) * percent;
    CGFloat height = (size.y - 2*y) * 0.5;
    
    CGContextSetFillColorWithColor(context, color);
    CGContextFillRect(context, CGRectMake(0.0, -size.y * 0.5, size.x, height));
}

void DrawBoundaryNeg(CGContextRef context, CGPoint size, CGFloat padY, CGFloat percent, CGColorRef color)
{
    CGFloat y = (size.y/2 - padY) * percent;
    CGFloat height = (size.y - 2*y) * 0.5;
    
    CGContextSetFillColorWithColor(context, color);
    //CGContextFillRect(context, CGRectMake(0.0, size.y * 0.5, size.x, height));
    CGContextFillRect(context, CGRectMake(0.0, y, size.x, height));
}



#pragma mark -

@interface SBGraphViewMarker : NSObject
@property(nonatomic,readonly) CALayer *layer;
- (id)initWithDim:(CGPoint)dim;
@end

@implementation SBGraphViewMarker
@synthesize layer;

- (id)init
{
    return [self initWithDim:CGPointZero];
}

- (id)initWithDim:(CGPoint)dim
{
    self = [super init];
    if (self != nil)
    {
        layer = [[CALayer alloc] init];
		// the layer will call our -drawLayer:inContext: method to provide content
		// and our -actionForLayer:forKey: for implicit animations
		layer.delegate = self;
		// This sets our coordinate system such that it has an origin of 0.0,-56 and a size of 32,112.
		// This would need to be changed if you change either the number of pixel values that a segment
		// represented, or if you changed the size of the graph view.
        layer.bounds = CGRectMake(0.0, 0.0, dim.x, dim.y);
		// Disable blending as this layer consists of non-transperant content.
		// Unlike UIView, a CALayer defaults to opaque=NO
		layer.opaque = YES;
        
        [layer setNeedsDisplay];
    }
    return self;
}

- (void)drawLayer:(CALayer*)l inContext:(CGContextRef)context
{
	// Fill in the background
	CGContextSetFillColorWithColor(context, graphMarkerColor());
	CGContextFillRect(context, layer.bounds);
}

- (id)actionForLayer:(CALayer *)layer forKey :(NSString *)key
{
	// We disable all actions for the layer, so no content cross fades, no implicit animation on moves, etc.
	return [NSNull null];
}

@end

# pragma mark -
@interface SBGraphViewBoundaryView : UIView
@property (nonatomic, readonly) SBGraphViewState stateBits;
@property (nonatomic) CGFloat percentAccepted;
@property (nonatomic, readonly) bool isTop;

- (id)initWithFrame:(CGRect)frame percentAccepted:(CGFloat)percentAccepted isTop:(bool)isTop;
// Add/rm states and also updates the view
- (void)addState:(SBGraphViewState)state;
- (void)rmState:(SBGraphViewState)state;
@end

@implementation SBGraphViewBoundaryView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame percentAccepted:0.8 isTop:true];
}

- (id)initWithFrame:(CGRect)frame percentAccepted:(CGFloat)percentAccepted isTop:(bool)isTop
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialize state
        _stateBits = 0;
        
        // Determine if this is for top of the graph or the bottom
        _isTop = isTop;
        
        [self setPercentAccepted:percentAccepted];
        [self setOpaque:false];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Fill in the background
	CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
	CGContextFillRect(context, self.bounds);
    CGContextTranslateCTM(context, 0.0, 0.5*rect.size.height);
    
    // Fill acceptable ranges
    UIColor *color = [UIColor darkGrayColor];
    
    if (_stateBits & SBGraphViewState_Monitor)
    {
        if (_stateBits & SBGraphViewState_Warning)
            color = [UIColor redColor];
        else if (_stateBits & SBGraphViewState_Caution)
            color = [UIColor yellowColor];
        else
            color = [UIColor greenColor];
    }
    CGColorRef colorRef = [[color colorWithAlphaComponent:0.25] CGColor];
    
    if (_isTop)
        DrawBoundaryPos(context, CGPointMake(rect.size.width,rect.size.height), SBGraphViewPadY, _percentAccepted, colorRef);
    else
        DrawBoundaryNeg(context, CGPointMake(rect.size.width,rect.size.height), SBGraphViewPadY, _percentAccepted, colorRef);
}

- (void)setPercentAccepted:(CGFloat)percentAccepted
{
    _percentAccepted = percentAccepted;
    if (_percentAccepted > 1.0f) _percentAccepted = 1.0f;
    if (_percentAccepted < 0.5f) _percentAccepted = 0.5f;
}

- (void)addState:(SBGraphViewState)state
{
    _stateBits |= state;
    [self.layer setNeedsDisplay];
}

- (void)rmState:(SBGraphViewState)state
{
    _stateBits &= state;
    [self.layer setNeedsDisplay];
}
@end



#pragma mark -

// The GraphViewSegment manages up to 32 accelerometer values and a CALayer that it updates with
// the segment of the graph that those values represent.

@interface SBGraphViewSegment : NSObject
{
	int index;
}

- (id)initWithCapacity:(NSInteger)capacity dim:(CGPoint)dim padY:(CGFloat)padY;
//- (id)initWithHeight:(CGFloat)height padY:(CGFloat)padY;

// returns true if adding this value fills the segment, which is necessary for properly updating the segments
- (BOOL)addX:(double)x;

// When this object gets recycled (when it falls off the end of the graph)
// -reset is sent to clear values and prepare for reuse.
- (void)reset;
- (void)resetIndex;

// Returns true if this segment has consumed 32 values.
- (BOOL)isFull;

// Returns true if the layer for this segment is visible in the given rect.
- (BOOL)isVisibleInRect:(CGRect)r;

// Store data
@property (nonatomic) float *data;

// The layer that this segment is drawing into
@property (nonatomic, readonly) CALayer *layer;
//@property (nonatomic, readonly) CGFloat height;

// Dimensions of graph in pixels
@property (nonatomic, readonly) CGPoint dim;

@property (nonatomic, readonly) NSInteger capacity;
@property (nonatomic, readonly) CGPoint delta;
@property (nonatomic, readonly) CGFloat padY;
@property (nonatomic, assign) CGFloat percentAccepted;

// Store max/min so the segments can be normalized later
@property(nonatomic, readonly) UIAccelerationValue xmax;
@property(nonatomic, readonly) UIAccelerationValue xmin;

@property(nonatomic) bool isnew;

@end


#pragma mark -

@implementation SBGraphViewSegment

@synthesize layer;

- (id)init
{
	//return [self initWithHeight:0 padY:0];
    return [self initWithCapacity:0 dim:CGPointZero padY:0.0];
}

- (id)initWithCapacity:(NSInteger)capacity dim:(CGPoint)dim padY:(CGFloat)padY
{
    self = [super init];
	if (self != nil)
	{
        _capacity = capacity;
        _data = malloc(sizeof(*_data)*(_capacity+SBGraphViewSegmentOverlap));
        _dim = dim;
        _padY = padY;
        _delta = CGPointMake(_dim.x/_capacity,
                             (_dim.y-2*_padY)*0.5f);
        _percentAccepted = 1.0;
        

		layer = [[CALayer alloc] init];
		// the layer will call our -drawLayer:inContext: method to provide content
		// and our -actionForLayer:forKey: for implicit animations
		layer.delegate = self;
		layer.bounds = CGRectMake(0.0, _dim.y*-0.5,
                                  _delta.x*(_capacity+1), _dim.y);
		// Disable blending as this layer consists of non-transperant content.
		// Unlike UIView, a CALayer defaults to opaque=NO
		layer.opaque = NO;
        index = 0;
	}
    [self reset];
    
	return self;
}

- (void)dealloc
{
    if (_data) free(_data);
}

- (void)resetIndex
{
    _xmax = DBL_MIN;
    _xmin = DBL_MAX;
    index = 0;
}

- (void)reset
{
    _isnew = true;
    
	// Clear out our components and reset the index to 0 to start filling values again...
    memset(_data, 0, sizeof(*_data)*(_capacity+1));
    
    [self resetIndex];
    
	// Inform Core Animation that we need to redraw this layer.
	[layer setNeedsDisplay];
}

- (BOOL)isFull
{
	// Simple, this segment is full if there are no more space in the history.
	return index >= _capacity + SBGraphViewSegmentOverlap;
}

- (BOOL)isVisibleInRect:(CGRect)r
{
	// Just check if there is an intersection between the layer's frame and the given rect.
	return CGRectIntersectsRect(r, layer.frame);
}

- (BOOL)addX:(double)x
{
	// If this segment is not full, then we add a new acceleration value to the history.
	if (index < _capacity + SBGraphViewSegmentOverlap)
	{
        _data[index] = x;
        index++;
        
        if (_xmax < x) _xmax = x;
        if (_xmin > x) _xmin = x;
        
		// And inform Core Animation to redraw the layer.
		[layer setNeedsDisplay];
	}
    
	return [self isFull];
}

- (void)drawLayer:(CALayer*)l inContext:(CGContextRef)context
{
	// Fill in the background
    CGContextClearRect(context, layer.bounds);
    int nlines = _isnew? index : (_capacity);
    
	// Draw the graph
	CGPoint lines[nlines*2];
	//double dx = 1.0f*SBGraphViewSegmentWidthPx/(SBGraphViewSegmentSize-1);

	for (int i = 0; i < nlines; i++)
	{
		lines[i*2].x = i * _delta.x;
		lines[i*2].y = _data[i] * _delta.y;
		lines[i*2+1].x = (i + 1) * _delta.x;
		lines[i*2+1].y = _data[i+1] * _delta.y;
	}
    
    CGContextSetStrokeColorWithColor(context,graphLineColor());
    CGContextSetLineWidth(context, SBGraphViewGraphLineWidth);
    CGContextSetAllowsAntialiasing(context, true);
	CGContextStrokeLineSegments(context, lines, nlines*2);
}

- (id)actionForLayer:(CALayer *)layer forKey :(NSString *)key
{
	// We disable all actions for the layer, so no content cross fades, no implicit animation on moves, etc.
	return [NSNull null];
}

// The accessibilityValue of this segment should be the x,y,z values last added.
- (NSString *)accessibilityValue
{
	return [NSString stringWithFormat:NSLocalizedString(@"graphSegmentFormat", @""), _data[index]];
}

@end


#pragma mark -

// We use a seperate view to draw the text for the graph so that we can layer the segment layers below it
// which gives the illusion that the numbers are draw over the graph, and hides the fact that the graph drawing
// for each segment is incomplete until the segment is filled.

@interface SBGraphTextView : UIView
@end


#pragma mark -

@implementation SBGraphTextView

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Fill in the background
	CGContextSetFillColorWithColor(context, graphBackgroundColor());
	CGContextFillRect(context, self.bounds);
	
	CGContextTranslateCTM(context, 0.0, 56.0);
}

@end


#pragma mark -

// Finally the actual GraphView class. This class handles the public interface as well as arranging
// the subviews and sublayers to produce the intended effect.

@interface SBGraphViewFwd()

// Internal accessors
@property (nonatomic, strong) NSMutableArray *segments;
@property (nonatomic, unsafe_unretained) SBGraphViewSegment *current;
@property (nonatomic, strong) SBGraphViewMarker *marker;
@property (nonatomic) SBGraphViewBoundaryView *boundaryPos;
@property (nonatomic) SBGraphViewBoundaryView *boundaryNeg;

@property (nonatomic) int index_point;
@property (nonatomic) int index_seg;

// Keep height of graph constant
@property (nonatomic, readonly) CGFloat height;

// To help with scaling the graph
@property (nonatomic,readonly) double xscale;
@property (nonatomic,readonly) double xcenter;

// User-specified scaling/center
@property (nonatomic,readonly) double xscale_user;
@property (nonatomic,readonly) double xcenter_user;
@property (nonatomic,readonly) double xmax_user;
@property (nonatomic,readonly) double xmin_user;

// Used for auto-scaling/centering
@property (nonatomic,readonly) double xmax_auto;
@property (nonatomic,readonly) double xmin_auto;
@property (nonatomic,readonly) double xscale_auto;
@property (nonatomic,readonly) double xcenter_auto;

// Used for displaying check again calib
@property (nonatomic) double timeNotify;
@property (nonatomic) NSInteger stateBits;

// A common init routine for use with -initWithFrame: and -initWithCoder:
- (void)commonInit;

// Creates a new segment, adds it to 'segments', and returns a weak reference to that segment
// Typically a graph will have around a dozen segments, but this depends on the width of the graph view and segments
- (SBGraphViewSegment *)addSegment;

// Recycles a segment from 'segments' into  'current'
- (void)recycleSegment;

@end


#pragma mark -

@implementation SBGraphViewFwd

//••@synthesize segments, current, text;

// Designated initializer
- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self != nil)
	{
		[self commonInit];
	}
	return self;
}

// Designated initializer
- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	if (self != nil)
	{
		[self commonInit];
	}
	return self;
}

- (void)commonInit
{
	// This should be constant
    _height = CGRectGetHeight([self bounds]);
    
    // Setup indeces
    _index_point = 0;
    _index_seg = 0;
    
    // Setup scaling/center
    _xscale = 1.0;
    _xcenter = 0.0;
    
    // User specified scaling/centering
    _xscale_user = 1.0;
    _xcenter_user = 0.0;
    _percentAccepted = 0.6;
    
    // Setup scaling/centering for auto-scaling
    _xscale_auto = 1.0;
    _xcenter_auto = 0.0;
    _xmax_auto = -DBL_MAX;
    _xmin_auto = DBL_MAX;
    
    _doAutoScale = true;

    
    // Setup layers/sublayers
    
    // Boundaries to let user know if they are outside of breathing calibration
    _boundaryPos = [[SBGraphViewBoundaryView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height) percentAccepted:_percentAccepted isTop:true];
    // Fill superview
    _boundaryPos.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_boundaryPos];
    _boundaryNeg = [[SBGraphViewBoundaryView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height) percentAccepted:_percentAccepted isTop:false];
    // Fill superview
    _boundaryNeg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_boundaryNeg];

    
    // Initialize time marker (this will be the top most sublayer)
    _marker = [[SBGraphViewMarker alloc] initWithDim:CGPointMake(SBGraphViewMarkerWidthPx,_height)];
    _marker.layer.position = CGPointMake(-0.5*SBGraphViewDeltaX*SBGraphViewSegmentSize,0.5*_height);
    [self.layer addSublayer:_marker.layer];
    
	// Create a mutable array to store segments, which is required by -addSegment
	_segments = [[NSMutableArray alloc] init];
    
    // Create a new current segment, which is required by -addX:y:z and other methods.
	// This is also a weak reference (we assume that the 'segments' array will keep the strong reference).
	_current = [self addSegment];
}

- (void)resetGraph
{
    [self resetGraph:_doAutoScale];
}

- (void)resetGraph:(bool)doAuto
{
    if (doAuto)
    {
        [self calcScaleCenterAuto];
        _xscale = _xscale_auto;
        _xcenter = _xcenter_auto;
    }
    else
    {
        _xscale = _xscale_user;
        _xcenter = _xcenter_user;
    }
        
 
    // keep track, just in case we need it later
    _xmax_auto = -DBL_MAX;
    _xmin_auto = DBL_MAX;

    // Reset marker
    _marker.layer.position = CGPointMake(-0.5*SBGraphViewDeltaX*SBGraphViewSegmentSize,0.5*_height);
    
    // Let's just make sure that there are some segments there to use
    if ([_segments count] > 0)
    {
        _current = [_segments objectAtIndex:0];
        [_current resetIndex];
    } else
        _current = [self addSegment];
    
    // Reset indeces
    _index_point = 0;
    _index_seg = 0;
    
}

- (void)addX:(double)x
{
    _index_point++;

    // Update min/max before scaling/centering
    if (x > _xmax_auto) _xmax_auto = x;
    if (x < _xmin_auto) _xmin_auto = x;
    
    // scale and center
    x = (x - _xcenter) * _xscale;
    
	// First, add the new value to the current segment
	if ([_current addX:x] || _index_point*SBGraphViewDeltaX>self.layer.bounds.size.width)
	{
        float* xhist = [_current data] + [_current capacity];
        
		// If after doing that we've filled up the current segment, then we need to
		// determine the next current segment
		[self recycleSegment];
		// And to keep the graph looking continuous, we add the acceleration value to
        // the new segment as well... only if it is not the first segment
        if (_index_seg != 0)
        {
            //[self.current addX:x];
            for (int i = 0; i < SBGraphViewSegmentOverlap; i++)
                [self.current addX:xhist[i]];
        }
	}
    
    
    // Update marker
    CGPoint markerPosition = CGPointMake(-0.5*SBGraphViewDeltaX*SBGraphViewSegmentSize,0.5*_height);
    markerPosition.x += _index_point*SBGraphViewDeltaX + SBGraphViewDeltaX*SBGraphViewSegmentSize*0.5;
    self.marker.layer.position = markerPosition;
    //self.marker.layer.zPosition = 1;
}

- (SBGraphViewSegment *)addSegment
{
	// Create a new segment and add it to the segments array.
	SBGraphViewSegment *segment = [[SBGraphViewSegment alloc] initWithCapacity:SBGraphViewSegmentSize dim:CGPointMake(SBGraphViewDeltaX*SBGraphViewSegmentSize,_height) padY:SBGraphViewPadY];
    [segment setPercentAccepted:_percentAccepted];
    
    // Insert object into array while keeping weak reference to segment
    [_segments insertObject:segment atIndex:_index_seg];
    
    // Insert sublayer right below marker
    [self.layer insertSublayer:segment.layer below:_marker.layer];
    //[self.layer insertSublayer:segment.layer above:[[self.layer sublayers] lastObject]];

	// Position it properly
    CGPoint cur = CGPointMake(-0.5*SBGraphViewDeltaX*SBGraphViewSegmentSize,0.5*_height);
    cur.x += (_index_seg+1)*(SBGraphViewDeltaX*SBGraphViewSegmentSize); // - SBGraphViewDeltaX);
	segment.layer.position = cur;
	
	return segment;
}

- (void)recycleSegment
{
    // Increment segement number
    _index_seg++;
    
    // Check to see if we are still within the window bounds
    if (_index_point*SBGraphViewDeltaX < self.bounds.size.width)
    {
        if (_index_seg < [_segments count])
        {
            //NSLog(@"reuse old segment: %d",_index_seg);
            _current = [_segments objectAtIndex:_index_seg];
            [_current resetIndex];
        }
        else
        {
            //NSLog(@"adding new segment: %d",_index_seg);
            _current.isnew = false;
            _current = [self addSegment];
        }
        
    }
    else
    {
        _current.isnew = false;
        // Outside of graph bounds!
        //   Are there left over segments & layers that we don't need? If so, remove them.
        if (_index_seg < [_segments count])
        {
            NSLog(@"Removing some segments...");
            NSRange rmrange = NSMakeRange(_index_seg,[_segments count]-_index_seg);
            for (int i = _index_seg; i < [_segments count]; i++)
                [((SBGraphViewSegment*)[_segments objectAtIndex:i]).layer removeFromSuperlayer];
            [_segments removeObjectsInRange:rmrange];
        }
        
        // Grab the first segment
        _index_point = 0;
        _index_seg = 0;
        _current = [_segments objectAtIndex:0];
        [_current resetIndex];
        
        // Reset scaling and centering of graph
        [self calcScaleCenterAuto];
        [self resetGraph:_doAutoScale];
    }
}

#pragma mark Calculating centering/scaling

- (double) calcCenterFromMax:(double)xmax min:(double)xmin
{
    return (xmax + xmin)*0.5;
}

- (double) calcScaleFromMax:(double)xmax min:(double)xmin
{
    double scale = (xmax - xmin < 0.001)? 1.0 : 1.0/(xmax - xmin);
    return scale*2.0f*_percentAccepted;
}

- (void) calcScaleCenterAuto
{
    _xcenter_auto = [self calcCenterFromMax:_xmax_auto min:_xmin_auto];
    _xscale_auto = [self calcScaleFromMax:_xmax_auto min:_xmin_auto];
    
    //_boundary.stateBits &= ~SBGraphViewState_Monitor;
}

- (void) calcScaleCenterUserFromMax:(double)xmax min:(double)xmin
{
    _xmax_user = xmax;
    _xmin_user = xmin;
    
    _xcenter_user = [self calcCenterFromMax:xmax min:xmin];
    _xscale_user = [self calcScaleFromMax:xmax min:xmin];
    
    //_boundary.stateBits |= SBGraphViewState_Monitor;
}


#pragma mark Actual drawing

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    NSLog(@"Setting frame!");
}

// The graph view itself exists only to draw the background and gridlines. All other content is drawn either into
// the GraphTextView or into a layer managed by a GraphViewSegment.
- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	// Fill in the background
	CGContextSetFillColorWithColor(context, graphBackgroundColor());
	CGContextFillRect(context, self.bounds);
	CGFloat width = self.bounds.size.width;
	CGContextTranslateCTM(context, 0.0, 0.5*_height);
    
	// Draw the grid lines
    DrawGridlines(context, 0.0, CGPointMake(width, _height), CGPointMake(5,SBGraphViewPadY), SBGraphViewNumLines);
}

// Return an up-to-date value for the graph.
- (NSString *)accessibilityValue
{
	if (self.segments.count == 0)
	{
		return nil;
	}
	
	// Let the GraphViewSegment handle its own accessibilityValue;
	SBGraphViewSegment *graphViewSegment = self.segments[0];
	return [graphViewSegment accessibilityValue];
}

#pragma mark - Checking against calibration

- (void)setDoAutoScale:(bool)doAutoScale
{
    _doAutoScale = doAutoScale;
    if (!_doAutoScale)
    {
        NSLog(@"Using calibration information...");
        [_boundaryPos addState:SBGraphViewState_Monitor];
        [_boundaryNeg addState:SBGraphViewState_Monitor];
    }
}

- (void)setPercentAccepted:(CGFloat)percent
{
    [_boundaryNeg setPercentAccepted:percent];
    [_boundaryPos setPercentAccepted:percent];
    
    _percentAccepted = [_boundaryPos percentAccepted];
}


- (void)timerNotifyNegFireMethod:(NSTimer *)timer
{
    _stateBits &= !SBGraphViewState_Caution;
    //[_boundary.layer setNeedsDisplay];
}

- (void)timerNotifyPosFireMethod:(NSTimer *)timer
{
    //_stateBits &= !SBGraphViewState_Positive;
    //[_boundary.layer setNeedsDisplay];
}

@end

