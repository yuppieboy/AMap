//
//  ViewController.m
//  HelloAmap
//
//  Created by Paul on 15/8/14.
//  Copyright (c) 2015年 Jijesoft. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>

#define  APIKey @"00f7ffa8bfbc1fdc4749a7fba3c947a6"

@interface ViewController ()<MAMapViewDelegate,AMapSearchDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
{
    MAMapView *_mapView;
    UIButton *_locationButton;
    AMapSearchAPI *_search;
    CLLocation *_currentLocation;
    UIButton *_searchbutton;
    
    UITableView *_tableview;
    NSArray *_pois;
    NSMutableArray *_annotations;
    
    UILongPressGestureRecognizer *_longPressGesture;
    
    MAPointAnnotation *_destinationPoint;
    UIButton *_pathButton;
    
    NSArray *_pathPolylines;
    
    BOOL fisrtload;
    
}
@end

@implementation ViewController

#pragma mark - Init

-(void)initAttributes
{
    _annotations=[NSMutableArray array];
    _pois=nil;
    
    _longPressGesture=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    _longPressGesture.delegate=self;
    [_mapView addGestureRecognizer:_longPressGesture];
}

-(void)initTableView
{
    CGFloat halfheight=CGRectGetHeight(self.view.bounds)/2;
    _tableview=[[UITableView alloc]initWithFrame:CGRectMake(0, halfheight, CGRectGetWidth(self.view.bounds), halfheight)];
    _tableview.backgroundColor=[UIColor whiteColor];
    _tableview.delegate=self;
    _tableview.dataSource=self;
    
    [self.view addSubview:_tableview];
}

-(void)initMapView
{
    [MAMapServices sharedServices].apiKey=APIKey;
    _mapView=[[MAMapView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)/2)];
    _mapView.delegate=self;
    _mapView.compassOrigin=CGPointMake(_mapView.compassOrigin.x, 22);
    _mapView.scaleOrigin=CGPointMake(_mapView.scaleOrigin.x, 22);
    [self.view addSubview:_mapView];

    _mapView.showsUserLocation=YES;
    
    [_mapView setUserTrackingMode:MAUserTrackingModeFollow animated:NO];
    
}

-(void)initcontrols
{
    _locationButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_locationButton setFrame:CGRectMake(20, CGRectGetHeight(self.view.bounds)/2-80, 40, 40)];
    _locationButton.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
    _locationButton.backgroundColor=[UIColor whiteColor];
    _locationButton.layer.cornerRadius=5;
    
    [_locationButton setBackgroundImage:[UIImage imageNamed:@"location_no"] forState:UIControlStateNormal];
    
    [_locationButton addTarget:self action:@selector(locateAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_locationButton];
    
    
    _searchbutton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    _searchbutton.frame=CGRectMake(80, CGRectGetHeight(self.view.bounds)/2-80, 40, 40);
    
    _searchbutton.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
    _searchbutton.backgroundColor=[UIColor whiteColor];
    _searchbutton.layer.cornerRadius=5;
    
    [_searchbutton setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    
    [_searchbutton addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_searchbutton];
    
//    _pathButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
//    _pathButton.frame=CGRectMake(140, CGRectGetHeight(self.view.bounds)/2-80, 40, 40);
//    _pathButton.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
//    _pathButton.backgroundColor=[UIColor whiteColor];
//    _pathButton.tintColor=[UIColor blackColor];
//    _pathButton.layer.cornerRadius=5;
//    [_pathButton setImage:[UIImage imageNamed:@"navigation"] forState:UIControlStateNormal];
//    [_pathButton addTarget:self action:@selector(pathAction) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:_pathButton];
    

    
}

-(void)initSearch
{
    _search=[[AMapSearchAPI alloc]initWithSearchKey:APIKey Delegate:self];
}


#pragma mark - Action

-(void)pathAction
{
    if(_destinationPoint == nil || _currentLocation == nil || _search == nil)
    {
        NSLog(@"path search failed");
        return;
    }
    
    AMapNavigationSearchRequest *request=[[AMapNavigationSearchRequest alloc]init];
    request.searchType=AMapSearchType_NaviDrive;
    request.origin=[AMapGeoPoint locationWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];
    request.destination=[AMapGeoPoint locationWithLatitude:_destinationPoint.coordinate.latitude longitude:_destinationPoint.coordinate.longitude];
    
    [_search AMapNavigationSearch:request];
    
}


-(void)buttonAction_around
{
    if(_currentLocation == nil || _search == nil)
    {
        NSLog(@"path search failed");
        return;
    }
    
    AMapNavigationSearchRequest *request=[[AMapNavigationSearchRequest alloc]init];
    request.searchType=AMapSearchType_NaviWalking;
    request.origin=[AMapGeoPoint locationWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];
    
    MAPointAnnotation *destinatePoint=_annotations[0];
    _destinationPoint=destinatePoint;
    
    request.destination=[AMapGeoPoint locationWithLatitude:_destinationPoint.coordinate.latitude longitude:_destinationPoint.coordinate.longitude];
    
    [_search AMapNavigationSearch:request];
}

-(void)buttonAction_custom
{
    if(_destinationPoint == nil || _currentLocation == nil || _search == nil)
    {
        NSLog(@"path search failed");
        return;
    }
    
    AMapNavigationSearchRequest *request=[[AMapNavigationSearchRequest alloc]init];
    request.searchType=AMapSearchType_NaviWalking;
    request.origin=[AMapGeoPoint locationWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];
    
    request.destination=[AMapGeoPoint locationWithLatitude:_destinationPoint.coordinate.latitude longitude:_destinationPoint.coordinate.longitude];
    
    [_search AMapNavigationSearch:request];
}

-(void)locateAction
{
    if (_mapView.userTrackingMode!=MAUserTrackingModeFollow) {
        [_mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
    }
}

-(void)searchAction
{
    if (_currentLocation==nil || _search ==nil) {
        NSLog(@"search failed");
        return;
    }
    
    AMapPlaceSearchRequest *request=[[AMapPlaceSearchRequest alloc]init];
    request.searchType=AMapSearchType_PlaceAround;
    request.location=[AMapGeoPoint locationWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];
    request.keywords=@"酒店";
    [_search AMapPlaceSearch:request];
    
}



-(void)reGeoAction
{
    if (_currentLocation) {
        AMapReGeocodeSearchRequest *request=[[AMapReGeocodeSearchRequest alloc]init];
        request.location=[AMapGeoPoint locationWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];
        [_search AMapReGoecodeSearch:request];
    }
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CLLocationCoordinate2D coordinate=[_mapView convertPoint:[gesture locationInView:_mapView] toCoordinateFromView:_mapView];
        
        //添加标注
        if (_destinationPoint!=nil) {
            [_mapView removeAnnotation:_destinationPoint];
            _destinationPoint=nil;
        }
        _destinationPoint=[[MAPointAnnotation alloc]init];
        _destinationPoint.coordinate=coordinate;
        _destinationPoint.title=@"Destination";
        
        [_mapView addAnnotation:_destinationPoint];
        
    }
}

#pragma mark - Tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _pois.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"cellIdentifier";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    AMapPOI *poi=[_pois objectAtIndex:indexPath.row];
    cell.textLabel.text=poi.name;
    cell.detailTextLabel.text=poi.address;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AMapPOI *poi=[_pois objectAtIndex:indexPath.row];
    MAPointAnnotation *annotation=[[MAPointAnnotation alloc]init];
    annotation.coordinate=CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
    annotation.title=poi.name;
    annotation.subtitle=poi.address;

    
    [_mapView removeAnnotations:_annotations];
    [_annotations removeAllObjects];

    [_annotations addObject:annotation];
    [_mapView addAnnotation:annotation];

    [_mapView setCenterCoordinate:annotation.coordinate animated:YES];
    
}


#pragma mark Map delegate

- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]]) {
        MAPolylineView *polylineView=[[MAPolylineView alloc]initWithOverlay:overlay];
        polylineView.lineWidth=4;
        polylineView.strokeColor=[UIColor magentaColor];
        polylineView.lineCapType=kMALineCapRound;
        return polylineView;
    }
    
    return nil;
    
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if (annotation == _destinationPoint) {
        static NSString *resueIdentifier=@"annonationResueIdentifier";
        MAPinAnnotationView *annotationView=(MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:resueIdentifier];
        if (annotationView == nil) {
            annotationView=[[MAPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:resueIdentifier];
        }
        
        annotationView.canShowCallout=YES;
        
        UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        [button setImage:[UIImage imageNamed:@"navigation"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction_custom) forControlEvents:UIControlEventTouchUpInside];
        annotationView.rightCalloutAccessoryView=button;
        
        return annotationView;

    }
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *resueIdentifier=@"annonationResueIdentifier";
        MAPinAnnotationView *annotationView=(MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:resueIdentifier];
        if (annotationView == nil) {
            annotationView=[[MAPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:resueIdentifier];
        }
        
        annotationView.image=[UIImage imageNamed:@"pin"];
        annotationView.canShowCallout=YES;
        
        UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        [button setImage:[UIImage imageNamed:@"navigation"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction_around) forControlEvents:UIControlEventTouchUpInside];
        annotationView.rightCalloutAccessoryView=button;
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated
{
    if(mode == MAUserTrackingModeNone)
    {
        [_locationButton setBackgroundImage:[UIImage imageNamed:@"location_no"] forState:UIControlStateNormal];
    }else
    {
        [_locationButton setBackgroundImage:[UIImage imageNamed:@"location_yes"] forState:UIControlStateNormal];
    }
}


- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    //选中定位annotation的时候进行逆地理位置编码查询
    if ([view.annotation isKindOfClass:[MAUserLocation class]]) {
        [self reGeoAction];
    }
    
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    NSLog(@"userLocation = %@",userLocation.location);
    _currentLocation=[userLocation.location copy];
    
    
    if (_currentLocation && !fisrtload) {
        CGPoint currentPoint=[_mapView convertCoordinate:_currentLocation.coordinate toPointToView:_mapView];
        [_mapView setZoomLevel:15 atPivot:currentPoint animated:NO];
        
        fisrtload=YES;
    }
}

-(CLLocationCoordinate2D *)coodinatesForString:(NSString *)string coordinateCount:(NSUInteger *)coordinateCount parseToken:(NSString *)token
{
    if (string == nil) {
        return NULL;
    }
    if (token == nil) {
        token = @",";
    }
    
    NSString *str=@"";
    if (![token isEqualToString:@","]) {
        str=[string stringByReplacingOccurrencesOfString:token withString:@","];
    }else
    {
        str=[NSString stringWithString:string];
    }
    
    NSArray *components=[str componentsSeparatedByString:@","];
    NSUInteger count =[components count]/2;
    if (coordinateCount!=NULL) {
        *coordinateCount=count;
    }
    CLLocationCoordinate2D *coordinates=(CLLocationCoordinate2D *)malloc(count *sizeof(CLLocationCoordinate2D));
    for (int i=0; i<count; i++) {
        coordinates[i].longitude = [[components objectAtIndex:2*i]doubleValue];
        coordinates[i].latitude = [[components objectAtIndex:2*i+1]doubleValue];
    }
    
    return coordinates;
}

-(NSArray *)polylinesForPath:(AMapPath *)path
{
    if (path == nil || path.steps.count==0) {
        return nil;
    }
    
    NSMutableArray *polylines=[NSMutableArray array];
    [path.steps enumerateObjectsUsingBlock:^(AMapStep *step, NSUInteger idx, BOOL *stop) {
        NSUInteger count=0;
        CLLocationCoordinate2D *coordinates=[self coodinatesForString:step.polyline coordinateCount:&count parseToken:@";"];
        
        MAPolyline *polyline=[MAPolyline polylineWithCoordinates:coordinates count:count];
        
        [polylines addObject:polyline];
        
        free(coordinates),coordinates = NULL;
    }];
    
    return polylines;
}


#pragma  mark - MapSearch delegate

- (void)searchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"request : %@ , error : %@",request,error);
}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    NSLog(@"response : %@",response);
    NSString *title=response.regeocode.addressComponent.city;
    if (title.length == 0) {
        title=response.regeocode.addressComponent.province;
    }
    _mapView.userLocation.title=title;
    _mapView.userLocation.subtitle=response.regeocode.formattedAddress;
}

- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response
{
    NSLog(@"requst : %@",request);
    NSLog(@"response : %@",response);
    
    if (response.pois.count > 0) {
        _pois=response.pois;
        [_tableview reloadData];
    }
    
    [_mapView removeAnnotations:_annotations];
    [_annotations removeAllObjects];
    
}

- (void)onNavigationSearchDone:(AMapNavigationSearchRequest *)request response:(AMapNavigationSearchResponse *)response
{
    if (response.count>0) {
        [_mapView removeOverlays:_pathPolylines];
        _pathPolylines=nil;
        
        //只显示一条
        _pathPolylines = [self polylinesForPath:response.route.paths[0]];
        [_mapView addOverlays:_pathPolylines];
        [_mapView showAnnotations:@[_destinationPoint,_mapView.userLocation] animated:YES];
        
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initMapView];
    [self initcontrols];
    [self initSearch];
    [self initAttributes];
    [self initTableView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
