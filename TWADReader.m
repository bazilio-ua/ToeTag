
@implementation NSImage (ProportionalScaling)

- (NSImage*)imageByScalingProportionallyToSize:(NSSize)targetSize
{
	NSImage* sourceImage = self;
	NSImage* newImage = nil;
	
	if ([sourceImage isValid])
	{
		NSSize imageSize = [sourceImage size];
		float width  = imageSize.width;
		float height = imageSize.height;
		
		float targetWidth  = targetSize.width;
		float targetHeight = targetSize.height;
		
		float scaledWidth  = targetWidth;
		float scaledHeight = targetHeight;
		
		if ( NSEqualSizes( imageSize, targetSize ) == NO )
		{
			float widthFactor  = targetWidth / width;
			float heightFactor = targetHeight / height;

			scaledWidth  = width  * widthFactor;
			scaledHeight = height * heightFactor;
		}
		
		newImage = [[NSImage alloc] initWithSize:targetSize];
		
		[newImage lockFocus];
		
		NSRect thumbnailRect = NSMakeRect( 0, 0, scaledWidth, scaledHeight );
		
		[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
		
		[sourceImage drawInRect: thumbnailRect
					   fromRect: NSZeroRect
					  operation: NSCompositeSourceOver
					   fraction: 1.0];
		
		[newImage unlockFocus];
		
	}
	
	return newImage;
}

@end

@implementation TWADReader

-(BOOL) loadFile:(NSString*)InFilename Map:(MAPDocument*)InMap
{
	LOG( @"Reading WAD file: %@", InFilename );
	LOG_IN();
	
	[self openFile:InFilename];
	
	if( !fileHandle )
	{
		ERROR( @"Couldn't find WAD file: %@", InFilename );
		LOG_OUT();
		return NO;
	}
	
	NSData* data = [fileHandle readDataToEndOfFile];
	byte* headOfFile = (byte*)[data bytes];
	
	// Read the WAD header
	
	WADHeader = (wadhead_t*)headOfFile;
	
	SWAPINT32( WADHeader->diroffset );
	SWAPINT32( WADHeader->numentries );
	
	// Verify that this is a WAD file
	
	if( WADHeader->magic[0] != 'W' && WADHeader->magic[1] != 'A' && WADHeader->magic[2] != 'D' && WADHeader->magic[3] != '2' )
	{
		[fileHandle closeFile];
		return NO;
	}
	
	// Read the table of contents
	
	WADEntries = (wadentry_t*)(headOfFile + WADHeader->diroffset);
	
	// Read each entry
	
	int e;
	NSOperationQueue* queue = [NSOperationQueue new];
	
	for( e = 0 ; e < WADHeader->numentries ; ++e )
	{
		SWAPINT32( WADEntries[e].filepos );
	
		switch( WADEntries[e].type )
		{
			case 68:		// Texture
			{
				byte* filePos = headOfFile + WADEntries[e].filepos;
				miptexheader_t* miptex = (miptexheader_t*)filePos;
				
				// If a texture by this name is already loaded, skip it.
				
				if( [InMap doesTextureExist:[NSString stringWithCString:miptex->name encoding:NSUTF8StringEncoding]] == YES )
				{
					continue;
				}
				
				SWAPINT32( miptex->height );
				SWAPINT32( miptex->width );
				SWAPINT32( miptex->offsets[0] );
				SWAPINT32( miptex->offsets[1] );
				SWAPINT32( miptex->offsets[2] );
				SWAPINT32( miptex->offsets[3] );
				
				TTexture* T = [TTexture new];
				T->name = [NSString stringWithCString:miptex->name encoding:NSUTF8StringEncoding];
				T->width = miptex->width;
				T->height = miptex->height;
				
				T->bHasMipMaps = YES;
				
				T->RGBBytesMips[0] = NSAllocateCollectable( ((T->width * T->height) * 3) / 1, NSScannedOption );
				T->RGBBytesMips[1] = NSAllocateCollectable( ((T->width * T->height) * 3) / 2, NSScannedOption );
				T->RGBBytesMips[2] = NSAllocateCollectable( ((T->width * T->height) * 3) / 4, NSScannedOption );
				T->RGBBytesMips[3] = NSAllocateCollectable( ((T->width * T->height) * 3) / 8, NSScannedOption );
				
				[InMap->texturesFromWADs addObject:T];
				
				[queue addOperation:[[NSOperationLoadTextureFromWAD alloc] initWithMipTex:miptex FilePos:filePos Map:InMap Texture:T]];
			}
			break;
		}
	}
	
	[queue waitUntilAllOperationsAreFinished];
	
	[self closeFile];
	
	LOG( @"Done loading WAD." );
	LOG_OUT();
	
	return YES;
}

@end
