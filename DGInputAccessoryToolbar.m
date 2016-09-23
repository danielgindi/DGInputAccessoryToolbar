//
//  DGInputAccessoryToolbar.m
//  DGInputAccessoryToolbar
//
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/DGInputAccessoryToolbar
//
//  The MIT License (MIT)
//  
//  Copyright (c) 2014 Daniel Cohen Gindi (danielgindi@gmail.com)
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "DGInputAccessoryToolbar.h"

@interface DGInputAccessoryToolbar ()
@end

@implementation DGInputAccessoryToolbar
{
    id actionTarget;
    SEL prevActionSelector, nextActionSelector, doneActionSelector;
    UISegmentedControl *segmented;
    UIBarButtonItem *doneButton;
}

- (void)initialize_DGInputAccessoryToolbar
{
    CGRect rect = self.frame;
    rect.size.height = 44.f;
    self.frame = rect;
    
    self.barStyle = UIBarStyleDefault;
    self.tintColor = UIColor.blackColor;
    
    NSString *prevString, *nextString;
    
    NSString *localeId = NSBundle.mainBundle.preferredLocalizations[0];
    if ([localeId hasPrefix:@"he"])
    {
        prevString = @"הקודם";
        nextString = @"הבא";
    }
    else
    {
        prevString = @"Previous";
        nextString = @"Next";
    }
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    if (prevActionSelector || nextActionSelector)
    {
        segmented = [[UISegmentedControl alloc] initWithItems:((prevActionSelector&&nextActionSelector) ? @[prevString,nextString] : (prevActionSelector ? @[prevString] : @[nextString]))];
        [segmented addTarget:self action:@selector(segmentedControlChangedValued:) forControlEvents:UIControlEventValueChanged];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
        segmented.segmentedControlStyle = UISegmentedControlStyleBar;
#endif
        
        segmented.momentary = YES;
        [items addObject:[[UIBarButtonItem alloc] initWithCustomView:segmented]];
    }
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:actionTarget action:doneActionSelector];
    
    doneButton.tintColor = UIColor.blackColor;
    
    [items addObject:flexSpace];
    [items addObject:doneButton];
    [self setItems:[items copy] animated:NO];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initialize_DGInputAccessoryToolbar];
    }
    return self;
}

- (id)initWithTarget:(id)target prevAction:(SEL)prevAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction
{
    self = [super init];
    if (self)
    {
        actionTarget = target;
        prevActionSelector = prevAction;
        nextActionSelector = nextAction;
        doneActionSelector = doneAction;
        [self initialize_DGInputAccessoryToolbar];
    }
    return self;
}

- (void)setPreviousEnabled:(BOOL)previousEnabled
{
    if (prevActionSelector)
    {
        [segmented setEnabled:previousEnabled forSegmentAtIndex:0];
    }
}

- (BOOL)previousEnabled
{
    if (prevActionSelector)
    {
        return [segmented isEnabledForSegmentAtIndex:0];
    }
    return NO;
}

- (void)setNextEnabled:(BOOL)nextEnabled
{
    if (nextActionSelector)
    {
        [segmented setEnabled:nextEnabled forSegmentAtIndex:prevActionSelector?1:0];
    }
}

- (BOOL)nextEnabled
{
    if (nextActionSelector)
    {
        return [segmented isEnabledForSegmentAtIndex:prevActionSelector?1:0];
    }
    return NO;
}

- (void)segmentedControlChangedValued:(id)sender
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (segmented.selectedSegmentIndex == 0)
    {
        if (prevActionSelector)
        {
            [actionTarget performSelector:prevActionSelector withObject:segmented];
        }
        else
        {
            [actionTarget performSelector:nextActionSelector withObject:segmented];
        }
    }
    else
    {
        [actionTarget performSelector:nextActionSelector withObject:segmented];
    }
#pragma clang diagnostic pop
}

@end
