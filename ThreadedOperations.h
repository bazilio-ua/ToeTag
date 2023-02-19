
@interface NSOperationCreateBrushFromPlanes : NSOperation
{
	MAPDocument* map;
	NSMutableArray* clipPlanes;
	TEntity* entity;
	BOOL bSelectAfterImport;
	int quickGroupID;
}

-(id) initWithMap:(MAPDocument*)InMap ClipPlanes:(NSMutableArray*)InClipPlanes quickGroupID:(int)InQuickGroupID Entity:(TEntity*)InEntity SelectAfterImport:(BOOL)InSelectAfterImport;

@end

// ------------------------------------------------------

@interface NSOperationLoadTextureFromWAD : NSOperation
{
	miptexheader_t* mipTex;
	byte* filepos;
	MAPDocument* map;
	TTexture* texture;
}

-(id) initWithMipTex:(miptexheader_t*)InMipTex FilePos:(byte*)InFilePos Map:(MAPDocument*)InMap Texture:(TTexture*)InTexture;

@end

// ------------------------------------------------------

@interface NSOperationLoadMDLIntoECRC : NSOperation
{
	TEntityClassRenderComponentMDL* ECRC;
	TMDLTocEntry* TOCEntry;
}

-(id) initWithECRC:(TEntityClassRenderComponentMDL*)InECRC TOCEntry:(TMDLTocEntry*)InTOCEntry;

@end

// ------------------------------------------------------

// Don't delete this class as we will need to remember how to generate mipmaps when we allow importing of textures

/*
@interface NSOperationGenerateMipMaps : NSOperation
{
	TTexture* texture;
}

-(id) initWithTexture:(TTexture*)InTexture;

@end
*/

// ------------------------------------------------------
