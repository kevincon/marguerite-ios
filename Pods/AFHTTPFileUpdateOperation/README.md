AFHTTPFileUpdateOperation
=========================

AFNetworking extenstion for updating file with HTTP header "If-Modified-Since" and status code 304.

This operation checks whether file exists, gets last modification date and send this date to the server. If the file is up-to-date, then operation recieves 304 status code and load from local.

All of this is working when server understands "If-Modifed-Since" HTTP header and you are not touching to the file, so the last modification date is synchronized with server. Excellent example is updating images.

# Example

```objective-c
NSURLRequest * request = // some request
NSString * localPath = // path where the file is located or should be if is not created
AFHTTPFileUpdateOperation * op = [[AFHTTPFileUpdateOperation alloc] initWithRequest:request localPath:localPath];
[op setCompletionBlockWithSuccess:^(AFHTTPFileUpdateOperation *operation, NSData * data) 
{
	// using updated data
}
failure:^(AFHTTPFileUpdateOperation *operation, NSError *error)
{
	// Error handling
}];
```


# CocoaPods is of course supported.
	
    pod 'AFHTTPFileUpdateOperation'
    
# License

The MIT License (MIT)

Copyright (c) 2013 Roman Kříž

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.