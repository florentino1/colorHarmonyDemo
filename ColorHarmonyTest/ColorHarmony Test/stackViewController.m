//
//  stackViewController.m
//  ColorHarmony Test
//
//  Created by 莫玄 on 2021/5/1.
//
#import "stackViewController.h"

@interface stackViewController()

@property (assign,nonatomic)NSUInteger tagtmp;//用于储存正在被拖动的imageView的初始tag；
@property (strong,nonatomic)NSMutableArray *color;//用于储存来自colorArray的随机颜色；
@property (strong,nonatomic)myUIImageView *first;     //第一个不可移动不可交互的色块
@property (strong,nonatomic)myUIImageView *last;      //最后一个不可移动不可交互的色块
@property (strong,nonatomic)UIStackView *stackView;  //用于显示可移动，可交互的色块


@end
@implementation stackViewController

-(instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)coder
{
    self=[super initWithCoder:coder];
    return self;
}
-(void)innerStackViewDoSomeOtherInit
{
    [self setColorArray];
    [self initStackConstraint];
    [self setImages];
}
//进行stackview内部的初始化视图布局
-(void)initStackConstraint
{
    self.axis=UILayoutConstraintAxisHorizontal;
    self.alignment=UIStackViewAlignmentCenter;
    self.layoutMarginsRelativeArrangement=NO;
    self.distribution=UIStackViewDistributionFill;
    
    _first=[[myUIImageView alloc]init];
    _last=[[myUIImageView alloc]init];
    _stackView=[[UIStackView alloc]init];
    
    [self setSingleImageColorWithimageView:_first Index:0 ColorArray:_color];
    [self setSingleImageColorWithimageView:_last Index:COLORNUMBERS-1 ColorArray:_color];
    [_first.heightAnchor constraintEqualToConstant:IMAGEHIGHT].active=true;
    [_first.widthAnchor constraintEqualToConstant:IMAGEWIDTH].active=true;
    
    [_last.heightAnchor constraintEqualToConstant:IMAGEHIGHT].active=true;
    [_last.widthAnchor constraintEqualToConstant:IMAGEWIDTH].active=true;
    
    [self.stackView.heightAnchor constraintEqualToConstant:IMAGEHIGHT].active=true;
    
    [self addArrangedSubview:_first];
    [self addArrangedSubview:_stackView];
    [self addArrangedSubview:_last];
    
    [self setCustomSpacing:BIGSPACING afterView:_first];
    [self setCustomSpacing:BIGSPACING afterView:_stackView];
    
    self.stackView.axis=UILayoutConstraintAxisHorizontal;
    self.stackView.spacing=SMALLSPACING;
    self.stackView.distribution=UIStackViewDistributionEqualSpacing;
    self.stackView.alignment=UIStackViewAlignmentCenter;
    self.stackView.layoutMarginsRelativeArrangement=NO;
}
-(void)setColorArray
{
    colorArray *colorA=[colorArray sharedColorArray];
    if(self.tag==100)
    {
        _color=colorA.myColorArray[0];
        return;
    }
    else if(self.tag==200)
    {
        _color=colorA.myColorArray[1];
        return;;
    }
    else if(self.tag==300)
    {
        _color=colorA.myColorArray[2];
        return;
    }
    else if(self.tag==400)
    {
        _color=colorA.myColorArray[3];
        return;
    }
    NSException *erro=[NSException exceptionWithName:@"no_tag" reason:@"inner_stack_view has no tag val" userInfo:nil];
    [erro raise];
}
-(void)setImages
{
    for(int i=1;i<COLORNUMBERS-1;i++)
    {
            //设置imageview的基本参数
            myUIImageView *image=[[myUIImageView alloc]init];
            image.tag=i+self.tag;
            image.userInteractionEnabled=YES;
            [image.heightAnchor constraintEqualToConstant:IMAGEHIGHT].active=true;
            [image.widthAnchor constraintEqualToConstant:IMAGEWIDTH].active=true;

            //设置每个色块的颜色
            [self setSingleImageColorWithimageView:image Index:i ColorArray:_color];

            //设置手势识别器
            [self imageViewSetPanGesture:image];

            [self.stackView addArrangedSubview:image];
    }
}
-(void)imageViewSetPanGesture:(myUIImageView *)image
{
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc]init];
    pan.maximumNumberOfTouches=1;
    pan.minimumNumberOfTouches=1;
    [pan addTarget:self action:@selector(panMove:)];
    [image addGestureRecognizer:pan];
}
-(void)setSingleImageColorWithimageView:(myUIImageView *)image Index:(int)i ColorArray:(NSMutableArray *)color
{
    RGBColor *rgbColor=color[i];
    UIColor *colorForImageView=[UIColor colorWithRed:rgbColor.R/255.0 green:rgbColor.G/255.0 blue:rgbColor.B/255.0 alpha:1.0];
    image.backgroundColor=colorForImageView;
    image.colorInfo=rgbColor;
}
-(void)refreshSingleImageViewColor
{
    [self setColorArray];
    for(int i=1;i<COLORNUMBERS-1;i++)
    {
        myUIImageView *image=[self viewWithTag:(i+self.tag)];
        [self setSingleImageColorWithimageView:image Index:i ColorArray:self.color];
    }
}
-(void)panMove:(UIPanGestureRecognizer *)sender
{
    myUIImageView *imageView=(myUIImageView *)sender.view;
    CGPoint trans=[sender translationInView:sender.view.superview];     //以自身的左上角为原点，每次移动时计算与原点的差值
    
    if(sender.state==UIGestureRecognizerStateBegan)
    {
        imageView.positionOriginX=sender.view.center.x;
        imageView.positionOriginY=sender.view.center.y;
        imageView.positionCurrentX=imageView.positionOriginX;
        imageView.positionCurrentY=imageView.positionOriginY;
        NSLog(@"当前正在移动的imageview 序号为：%lu,初始坐标为：%f,%f\n",(unsigned long)imageView.tag,imageView.positionOriginX,imageView.positionOriginY);
    }
    else if(sender.state==UIGestureRecognizerStateChanged)
    {
        NSUInteger imageViewTag=imageView.tag;
        myUIImageView *nextImageView;
        imageView.positionCurrentX=imageView.positionOriginX+trans.x;
        imageView.positionCurrentY=imageView.positionOriginY+trans.y;
        imageView.center=CGPointMake(imageView.positionCurrentX,imageView.positionCurrentY);
        if(trans.x>0)
        {
            if(imageViewTag<self.tag+COLORNUMBERS-2)
                nextImageView=[self viewWithTag:imageViewTag+1];
            else
                nextImageView=imageView;
        }
        else if(trans.x<0)
        {
            if(imageViewTag!=self.tag+1)
                nextImageView=[self viewWithTag:imageViewTag-1];
            else
                nextImageView=imageView;
            trans.x*=-1;
        }
        if(trans.x>=SHOULDEXCHANGESPACING && trans.x<2*SHOULDEXCHANGESPACING)
        {
            [self exchangeView:imageView withView:nextImageView];
            imageView.tag=nextImageView.tag;
            nextImageView.tag=imageViewTag;
            [sender setTranslation:CGPointMake(0, 0) inView:sender.view.superview];
        }
    }
    else if(sender.state==UIGestureRecognizerStateCancelled || UIGestureRecognizerStateEnded)
    {
        [UIView animateWithDuration:0.2 animations:^(){
            imageView.center=CGPointMake(imageView.positionOriginX, imageView.positionOriginY);
        } completion:nil];
    }
}
-(void)exchangeView:(myUIImageView *)current withView:(myUIImageView *)other
{
    CGFloat tmpx=current.positionOriginX;
    current.positionOriginX=current.positionCurrentX=other.center.x;
    [UIView animateWithDuration:0.2 animations:^(){
        other.center=CGPointMake(tmpx, other.center.y);
    } completion:nil];
}
@end
