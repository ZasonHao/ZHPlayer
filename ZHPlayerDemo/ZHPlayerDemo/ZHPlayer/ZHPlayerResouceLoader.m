//
//  ZHPlayerResouceLoader.m
//
//  Created by Zason Hao.
//

#import "ZHPlayerResouceLoader.h"

@interface ZHPlayerResouceLoader () {
    
}

@end
@implementation ZHPlayerResouceLoader


- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSLog(@"loadingRequest:%@\nloadingRequest.dataRequest:%lld\n%lld\n%ld",loadingRequest.request.URL,loadingRequest.dataRequest.requestedOffset,loadingRequest.dataRequest.currentOffset,loadingRequest.dataRequest.requestedLength);
    
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    //AVAssetResourceLoaderDelegate,AVAssetDownloadDelegate>
}

@end
