//
//  PlayerShip.m
//  XBlaster
//
//  Created by Main Account on 8/31/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "PlayerShip.h"
#import "MyScene.h"

@implementation PlayerShip {
  SKEmitterNode *_ventingPlasma;
}

- (instancetype)initWithPosition:(CGPoint)position
{
  if (self = [super initWithPosition:position]) {
    self.name = @"shipSprite";
    self.health = 100;
    
    SKEmitterNode *engineEmitter =
      [NSKeyedUnarchiver unarchiveObjectWithFile:
       [[NSBundle mainBundle] pathForResource:@"engine"
                                       ofType:@"sks"]];
    engineEmitter.position = CGPointMake(1, -4);
    engineEmitter.name = @"engineEmitter";
    [self addChild:engineEmitter];
    
    _ventingPlasma =
      [NSKeyedUnarchiver unarchiveObjectWithFile:
       [[NSBundle mainBundle] pathForResource:@"ventingPlasma"
                                       ofType:@"sks"]];
    _ventingPlasma.hidden = TRUE;
    [self addChild:_ventingPlasma];
    
    [self configureCollisionBody];
  }
  return self;
}

+ (SKTexture *)generateTexture
{
  // 1 
  static SKTexture *texture = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    
    // 2
    SKLabelNode *mainShip = 
      [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    mainShip.name = @"mainship";
    mainShip.fontSize = 20.0f;
    mainShip.fontColor = [SKColor whiteColor];
    mainShip.text = @"▲";
    
    // 3
    SKLabelNode *wings = 
      [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    wings.name = @"wings";
    wings.fontSize = 20.0f;
    wings.text = @"< >";
    wings.fontColor = [SKColor whiteColor];
    wings.position = CGPointMake(0, 7);
    
    // 4
    wings.zRotation = DegreesToRadians(180);

    [mainShip addChild:wings];
    
    // 5
    SKView *textureView = [SKView new];
    texture = [textureView textureFromNode:mainShip];
    texture.filteringMode = SKTextureFilteringNearest;
  });
  
  return texture;
}

- (void)configureCollisionBody
{
  //    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:[self childNodeWithName:@"shipSprite"].frame.size];
  self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:15];
  
  self.physicsBody.affectedByGravity = NO;
  
  // Set the category of the physics object that will be used for collisions
  self.physicsBody.categoryBitMask = ColliderTypePlayer;
  
  // We want to know when a collision happens but we dont want the bodies to actually react to each other so we
  // set the collisionBitMask to 0
  self.physicsBody.collisionBitMask = 0;
  
  // Make sure we get told about these collisions
  self.physicsBody.contactTestBitMask = ColliderTypeEnemy;
}

- (void)collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact*)contact
{
  MyScene * scene = (MyScene *)self.scene;
  [scene playExplodeSound];

  self.health -= 5;
  if (self.health < 0)
    self.health = 0;
  
  _ventingPlasma.hidden = self.health > 30;
  
}

- (void)update:(CFTimeInterval)delta
{
  SKEmitterNode *emitter = (SKEmitterNode *) [self childNodeWithName:@"engineEmitter"];
  MyScene * scene = (MyScene *)self.scene;
  if (!emitter.targetNode) {
    emitter.targetNode = [scene particleLayerNode];
  }
}

@end
