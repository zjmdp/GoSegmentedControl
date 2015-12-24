# GoSegmentedControl

[![Version](https://img.shields.io/cocoapods/v/GoSegmentedControl.svg?style=flat)](http://cocoapods.org/pods/GoSegmentedControl)
[![License](https://img.shields.io/cocoapods/l/GoSegmentedControl.svg?style=flat)](http://cocoapods.org/pods/GoSegmentedControl)
[![Platform](https://img.shields.io/cocoapods/p/GoSegmentedControl.svg?style=flat)](http://cocoapods.org/pods/GoSegmentedControl)


`GoSegmentedControl` provides fully customizable and scrollable segmented control.

#ScreenShot
![Screenshot](./Screenshots/screenshot.gif "screenshot")

## Installation
###CocoaPods
```ruby

pod 'GoSegmentedControl', '~> 0.1'

```

###Manually
1. Downloads the source files in directory `GoSegmentedControl/Classes`.
2. Add the source files to your project.
3. import `"GoSegmentedControl.h"` in your files.

## Usage
#### Create GoSegmentedControl

```objc

GoSegmentedControl *segmentedControl = [[GoSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 50)];
segmentedControl.delegate = self;
segmentedControl.dataSource = self;
segmentedControl.selectionIndicatorHeight = 3;
segmentedControl.indicatorMargin = 4.f;
segmentedControl.selectionIndicatorColor = [UIColor grayColor];

```

#### Implement GoSegmentedControlDataSource

```objc

- (NSInteger)numberOfSegmentsInGoSegmentedControl:(GoSegmentedControl *)segmentedControl{
    return 10;
}

- (UIView *)segmentedControl:(GoSegmentedControl *)segmentedControl customSegmentViewAtIndex:(NSInteger)index{
    UILabel *label = [UILabel new];
    [label setText:[NSString stringWithFormat:@"Segment: %@", @(index)]];
    return label;
}

```

#### Implement GoSegmentedControlDelegate

```objc

- (CGFloat)segmentedControl:(GoSegmentedControl *)segmentedControl widthForSegmentAtIndex:(NSInteger)index{
    return 50;
}

```

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## Credits

* zjmdp

## License

MIT license
