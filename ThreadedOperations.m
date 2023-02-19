
@implementation NSOperationCreateBrushFromPlanes

-(id) initWithMap:(MAPDocument*)InMap ClipPlanes:(NSMutableArray*)InClipPlanes quickGroupID:(int)InQuickGroupID Entity:(TEntity*)InEntity SelectAfterImport:(BOOL)InSelectAfterImport
{
	[super init];
	
	map = InMap;
	clipPlanes = InClipPlanes;
	entity = InEntity;
	bSelectAfterImport = InSelectAfterImport;
	quickGroupID = InQuickGroupID;
	
	return self;
}

-(void) main
{
	TBrush* brush = [TBrush createBrushFromPlanes:clipPlanes MAP:map];
	
	[entity->brushes addObject:brush];
	[map->historyMgr addAction:[[THistoryAction alloc] initWithType:TUAT_AddBrush Object:brush Owner:entity]];
	
	brush->quickGroupID = quickGroupID;
	
	if( bSelectAfterImport == YES )
	{
		[map->selMgr addSelection:brush];
	}
}

@end

// ------------------------------------------------------

@implementation NSOperationLoadTextureFromWAD 

-(id) initWithMipTex:(miptexheader_t*)InMipTex FilePos:(byte*)InFilePos Map:(MAPDocument*)InMap Texture:(TTexture*)InTexture
{
	[super init];
	
	mipTex = InMipTex;
	filepos = InFilePos;
	map = InMap;
	texture = InTexture;
	
	return self;
}

-(void) main
{
	int sz, x, pidx, mip, pow2;
	byte R, G, B;
	
	if( texture->bHasMipMaps == YES )
	{
		pow2 = 1;
		for( mip = 0 ; mip < 4 ; ++mip )
		{
			byte* palidx = ((byte*)mipTex) + mipTex->offsets[mip];
			byte* RGBp = texture->RGBBytesMips[mip];
			
			sz = (texture->width * texture->height) / pow2;
			
			for( x = 0 ; x < sz ; ++x )
			{
				pidx = palidx[x] * 3;
				R = [TGlobal G]->palette[ pidx ];
				G = [TGlobal G]->palette[ pidx+1 ];
				B = [TGlobal G]->palette[ pidx+2 ];
				
				*RGBp = R;	RGBp++;
				*RGBp = G;	RGBp++;
				*RGBp = B;	RGBp++;
			}
			
			pow2 *= 2;
		}
	}
	else
	{
		byte* palidx = filepos + mipTex->offsets[0];
		byte* RGBp = texture->RGBBytesMips[0];
		
		sz = texture->width * texture->height;
		
		for( x = 0 ; x < sz ; ++x )
		{
			pidx = palidx[x] * 3;
			R = [TGlobal G]->palette[ pidx ];
			G = [TGlobal G]->palette[ pidx+1 ];
			B = [TGlobal G]->palette[ pidx+2 ];
			
			*RGBp = R;	RGBp++;
			*RGBp = G;	RGBp++;
			*RGBp = B;	RGBp++;
		}
	}
}

@end

// ------------------------------------------------------

@implementation NSOperationLoadMDLIntoECRC

-(id) initWithECRC:(TEntityClassRenderComponentMDL*)InECRC TOCEntry:(TMDLTocEntry*)InTOCEntry
{
	[super init];
	
	ECRC = InECRC;
	TOCEntry = InTOCEntry;
	
	return self;
}

-(void) main
{
	TPAKReader* reader = [TPAKReader new];
	ECRC->model = [reader loadMDL:TOCEntry->PAKFilename Offset:TOCEntry->offset Size:TOCEntry->sz];
	[ECRC->model finalizeInternals];
}

@end

// ------------------------------------------------------

/*
@implementation NSOperationGenerateMipMaps

-(id) initWithTexture:(TTexture*)InTexture
{
	[super init];
	
	texture = InTexture;
	
	return self;
}

-(void) main
{
	NSLog( @"Starting : %@", texture->name );
	
	byte* rgbData = texture->RGBBytesMips[0];
	
	strcpy( texture->miptexData->name, [texture->name UTF8String] );
	texture->miptexData->width = texture->width;
	texture->miptexData->height = texture->height;
	
	texture->miptexData->offsets[0] = sizeof( miptexheader_t );
	texture->miptexData->offsets[1] = texture->miptexData->offsets[0] + (texture->width * texture->height);
	texture->miptexData->offsets[2] = texture->miptexData->offsets[1] + ((texture->width / 2) * (texture->height / 2));
	texture->miptexData->offsets[3] = texture->miptexData->offsets[2] + ((texture->width / 4) * (texture->height / 4));
	
	int x;
	int step = 1;
	byte *mip = (byte*)texture->miptexData;
	
	for( x = 0 ; x < 4 ; ++x )
	{
		int w, h;
		for( h = 0 ; h < texture->height ; h += step )
		{
			for( w = 0 ; w < texture->width ; w += step )
			{
				int r, g, b, count, ww, hh;
				
				r = g = b = count = 0;
				
				// TODO: try keeping the brightest pixel instead of averaging them all together and see what that looks like.  might be interesting
				for( hh = h ; hh < h + step ; ++hh )
				{
					for( ww = w ; ww < w + step ; ++ww )
					{
						int idx = ((hh * texture->width) + ww) * 3;
						
						byte* rgb = rgbData + idx;
						r += *rgb;
						g += *(rgb + 1);
						b += *(rgb + 2);
						
						count++;
					}
				}
				
				r /= (float)count;
				g /= (float)count;
				b /= (float)count;
				
				byte palIdx = [[TGlobal G] getBestPaletteIndexForR:r G:g B:b];
				
				*mip = palIdx;
				mip++;
			}
		}
		
		step *= 2;
	}
	
	SWAPINT32( texture->miptexData->height );
	SWAPINT32( texture->miptexData->width );
	SWAPINT32( texture->miptexData->offsets[0] );
	SWAPINT32( texture->miptexData->offsets[1] );
	SWAPINT32( texture->miptexData->offsets[2] );
	SWAPINT32( texture->miptexData->offsets[3] );

	NSLog( @"Finished : %@", texture->name );
}

@end
*/

