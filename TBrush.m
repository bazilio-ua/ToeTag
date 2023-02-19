
@implementation TBrush

-(id) init
{
	[super init];
	
	faces = [NSMutableArray new];
	pickName = nil;
	quickGroupID = -1;
	bTemporaryBrush = FALSE;
	
	return self;
}

-(void) pushPickName
{
	if( pickName == nil )
	{
		pickName = [NSNumber numberWithUnsignedInt:[[TGlobal G] generatePickName]];
	}
	
	glPushName( [pickName unsignedIntValue] );
}

-(NSNumber*) getPickName
{
	if( pickName == nil )
	{
		pickName = [NSNumber numberWithUnsignedInt:[[TGlobal G] generatePickName]];
	}
	
	return pickName;
}

-(int) getQuickGroupID
{
	return quickGroupID;
}

-(ESelectCategory) getSelectCategory
{
	return TSC_Level;
}

-(void) selmgrWasUnselected
{
	MAPDocument* map = [[NSDocumentController sharedDocumentController] currentDocument];
	
	for( TFace* F in faces )
	{
		for( TVec3D* V in F->verts )
		{
			[map->selMgr removeSelection:V];
		}
	}
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
	TBrush* newbrush = [TBrush new];
	
	for( TFace* F in faces )
	{
		[newbrush->faces addObject:[F mutableCopy]];
	}
	
	newbrush->pickName = [pickName copy];
	
	return newbrush;
}

-(void) generateTexCoords:(MAPDocument*)InMAP
{
	for( TFace* F in faces )
	{
		[F generateTexCoords:InMAP];
	}
}

-(void) drawSelectionHighlights:(MAPDocument*)InMAP
{
	// Draws the faces of the brush with a highlight color over them
	
	[self drawFlatFaces:InMAP Color:[TGlobal G]->colorSelectedBrush];
	
	// Draws the outline of the brush in bold white
	
	glLineWidth( 2.0 );
	[self drawHighlightedOutline:InMAP Color:[TGlobal G]->colorMedGray];
	glLineWidth( 1.0 );
	
	// Verts
	
	[self drawVerts:[TGlobal G]->colorMedGray MAP:InMAP];
	
	// Draws the outline of the brush in a less bold color so you can see the extents
	
	glDepthFunc( GL_GREATER );
	
	glLineWidth( 2.0 );
	[self drawHighlightedOutline:InMAP Color:[TGlobal G]->colorDkGray];
	glLineWidth( 1.0 );
	
	[self drawVerts:[TGlobal G]->colorDkGray MAP:InMAP];

	glDepthFunc( GL_ALWAYS );

	// Selected edges
	
	glColor3f( 1, 1, 1 );
	glLineWidth( 2.0f );
	glDisable( GL_TEXTURE_2D );
	
	glBegin( GL_LINES );
	{
		for( TFace* F in faces )
		{
			for( TEdge* G in F->edges )
			{
				TVec3D* v0 = [F->verts objectAtIndex:G->verts[0]];
				TVec3D* v1 = [F->verts objectAtIndex:G->verts[1]];
				
				if( [InMAP->selMgr isSelected:v0] && [InMAP->selMgr isSelected:v1] )
				{
					glVertex3fv( &v0->x );
					glVertex3fv( &v1->x );
				}
			}
		}
	}
	
	glEnd();

	glDepthFunc( GL_LEQUAL );
	
	glEnable( GL_TEXTURE_2D );
	glLineWidth( 1.0f );
}

-(void) drawVerts:(TVec3D*)InColor MAP:(MAPDocument*)InMAP
{
	glDisable( GL_TEXTURE_2D );
	
	// Draw the vertices
	
	glBegin( GL_POINTS );
	{
		for( TFace* F in faces )
		{
			for( TVec3D* V in F->verts )
			{
				if( [InMAP->selMgr isSelected:V] )
				{
					glColor3f( 1, 1, 1 );
				}
				else
				{
					glColor3fv( &InColor->x );
				}
				
				glVertex3fv( &V->x );
			}
		}
	}
	glEnd();

	glEnable( GL_TEXTURE_2D );
}

-(void) drawEdgesForPick
{
	// Draw the edges
	
	glLineWidth( 2.0f );
	
	for( TFace* F in faces )
	{
		for( TEdge* G in F->edges )
		{
			[G pushPickName];
			
			glBegin( GL_LINES );
			{
				TVec3D* v0 = [F->verts objectAtIndex:G->verts[0]];
				TVec3D* v1 = [F->verts objectAtIndex:G->verts[1]];
				
				glVertex3fv( &v0->x );
				glVertex3fv( &v1->x );
			}
			glEnd();
			
			glPopName();
		}
	}

	glLineWidth( 1.0f );
}

-(void) drawVertsForPick
{
	// Draw the vertices
	
	for( TFace* F in faces )
	{
		for( TVec3D* V in F->verts )
		{
			[V pushPickName];
			
			glBegin( GL_POINTS );
			{
				glVertex3fv( &V->x );
			}
			glEnd();
			
			glPopName();
		}
	}
}

-(void) drawOrthoSelectionHighlights:(MAPDocument*)InMAP
{
	// Draws the outline of the brush in bold white
	
	glLineWidth( 2.0 );
	[self drawHighlightedOutline:InMAP Color:[TGlobal G]->colorMedGray];
	glLineWidth( 1.0 );

	[self drawVerts:[TGlobal G]->colorMedGray MAP:InMAP];
	
	// Selected edges
	
	glDepthFunc( GL_ALWAYS );
	glLineWidth( 2.0f );
	glDisable( GL_TEXTURE_2D );
	
	glColor3f( 1, 1, 1 );
	
	glBegin( GL_LINES );
	{
		for( TFace* F in faces )
		{
			for( TEdge* G in F->edges )
			{
				TVec3D* v0 = [F->verts objectAtIndex:G->verts[0]];
				TVec3D* v1 = [F->verts objectAtIndex:G->verts[1]];
				
				if( [InMAP->selMgr isSelected:v0] && [InMAP->selMgr isSelected:v1] )
				{
					glVertex3fv( &v0->x );
					glVertex3fv( &v1->x );
				}
			}
		}
	}
	
	glEnd();

	glEnable( GL_TEXTURE_2D );
	glLineWidth( 1.0f );
	glDepthFunc( GL_LEQUAL );
}

-(void) drawHighlightedOutline:(MAPDocument*)InMAP Color:(TVec3D*)InColor
{
	glDisable( GL_TEXTURE_2D );
	glPolygonMode( GL_FRONT_AND_BACK, GL_LINE );
	
	glColor3fv( &InColor->x );
	
	for( TFace* F in faces )
	{
		glBegin( GL_LINE_LOOP );
		{
			for( TVec3D* V in F->verts )
			{
				glVertex3fv( &V->x );
			}
		}
		glEnd();
	}
	
	glPolygonMode( GL_FRONT_AND_BACK, GL_FILL );
	glEnable( GL_TEXTURE_2D );
}

-(void) drawFlatFaces:(MAPDocument*)InMAP Color:(TVec3D*)InColor
{
	glDisable( GL_TEXTURE_2D );
	
	glColor4f( InColor->x, InColor->y, InColor->z, 0.05f );
	
	for( TFace* F in faces )
	{
		glBegin( GL_TRIANGLE_FAN );
		{
			for( TVec3D* V in F->verts )
			{
				glVertex3fv( &V->x );
			}
		}
		glEnd();
	}
	
	glEnable( GL_TEXTURE_2D );
}

// A static function that will take a set of planes and create a convex brush from them.

+(TBrush*) createBrushFromPlanes:(NSMutableArray*)InClippingPlanes MAP:(MAPDocument*)InMAP
{
	TBrushBuilderCube* bb = [TBrushBuilderCube new];
	
	TBrush* hugeBrush = [bb build:InMAP Location:[TVec3D new] Extents:[TGlobal G]->worldExtents Args:nil];
	
	for( TPlane* P in InClippingPlanes )
	{
		hugeBrush = [hugeBrush carveBrushAgainstPlane:P MAP:nil];
	}
	
	// If a MAP document has been provided, do texture alignment before returning
	
	if( InMAP != nil )
	{
		[hugeBrush generateTexCoords:InMAP];
	}
	
	return hugeBrush;
}

// Carves this brush against InPlane.  Returns a new brush representing whatever is behind InPlane.

-(TBrush*) carveBrushAgainstPlane:(TPlane*)InPlane MAP:(MAPDocument*)InMAP
{
	TBrush* clippedBrush = [TBrush new];
	
	BOOL bBrushWasClipped = NO;
	
	for( TFace* F in faces )
	{
		TFace *front = nil, *back = nil;
		int res = [F splitWithPlane:InPlane Front:&front Back:&back];
		
		switch( res )
		{
			case TFS_Split:
			{
				back->textureName = [F->textureName mutableCopy];
				[clippedBrush->faces addObject:back];
				bBrushWasClipped = YES;
			}
			break;
				
			case TFS_Back:
			{
				[clippedBrush->faces addObject:[F mutableCopy]];
			}
			break;
		}
	}
		
	TBrush* srcBrush = [clippedBrush mutableCopy];
	
	if( bBrushWasClipped )
	{
		// Now that we've clipped the brush against a plane, we need to create a giant face to cover the new hole
		
		TFace* capface = [InPlane getHugePolygon];
		
		// That giant face now needs to be clipped against the remaining faces in the brush (which are converted into planes for the clipping operation)
		
		for( TFace* F in srcBrush->faces )
		{
			TPlane* planeFromFace = [[TPlane alloc] initFromTriangleA:[F->verts objectAtIndex:2] B:[F->verts objectAtIndex:1] C:[F->verts objectAtIndex:0]];
			TFace *front = nil, *back = nil;
			
			if( [capface splitWithPlane:planeFromFace Front:&front Back:&back] == TFS_Split )
			{
				capface = [back mutableCopy];

				// If the cap still doesn't have a texture at this point, take it from the first
				// face that gets split.
				
				if( [capface->textureName length] == 0 )
				{
					[capface copyTexturingAttribsFrom:F];
				}
			}
		}
		
		[srcBrush->faces addObject:capface];
	}
	
	// If a MAP document has been provided, do texture alignment before returning
	
	if( InMAP != nil )
	{
		[srcBrush generateTexCoords:InMAP];
	}
	
	return srcBrush;
}

// Returns a string that represents this entity in Quake MAP text format.  This is the
// same text that would be read or written to a MAP file.

-(NSMutableString*) exportToText
{
	NSMutableString* string = [NSMutableString string];
	
	[string appendString:@"\t{\n"];
	
	[string appendString:@"\t// TAGS"];
	if( quickGroupID > -1 )
	{
		[string appendString:[NSString stringWithFormat:@" QG:%d", quickGroupID]];
	}
	if( bTemporaryBrush )
	{
		[string appendString:@" TB:1"];
	}
	[string appendString:@"\n"];

	for( TFace* F in faces )
	{
		TVec3D *v0, *v1, *v2;

		v2 = [[F->verts objectAtIndex:0] swizzleToQuake];
		v1 = [[F->verts objectAtIndex:1] swizzleToQuake];
		v0 = [[F->verts objectAtIndex:2] swizzleToQuake];

		[string appendFormat:@"\t\t( %d %d %d ) ( %d %d %d ) ( %d %d %d ) %@ %d %d %d %f %f\n",
		 (int)roundf(v0->x), (int)roundf(v0->y), (int)roundf(v0->z),
		 (int)roundf(v1->x), (int)roundf(v1->y), (int)roundf(v1->z),
		 (int)roundf(v2->x), (int)roundf(v2->y), (int)roundf(v2->z),
		 F->textureName,
		 (int)F->uoffset, (int)F->voffset, (int)F->rotation, F->uscale, F->vscale];
		
		[v0 swizzleFromQuake];
		[v1 swizzleFromQuake];
		[v2 swizzleFromQuake];
	}
	
	[string appendString:@"\t}\n"];
	
	return string;
}

-(void) dragBy:(TVec3D*)InOffset MAP:(MAPDocument*)InMAP
{
	for( TFace* F in faces )
	{
		for( TVec3D* V in F->verts )
		{
			V->x += InOffset->x;
			V->y += InOffset->y;
			V->z += InOffset->z;
		}
		
		[F maintainTextureLockAfterDrag:InOffset];
	}
			
	[self generateTexCoords:InMAP];
}

-(TVec3D*) getCenter
{
	return [[self getBoundingBox] getCenter];
}

-(TVec3D*) getExtents
{
	return [[self getBoundingBox] getExtents];
}

-(TBBox*) getBoundingBox
{
	TBBox* bbox = [TBBox new];
	
	for( TFace* F in faces )
	{
		for( TVec3D* V in F->verts )
		{
			[bbox addVertex:V];
		}
	}
	
	return bbox;
}

-(NSMutableArray*) getVertsNear:(TVec3D*)InVert
{
	NSMutableArray* verts = [NSMutableArray new];
	
	for( TFace* F in faces )
	{
		for( TVec3D* V in F->verts )
		{
			if( [V isAlmostEqualTo:InVert] )
			{
				[verts addObject:V];
			}
		}
	}
	
	return verts;
}

-(void) selectVertsNear:(TVec3D*)InVert MAP:(MAPDocument*)InMAP
{
	NSMutableArray* verts = [self getVertsNear:InVert];
	
	for( TVec3D* V in verts )
	{
		[InMAP->selMgr addSelection:V];
	}
}

-(BOOL) doesPlaneIntersect:(TPlane*)InPlane
{
	ESide side;
	int front, back;
	
	front = back = 0;
	
	for( TFace* F in faces )
	{
		for( TVec3D* V in F->verts )
		{
			side = [InPlane getVertexSide:V];
			
			if( side == S_Behind )
			{
				back++;
			}
			else
			{
				front++;
			}
			
			if( front && back )
			{
				return YES;
			}
		}
	}
	
	return NO;
}

-(BOOL) doesFaceIntersect:(TFace*)InFace
{
	TPlane* plane = [[TPlane alloc] initFromTriangleA:[InFace->verts objectAtIndex:0] B:[InFace->verts objectAtIndex:1] C:[InFace->verts objectAtIndex:2]];
	
	return [self doesPlaneIntersect:plane];
}

-(BOOL) isBehindOrOn:(TPlane*)InPlane
{
	ESide side;
	
	for( TFace* F in faces )
	{
		for( TVec3D* V in F->verts )
		{
			side = [InPlane getVertexSide:V];
			
			if( side == S_Front )
			{
				return NO;
			}
		}
	}
	
	return YES;
}

-(BOOL) doesBrushIntersect:(TBrush*)InBrush
{
	NSMutableArray* planes = [NSMutableArray new];
	
	for( TFace* F in faces )
	{
		[planes addObject:[[TPlane alloc] initFromTriangleA:[F->verts objectAtIndex:2] B:[F->verts objectAtIndex:1] C:[F->verts objectAtIndex:0]]];
	}
	
	TBrush* remainderBrush = [InBrush mutableCopy];
	
	for( TPlane* P in planes )
	{
		remainderBrush = [remainderBrush carveBrushAgainstPlane:P MAP:nil];
		
		if( [remainderBrush->faces count] < 3 )
		{
			return NO;
		}
	}
	
	return YES;
}

-(TVec3D*) getVertexNormal:(TVec3D*)InVtx
{
	TVec3D* vtxNormal = [TVec3D new];
	int count = 0;
	
	for( TFace* F in faces )
	{
		for( TVec3D* V in F->verts )
		{
			if( [V isAlmostEqualTo:InVtx] )
			{
				count++;
				vtxNormal = [TVec3D addA:vtxNormal andB:F->normal->normal];
			}
		}
	}
	
	if( count == 0 )
	{
		return [TVec3D new];
	}
	
	return [[TVec3D scale:vtxNormal By:(1.0f / count)] normalize];
}

-(NSMutableArray*) getFacesConnectedToVertex:(TVec3D*)InVtx
{
	NSMutableArray* connectedFaces = [NSMutableArray new];
	
	for( TFace* F in faces )
	{
		for( TVec3D* V in F->verts )
		{
			if( [V isAlmostEqualTo:InVtx] )
			{
				[connectedFaces addObject:F];
			}
		}
	}
	
	return connectedFaces;
}

-(NSMutableArray*) getUniqueSelectedEdges:(MAPDocument*)InMAP
{
	NSMutableArray* uniqueEdges = [NSMutableArray new];
	
	for( TFace* F in faces )
	{
		for( TEdge* G in F->edges )
		{
			if( [G isSelected:InMAP] )
			{
				BOOL bAlreadyInArray = NO;
				
				for( TEdge* GG in uniqueEdges )
				{
					if( [GG isEqual:G] )
					{
						bAlreadyInArray = YES;
					}
				}
				
				if( bAlreadyInArray == NO )
				{
					[uniqueEdges addObject:G];
				}
			}
		}
	}
	
	return uniqueEdges;
}

-(void) finalizeInternals
{
	[faces sortUsingSelector:@selector(compareByTextureName:)];
	
	for( TFace* F in faces )
	{
		[F finalizeInternals];
	}
}

// Clears out all pick names for this brush, including faces and verts.

-(void) clearPickNames
{
	pickName = nil;
	
	for( TFace* F in faces )
	{
		F->pickName = nil;
		
		for( TVec3D* V in F->verts )
		{
			V->pickName = nil;
		}
	}
}

-(void) snapToUnitGrid
{
	for( TFace* F in faces )
	{
		for( TVec3D* V in F->verts )
		{
			V->x = (int)roundf( V->x );
			V->y = (int)roundf( V->y );
			V->z = (int)roundf( V->z );
		}
	}
	
	[self finalizeInternals];
}

-(TFace*) findFaceWithMatchingEdge:(TEdge*)InEdge IgnoreFace:(TFace*)InIgnoreFace
{
	for( TFace* F in faces )
	{
		if( F != InIgnoreFace )
		{
			for( TEdge* E in F->edges )
			{
				if( [E isEqual:InEdge] )
				{
					return F;
				}
			}
		}
	}
	
	return nil;
}

// Looks at the current set of faces and tests to see if this brush is convex or not

-(BOOL) isConvex
{
	for( TFace* F in faces )
	{
		if( [self doesFaceIntersect:F] == YES )
		{
			return NO;
		}
	}
	
	return YES;
}

@end
