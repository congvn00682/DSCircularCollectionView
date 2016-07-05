//
//  DSCircularLayout.m
//  DSCircularCollectionViewExample
//
//  Created by Srinivasan Dodda on 04/07/16.
//  Copyright © 2016 Srinivasan Dodda. All rights reserved.
//

#import "DSCircularLayout.h"

@implementation DSCircularLayout{
    CGFloat angleOfEachItem;
    CGFloat angleForSpacing;
    CGFloat circumference;
    long cellCount;
    CGFloat maxNoOfCellsInCircle;
    
    CGFloat startAngle;
    CGFloat endAngle;
}

- (id)init {
    self = [super init];
    if (self) {
        startAngle = M_PI;
        endAngle = 0;
    }
    return self;
}

-(void)initWithCentre:(CGPoint)centre radius:(CGFloat)radius itemSize:(CGSize)itemSize andAngularSpacing:(CGFloat)angularSpacing{
    _centre = centre;
    _radius = radius;
    _itemSize = itemSize;
    _angularSpacing = angularSpacing;
}

-(void)prepareLayout{
    [super prepareLayout];
    cellCount = [self.collectionView numberOfItemsInSection:0];
    circumference = (startAngle - endAngle)*_radius;
    maxNoOfCellsInCircle =  circumference/(MAX(_itemSize.width, _itemSize.height) + _angularSpacing/2);
    angleOfEachItem = (startAngle - endAngle)/maxNoOfCellsInCircle;
}

-(CGSize)collectionViewContentSize{
    CGFloat visibleAngle = startAngle - endAngle;
    long remainingItemsCount = cellCount > maxNoOfCellsInCircle ? cellCount - maxNoOfCellsInCircle : 0;
    CGFloat scrollableContentWidth = (remainingItemsCount+0.5)*angleOfEachItem*_radius/(2*M_PI/visibleAngle);
    CGFloat height = _radius + (MAX(_itemSize.width, _itemSize.height)/2);
    
    if(_scrollDirection == UICollectionViewScrollDirectionVertical)
    {
        return CGSizeMake(height, scrollableContentWidth + self.collectionView.bounds.size.height);
    }
    return CGSizeMake(scrollableContentWidth + self.collectionView.bounds.size.width, height);
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(_scrollDirection == UICollectionViewScrollDirectionVertical)
    {
        return [self layoutAttributesForVerticalScrollForItemAtIndexPath:indexPath];
    }
    return [self layoutAttributesForHorozontalScrollForItemAtIndexPath:indexPath];
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForHorozontalScrollForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat offset = self.collectionView.contentOffset.x;
    offset = offset == 0 ? 1 : offset;
    CGFloat offsetPartInMPI = offset/circumference;
    CGFloat angle = 2*M_PI*offsetPartInMPI;
    CGFloat offsetAngle = angle;
    
    attributes.size = _itemSize;
    CGFloat x = _centre.x + offset + _radius*cosf(indexPath.item*angleOfEachItem - offsetAngle + angleOfEachItem/2 - startAngle);
    CGFloat y = _centre.y + _radius*sinf(indexPath.item*angleOfEachItem - offsetAngle + angleOfEachItem/2 - startAngle);
    
    CGFloat cellCurrentAngle = (indexPath.item*angleOfEachItem + angleOfEachItem/2 - offsetAngle);
    if(cellCurrentAngle >= -angleOfEachItem/2 && cellCurrentAngle <= startAngle - endAngle + angleOfEachItem/2){
        attributes.alpha = 1;
    }else{
        attributes.alpha = 0;
    }
    
    attributes.center = CGPointMake(x, y);
    attributes.zIndex = cellCount - indexPath.item;
    return attributes;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForVerticalScrollForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat offset = self.collectionView.contentOffset.y;
    offset = offset == 0 ? 1 : offset;
    CGFloat offsetPartInMPI = offset/circumference;
    CGFloat angle = 2*M_PI*offsetPartInMPI;
    CGFloat offsetAngle = angle;
    
    attributes.size = _itemSize;
    CGFloat x = _centre.x + _radius*cosf(indexPath.item*angleOfEachItem - offsetAngle + angleOfEachItem/2 - startAngle);
    CGFloat y = _centre.y + offset + _radius*sinf(indexPath.item*angleOfEachItem - offsetAngle + angleOfEachItem/2 - startAngle);
    
    CGFloat cellCurrentAngle = indexPath.item*angleOfEachItem + angleOfEachItem/2 - offsetAngle;
    if(cellCurrentAngle >= -angleOfEachItem/2 && cellCurrentAngle <= startAngle - endAngle + angleOfEachItem/2){
        attributes.alpha = 1;
    }else{
        attributes.alpha = 0;
    }
    
    attributes.center = CGPointMake(x, y);
    attributes.zIndex = cellCount - indexPath.item;
    return attributes;
}

-(NSArray <__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray<__kindof UICollectionViewLayoutAttributes *> *attributes = [NSMutableArray array];
    for(NSInteger i=0; i < cellCount; i++){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    return attributes;
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}

@end
