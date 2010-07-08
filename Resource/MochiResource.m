//
//  MochiResource.m
//
//  Created by Doug Pedley on 07/07/10.
//

#import "MochiResource.h"
#import "JSON.h"
#import "Mochi.h"

@interface NSString (MochiResourceExtensions)
-(NSString *)stringWithURLEncoding;
@end

@implementation NSString (MochiResourceExtensions)

-(NSString *)stringWithURLEncoding 
{
#define TMP_PERCENT_REPLACE	@"|||"
	NSString *ret = [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	ret = [ret stringByReplacingOccurrencesOfString:@"%" withString:TMP_PERCENT_REPLACE];
	ret = [ret stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
	ret = [ret stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
	ret = [ret stringByReplacingOccurrencesOfString:@"$" withString:@"%24"];
	ret = [ret stringByReplacingOccurrencesOfString:@"@" withString:@"%40"];
	ret = [ret stringByReplacingOccurrencesOfString:TMP_PERCENT_REPLACE withString:@"%37"];
	return [NSString stringWithString:ret];
}

@end

@implementation MochiResource

@synthesize resourceURL;
@synthesize resourceParameters;
@synthesize resourceConnection;
@synthesize resourceData;

-(id)initWithResourceURL:(NSString *)remoteURLString withParameters:(NSDictionary *)params remoteDelegate:(id<MochiResourceDelegate>)remoteDelegate
{
	if (self = [super init])
	{
		delegate = remoteDelegate;
		resourceParameters = [[NSDictionary alloc] initWithDictionary:params];
		
		NSMutableString *urlString = [NSMutableString stringWithString:remoteURLString];
		NSMutableDictionary *unusedParams = [NSMutableDictionary dictionaryWithDictionary:params];
		
		if ([unusedParams objectForKey:MOCHIRESOURCE_HTTPMETHOD_KEY]!=nil)
		{
			[unusedParams removeObjectForKey:MOCHIRESOURCE_HTTPMETHOD_KEY];
		}
		
		for (NSString *paramKey in [params allKeys])
		{
			NSString *replaceValue = [(NSString *)[params valueForKey:paramKey] stringWithURLEncoding];
			NSString *replaceKey = [NSString stringWithFormat:@"$%@", paramKey];
			NSUInteger replaceCount = [urlString replaceOccurrencesOfString:replaceKey withString:replaceValue options:NSLiteralSearch range:NSMakeRange(0, [urlString length])];
			if (replaceCount>0)
			{
				[unusedParams removeObjectForKey:paramKey];
			}
		}
		
		NSString *appendParamSeparator=@"?";
		for (NSString *unusedParamKey in [unusedParams allKeys])
		{
			NSString *unusedValue = [unusedParams valueForKey:unusedParamKey];
			NSString *urlString = [urlString stringByAppendingFormat:@"%@%@=%@", appendParamSeparator, unusedParamKey, unusedValue];
			appendParamSeparator=@"&";
		}
		
		
		NSLog(@"%@", urlString);
		
		resourceURL = [[NSURL alloc] initWithString:urlString];
	}
	
	return self;
}

-(void)requestResourceFromRemoteConnection
{
	NSString *method = [resourceParameters objectForKey:MOCHIRESOURCE_HTTPMETHOD_KEY];
	if (method==nil)
	{
		method = @"GET";
	}
	
	NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:resourceURL];
	[req setHTTPMethod:method];
	resourceConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];	
	[req release];
}

-(void)dealloc
{
	[resourceURL release];
	[resourceParameters release];
	[resourceConnection release];
	[resourceData release];
	[super dealloc];
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

-(BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace 
{
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge 
{
	[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"connection:(NSURLConnection *)connection didFailWithError:(NSError *)error \n%@", [error localizedDescription]);
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSLog(@"connection:data");
	if (resourceData==nil) { resourceData = [[NSMutableData alloc] initWithCapacity:2048]; } 
	[resourceData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"conn done...");
	id parsedResponse = [delegate mochiResource:self parseResponse:resourceData];

	Class mochiClass = [delegate mochiResourceResponseClass:self];
	
	if ([(NSObject *)parsedResponse isKindOfClass:[NSDictionary class]])
	{
		id newObject = [mochiClass performSelector:@selector(findOrCreateWithDictionary:) withObject:parsedResponse];
		[delegate mochiResource:self coreData:newObject];
	}
	else if ([(NSObject *)parsedResponse isKindOfClass:[NSArray class]])
	{
		NSArray *responseArray = (NSArray *)parsedResponse;
		NSMutableArray *newObjects = [NSMutableArray arrayWithCapacity:[responseArray count]];
		
		for (NSDictionary *parsedDict in responseArray)
		{
			id newObject = [mochiClass performSelector:@selector(findOrCreateWithDictionary:) withObject:parsedDict];
			[newObjects addObject:newObject];
		}
		[delegate mochiResource:self coreData:newObjects];
	}
}



@end
