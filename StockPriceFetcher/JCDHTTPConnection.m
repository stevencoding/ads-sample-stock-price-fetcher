//
//  JCDHTTPConnection.m
//  Created by Justin Driscoll on 11/26/11.
//

#import "JCDHTTPConnection.h"

@implementation JCDHTTPConnection

@synthesize request;
@synthesize response;
@synthesize data;
@synthesize onSuccess;
@synthesize onFailure;
@synthesize onDidSendData;

- (id)initWithRequest:(NSURLRequest *)urlRequest
{
    self = [super init];
    if (self) {
        self.request = urlRequest;
    }
    return self;
}

- (NSString *)body
{
    return [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
}

- (BOOL)executeRequestOnSuccess:(void (^)(NSHTTPURLResponse *, NSString *))onSuccessBlock
                        failure:(void (^)(NSHTTPURLResponse *, NSString *, NSError *))onFailureBlock
                    didSendData:(void (^)(NSInteger, NSInteger, NSInteger))onDidSendDataBlock
{
    self.onSuccess = (id)onSuccessBlock;
    self.onFailure = (id)onFailureBlock;
    self.onDidSendData = (id)onDidSendDataBlock;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
    return connection != nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)aResponse;
    self.response = httpResponse;
    
    self.data = [NSMutableData data];
    [self.data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)bytes
{
    [self.data appendData:bytes];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (self.onFailure)
        self.onFailure(self.response, self.body, error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (self.onSuccess)
        self.onSuccess(self.response, self.body);
}

-(NSCachedURLResponse *)connection:(NSURLConnection *)connection
                 willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
                                               totalBytesWritten:(NSInteger)totalBytesWritten
                                       totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if (self.onDidSendData)
        self.onDidSendData(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
}

@end