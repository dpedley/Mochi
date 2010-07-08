//
//  MochiResource.h
//
//  Created by Doug Pedley on 07/07/10.
//

#import <Foundation/Foundation.h>

#define MOCHIRESOURCE_HTTPMETHOD_KEY @"HTTPMETHOD"

@class MochiResource;

// parseResponse returns an NSArray or NSDictionary
@protocol MochiResourceDelegate

-(id)mochiResource:(MochiResource *)mochiResource parseResponse:(NSData *)responseData;
-(Class)mochiResourceResponseClass:(MochiResource *)mochiResource;
-(void)mochiResource:(MochiResource *)mochiResource coreData:(id)data;

@end


@interface MochiResource : NSObject 
{
	id<MochiResourceDelegate> delegate;
	NSURL *resourceURL;
	NSDictionary *resourceParameters;
	NSURLConnection *resourceConnection;
	NSMutableData *resourceData;
}
@property (nonatomic, readonly) NSURL *resourceURL;
@property (nonatomic, readonly) NSDictionary *resourceParameters;
@property (nonatomic, readonly) NSURLConnection *resourceConnection;
@property (nonatomic, readonly) NSMutableData *resourceData;

-(id)initWithResourceURL:(NSString *)remoteURLString withParameters:(NSDictionary *)params remoteDelegate:(id<MochiResourceDelegate>)remoteDelegate;
-(void)requestResourceFromRemoteConnection;
	
@end
