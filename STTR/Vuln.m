//
//  ObjC.m
//  STTR
//
//  Created by Logan K on 6/24/21.
//

#import "Vuln.h"

//implements Vuln.h
@implementation Vuln

// function that performs the vulnerable trusting and allowing invalid certificates
- (void) trustCerts{
    AFSecurityPolicy * sec = [[AFSecurityPolicy alloc] init];
    [sec setAllowInvalidCertificates:YES];
}

//function that insecurely downloads a zip file from the server in order to demonstrate a vulnerability
- (void) unsecureDownload{
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager * manager =[[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    AFSecurityPolicy * sec = [[AFSecurityPolicy alloc] init];
    [sec setValidatesDomainName: NO]; //dont validate
    [sec setAllowInvalidCertificates: YES]; //dont check for validity on certificates
    manager.securityPolicy = sec;
    NSURL *URL = [NSURL URLWithString: @"https://sttrwrong.martincarlisle.com/youwontguessthisbhVFFX/supersecretfile.zip"];
    NSURLRequest * request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDownloadTask * downloadTask = [manager downloadTaskWithRequest: request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL * documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory: NSDocumentDirectory inDomain: NSUserDomainMask appropriateForURL: nil create: NO error: nil];
        return [documentsDirectoryURL URLByAppendingPathComponent: [response suggestedFilename]];
    } completionHandler: ^(NSURLResponse *response, NSURL * filePath, NSError * error) {
        NSLog(@"File downloaded to : %@", filePath);
    }];
    
    [downloadTask resume];
}




@end
