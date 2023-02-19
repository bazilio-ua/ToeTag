
@class TFace;

@interface TEdge : NSObject
{
@public
	TFace* ownerFace;
	int verts[2];
	NSNumber* pickName;
}

-(id) initWithOwner:(TFace*)InOwner Vert0:(int)InVert0 Vert1:(int)InVert1;

-(void) pushPickName;
-(NSNumber*) getPickName;
-(ESelectCategory) getSelectCategory;
-(void) selmgrWasUnselected;
-(BOOL) isSelected:(MAPDocument*)InMap;

@end
