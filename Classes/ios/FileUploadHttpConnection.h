
#import "HTTPConnection.h"

@class MultipartFormDataParser;

@interface FileUploadHttpConnection : HTTPConnection  {
    MultipartFormDataParser*        parser;
	NSFileHandle*					storeFile;
	
	NSMutableArray*					uploadedFiles;
}

+ (void)onFileUploaded:(void(^)(NSString * filePath))completionHandler;

+ (NSString *)localIPAddress;

@end
