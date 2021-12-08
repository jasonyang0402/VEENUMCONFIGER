//
//  VENetworkMaterialCollectionViewCell.m
//  VEENUMCONFIGER
//
//  Created by apple on 2020/8/31.
//  Copyright © 2020 iOS VESDK Team. All rights reserved.
//

#import "VENetworkMaterialCollectionViewCell.h"
#import "VENetworkMaterialBtn_Cell.h"
#import "VENetworkMaterialView.h"
#import <SDWebImage/SDWebImage.h>

@interface VENetworkMaterialCollectionViewCell()<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate>

@property(nonatomic, assign) float cellWidth;
@property(nonatomic, assign) float cellHeight;
@property(nonatomic, assign) float              collectionOffsetX;
@property(nonatomic, assign) float              collectionOffsetPointX;
@property(nonatomic, assign) BOOL               isVertical_Cell;

@end

@implementation VENetworkMaterialCollectionViewCell

-(void)initCollectView:(BOOL) isVertical_Cell atWidth:(float) cellWidth atHeight:(float) cellHeight
{
    UICollectionViewFlowLayout * flow_Video = [[UICollectionViewFlowLayout alloc] init];
    _cellWidth = cellWidth;
    _cellHeight = cellHeight;
    _isVertical_Cell = isVertical_Cell;
    
    if( isVertical_Cell )
    {
        flow_Video.scrollDirection = UICollectionViewScrollDirectionVertical;
        flow_Video.itemSize = CGSizeMake(floor(_cellWidth),floor(_cellHeight));
    }
    else
    {
        flow_Video.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flow_Video.itemSize = CGSizeMake(_cellWidth,self.bounds.size.height);
    }
    
    flow_Video.headerReferenceSize = CGSizeMake(0,0);
    flow_Video.footerReferenceSize = CGSizeMake(0,0);
    
    flow_Video.minimumInteritemSpacing = 0.0;
    if( isVertical_Cell )
        flow_Video.minimumLineSpacing = 0.0;
    else
        flow_Video.minimumLineSpacing = _cellWidth/2.0/5.0;
        
    UICollectionView * videoCollectionView =  [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flow_Video];
    videoCollectionView.backgroundColor = [UIColor clearColor];
    ((UIScrollView*)videoCollectionView).delegate = self;
    videoCollectionView.tag = 1000000;
    videoCollectionView.dataSource = self;
    videoCollectionView.delegate = self;
    
    ((UIScrollView*)videoCollectionView).delegate = self;
    
    if( !isVertical_Cell )
    {
        
    }
    [videoCollectionView registerClass:[VENetworkMaterialBtn_Cell class] forCellWithReuseIdentifier:@"VENetworkMaterialBtn_Cell"];
    _collectionView = videoCollectionView;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    
//    UIPanGestureRecognizer* moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveGesture:)];
//    [_collectionView addGestureRecognizer:moveGesture];
    
    [self addSubview:_collectionView];
}

#pragma mark-scrollView
#pragma mark - UIScrollViewDelegate (时间轴的更新操作)
//开始滑动
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if( _isDragToChange &&  _delegate && [_delegate respondsToSelector:@selector(cell_ScrollViewWillBeginDragging:)] )
    {
        [_delegate cell_ScrollViewWillBeginDragging:scrollView];
    }
}
/**
 滚动中
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(  _isDragToChange && _delegate && [_delegate respondsToSelector:@selector(cell_ScrollViewDidScroll:)] )
    {
        [_delegate cell_ScrollViewDidScroll:scrollView];
    }
}

/**滚动停止
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if( _isDragToChange &&  _delegate && [_delegate respondsToSelector:@selector(cell_ScrollViewDidEndDecelerating:)] )
    {
        [_delegate cell_ScrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale
{
    if( _isDragToChange &&  _delegate && [_delegate respondsToSelector:@selector(cell_ScrollViewDidEndDecelerating:)] )
    {
        [_delegate cell_ScrollViewDidEndDecelerating:scrollView];
    }
}

/**手指停止滑动
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if( _isDragToChange && _delegate && [_delegate respondsToSelector:@selector(cell_ScrollViewDidEndDragging:willDecelerate:)] )
    {
        [_delegate cell_ScrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    
    if( _isNotMove )
        return;
    
    VENetworkMaterialView * network = (VENetworkMaterialView*)_delegate;
    double conffsetX = scrollView.contentOffset.x;
    NSInteger index = self.tag;
    if( conffsetX > (scrollView.contentSize.width - scrollView.frame.size.width + scrollView.frame.size.height/2.0) )
    {
        network.isAddCount = 0;
        index++;
        if( index > (network.CollectionViewCount-1) )
            index = network.CollectionViewCount-1;
    }
    else if( conffsetX < (-(scrollView.frame.size.height/2.0)) )
    {
        network.isAddCount = 1;
        index--;
        if( index < 0 )
            index = 0;
    }
    
    if( index != self.tag )
    {
        __weak typeof(self) myself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            myself.collectionView.contentOffset = CGPointMake(0, 0);
            if( myself.delegate && [myself.delegate respondsToSelector:@selector(CellIndex:)] )
            {
                [myself.delegate CellIndex:index ];
            }
        });
    }
}

#pragma mark-拖动
-(void)moveGesture:(UIGestureRecognizer *) recognizer
{
    if(  _isDragToChange && _delegate && [_delegate respondsToSelector:@selector(cell_MoveGesture:)] )
    {
        [_delegate cell_MoveGesture:recognizer];
    }
}

#pragma mark- UICollectionViewDelegate/UICollectViewdataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    //NSInteger count = ((float)self.bounds.size.height)/_cellHeight;
    return 1;
}



-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _indexCount;
//    NSInteger count = self.bounds.size.height/_cellHeight;
//    NSInteger  cellCount = _indexCount/count;
//   if( (section +1) < count )
//   {
//       return  (_indexCount == (cellCount*count) )?cellCount:(cellCount+1);
//   }
//    else
//    {
//        if( count == 1  )
//        {
//            return _indexCount;
//        }
//        else if(_indexCount == cellCount*count){
//            return  cellCount;
//        }
//        else{
//            return _indexCount - (cellCount*section);
//        }
//    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"VENetworkMaterialBtn_Cell";
    VENetworkMaterialBtn_Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    NSLog(@"VENetworkMaterialBtn_Cell:%zd,%zd",indexPath.section,indexPath.row);
    if(!cell){
        cell = [[VENetworkMaterialBtn_Cell alloc] initWithFrame:CGRectMake(0, 0, _cellWidth, _cellHeight)];
    }
    
    if( cell.btnCollectBtn )
    {
        if([cell.btnCollectBtn isKindOfClass:[UIButton class]] )
        {
            SDAnimatedImageView *imageView = (SDAnimatedImageView *)[cell.btnCollectBtn viewWithTag:22222];
            imageView.image = nil;
            [imageView removeFromSuperview];
        }
        
        [cell.btnCollectBtn removeFromSuperview];
        cell.btnCollectBtn = nil;
    }
    else{
        SDAnimatedImageView *imageView = (SDAnimatedImageView *)[cell viewWithTag:22222];
        if( imageView )
        {
            imageView.image = nil;
            [imageView removeFromSuperview];
        }
    }
    
    if( _delegate && [_delegate respondsToSelector:@selector(btnCollectCell:atIndexCount:collectionView:)] )
    {
        UIView * view = [_delegate btnCollectCell:indexPath.row atIndexCount:_index collectionView:collectionView];
        cell.btnCollectBtn = view;
        [cell addSubview:view];
    }
    
    
    return cell;
}

-(void)setIsNotMove:(bool)isNotMove
{
//    if( !isNotMove )
//    {
//        if( !_isVertical_Cell )
//        {
//            UIPanGestureRecognizer* moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveGesture:)];
//            [_collectionView addGestureRecognizer:moveGesture];
//        }
//    }
    _isNotMove = isNotMove;
}

// 控制翻页
//- (void) moveGesture:(UIGestureRecognizer *) recognizer
//{
//    if( _isNotMove )
//        return;
//
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        _collectionOffsetPointX = _collectionView.contentOffset.x;
//        _collectionOffsetX = [recognizer locationInView:self.superview].x;
//
//    }else if (recognizer.state == UIGestureRecognizerStateChanged){
//
//        float x = _collectionOffsetPointX + (_collectionOffsetX - [recognizer locationInView:self.superview].x );
//
//        [_collectionView setContentOffset:CGPointMake(x, 0) animated:false];
//
//    }else if (recognizer.state == UIGestureRecognizerStateEnded)
//    {
//        float x = _collectionOffsetPointX + (_collectionOffsetX - [recognizer locationInView:self.superview].x );
//
//        [_collectionView setContentOffset:CGPointMake(x, 0) animated:false];
//
//        float leftX = x - _collectionOffsetPointX;
//
//        BOOL isLeft = true;
//
//        if( leftX == 0 )
//        {
//            [_collectionView setContentOffset:CGPointMake(_collectionOffsetPointX, 0) animated:true];
//            return;
//        }
//        else if( leftX > 0 )
//        {
//            isLeft = false;
//        }
//
//        _collectionView.contentOffset = CGPointMake(x, 0);
//
//        VENetworkMaterialView * network = (VENetworkMaterialView*)_delegate;
//
//        double conffsetX = _collectionView.contentOffset.x;
//
//        NSInteger index = self.tag;
//        if( conffsetX > (_collectionView.contentSize.width - _collectionView.frame.size.width + _collectionView.frame.size.height/2.0) )
//        {
//            index++;
//
//            if( index > (network.CollectionViewCount-1) )
//            {
//                index = network.CollectionViewCount-1;
//
//            }
//        }
//        else if( conffsetX < (-(_collectionView.frame.size.height/2.0)) )
//        {
//            index--;
//            if( index < 0 )
//            {
//                index = 0;
//            }
//        }
//
//        if( index != self.tag )
//        {
//            __weak typeof(self) myself = self;
//            dispatch_async(dispatch_get_main_queue(), ^{
//
//                myself.collectionView.contentOffset = CGPointMake(0, 0);
//
//                if( myself.delegate && [myself.delegate respondsToSelector:@selector(CellIndex:)] )
//                {
//                    [myself.delegate CellIndex:index ];
//                }
//                [network.collectionView setContentOffset:CGPointMake(network.collectionView.frame.size.width*(index), 0) animated:false];
//            });
//        }
//        else{
//            if( conffsetX > _collectionView.contentSize.width - _collectionView.frame.size.width )
//            {
//                _collectionView.contentOffset = CGPointMake(_collectionView.contentSize.width - _collectionView.frame.size.width, 0);
//            }
//            else if( conffsetX < 0 ){
//                _collectionView.contentOffset = CGPointMake(0, 0);
//            }
//        }
//    }
//}

/**手指停止滑动
 */
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//
//
//}

@end
