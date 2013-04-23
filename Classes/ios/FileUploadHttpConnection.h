
#import "HTTPConnection.h"

@class MultipartFormDataParser;

@interface FileUploadHttpConnection : HTTPConnection  {
    MultipartFormDataParser*        parser;
	NSFileHandle*					storeFile;
	
	NSMutableArray*					uploadedFiles;
}

+ (void)onFileUploaded:(void(^)(NSString * filePath))completionHandler;
+ (void)onFileUploadProgress:(void(^)(NSString * fileName, float progress))progressHandler;

+ (NSString *)localIPAddress;

@end
