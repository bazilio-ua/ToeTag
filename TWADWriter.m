
@implementation TWADWriter

-(void) saveFile:(NSString*)InFilename Map:(MAPDocument*)InMap
{
	LOG( @"Writing WAD : %@", InFilename );
	
	[self openFile:InFilename];
	
	NSMutableArray* textures = [InMap getTexturesForWritingToWAD];

	// Create and fill out the header
	
	wadhead_t* __strong wadHeader = (wadhead_t* __strong)NSAllocateCollectable( sizeof(wadhead_t), NSScannedOption );
	
	wadHeader->magic[0] = 'W';
	wadHeader->magic[1] = 'A';
	wadHeader->magic[2] = 'D';
	wadHeader->magic[3] = '2';
	
	wadHeader->numentries = [textures count];
	wadHeader->diroffset = sizeof(wadhead_t);

	for( TTexture* T in textures )
	{
		int sz = T->width * T->height;
		wadHeader->diroffset += sizeof(miptexheader_t) + sz + (sz / 2) + (sz / 4) + (sz / 8);
	}
		
	// Write the header
	
	SWAPINT32( wadHeader->diroffset );
	SWAPINT32( wadHeader->numentries );
	
	[fileHandle writeData:[NSData dataWithBytes:wadHeader length:sizeof(wadhead_t)]];
	
	SWAPINT32( wadHeader->diroffset );
	SWAPINT32( wadHeader->numentries );
	
	wadentry_t* WADEntries = (wadentry_t*)malloc( sizeof(wadentry_t) * wadHeader->numentries );
	
	// Now that the miptex structures have been created for every texture we are writing out, write that data to the disk.
	
	wadentry_t* WE = WADEntries;
	long filepos = sizeof( wadhead_t );
	miptexheader_t* __strong miptexHeader = (miptexheader_t* __strong)NSAllocateCollectable( sizeof(miptexheader_t), NSScannedOption );
	
	for( TTexture* T in textures )
	{
		int sz = T->width * T->height;
		WE->filepos = filepos;
		WE->dsize = WE->size = sizeof(miptexheader_t) + sz + (sz / 2) + (sz / 4) + (sz / 8);
		WE->type = 68;		// texture
		strcpy( WE->name, [T->name UTF8String] );
		
		strcpy( miptexHeader->name, [T->name UTF8String] );
		miptexHeader->width = T->width;
		miptexHeader->height = T->height;
		
		miptexHeader->offsets[0] = sizeof( miptexheader_t );
		miptexHeader->offsets[1] = miptexHeader->offsets[0] + (sz / 1);
		miptexHeader->offsets[2] = miptexHeader->offsets[1] + (sz / 2);
		miptexHeader->offsets[3] = miptexHeader->offsets[2] + (sz / 4);
		
		[fileHandle writeData:[NSData dataWithBytes:miptexHeader length:sizeof(miptexheader_t)]];
		
		[fileHandle writeData:[NSData dataWithBytes:T->RGBBytesMips[0] length:sz / 1]];
		[fileHandle writeData:[NSData dataWithBytes:T->RGBBytesMips[1] length:sz / 2]];
		[fileHandle writeData:[NSData dataWithBytes:T->RGBBytesMips[2] length:sz / 4]];
		[fileHandle writeData:[NSData dataWithBytes:T->RGBBytesMips[3] length:sz / 8]];
		
		SWAPINT32( WE->dsize );
		SWAPINT32( WE->filepos );
		SWAPINT32( WE->size );
		
		filepos += WE->dsize;
		WE += sizeof(wadentry_t);
	}
	
	// Write out the directory entries
	
	[fileHandle writeData:[NSData dataWithBytes:WADEntries length:sizeof( wadentry_t ) * wadHeader->numentries]];
	
	[fileHandle closeFile];
	
	free( WADEntries );
	
	LOG( @"WAD Written successfully" );
}

@end
