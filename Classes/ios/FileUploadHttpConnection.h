
#import "HTTPConnection.h"

@class MultipartFormDataParser;

@interface FileUploadHttpConnection : HTTPConnection  {
    MultipartFormDataParser*        parser;
	NSFileHandle*					storeFile;
	
	NSMutableArray*					uploadedFiles;
}

@property (nonatomic, strong) void (^completionHandler)(NSString * filePath);

+ (NSString *)localIPAddress;

@end
