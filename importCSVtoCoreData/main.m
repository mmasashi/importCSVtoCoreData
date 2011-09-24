//
//  main.m
//  importCSVtoCoreData
//
//  Created by Miyazaki Masashi on 11/09/23.
//  Copyright 2011 mmasashi.jp. All rights reserved.
//

#import "CSVParser.h"

int submain(NSArray *arguments);
void usage(void);
NSString *extractTableName(NSString *filePath);
NSString *stripDoubleQuotation(NSString *src);
NSManagedObject *managedObject(NSManagedObjectContext *context, NSString *entityName);
NSManagedObjectModel *managedObjectModel(NSString *momdPath);
NSManagedObjectContext *managedObjectContext(NSString *sqlitePath, NSString *momdPath);

int main (int argc, const char * argv[])
{

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  // ------------------------------------------------------------

  int ret = submain([[NSProcessInfo processInfo] arguments]);
  
  // ------------------------------------------------------------
  [pool drain];
  return ret;
}


int submain (NSArray *arguments) {
  
  // ---- check arguments
  if ([arguments count] < 4) {
    usage();
    return 1;
  }
  NSString *csvFilePath = [arguments objectAtIndex:1];
  NSString *sqliteFilePath = [arguments objectAtIndex:2];
  NSString *momdPath = [arguments objectAtIndex:3];
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if ([fileManager fileExistsAtPath:csvFilePath] == NO) {
    printf("csvFilePath error %s\n", [csvFilePath cStringUsingEncoding:NSUTF8StringEncoding]);
    usage();
    return 2;
  }
//  if ([fileManager fileExistsAtPath:sqliteFilePath] == NO) {
//    printf("sqliteFilePath error %s\n", [sqliteFilePath cStringUsingEncoding:NSUTF8StringEncoding]);
//    usage();
//    return 3;
//  }
  if ([fileManager fileExistsAtPath:momdPath] == NO) {
    printf("momdPath error %s\n", [momdPath cStringUsingEncoding:NSUTF8StringEncoding]);
    usage();
    return 4;
  }

  // ---- initialize
  
  // read csv file
  NSString *csvLines = nil;
  {
    NSError *error = nil;
    csvLines = [NSString stringWithContentsOfFile:csvFilePath
                                         encoding:NSUTF8StringEncoding
                                            error:&error];
    if (error) {
      printf("Failed to read csv. Error:%s", [[error description] cStringUsingEncoding:NSUTF8StringEncoding]);
      return 5;
    }
  }
  
  // parse csv lines
  CSVParser *csvParser = [[CSVParser alloc] initWithString:csvLines
                                                 separator:@","
                                                 hasHeader:NO
                                                fieldNames:nil];
  NSArray *lineArray = [csvParser arrayOfParsedRows];
  if ([lineArray count] < 3) {
    printf("No csv data...\n");
    return 6;
  }
  
  // get context
  NSManagedObjectContext *context = managedObjectContext(sqliteFilePath, momdPath);
  if (context == nil) {
    return 7;
  }
  
  
  // ---- start to create data
  NSString *entityName = extractTableName(csvFilePath);
  printf("EntityName:%s ", [entityName cStringUsingEncoding:NSUTF8StringEncoding]);
  //NSLog(@"%@", [lineArray description]);
  NSArray *fieldNameArray = [[lineArray objectAtIndex:0] allValues];
  NSArray *fieldTypeArray = [[lineArray objectAtIndex:1] allValues];
  
  for (NSInteger i = 2; i < [lineArray count]; i++) {
    printf(".");
    NSManagedObject *entry = managedObject(context, entityName);
    NSArray *inputArray = [[lineArray objectAtIndex:i] allValues];
    for (NSInteger k = 0; k < [inputArray count]; k++) {
      NSString *targetField = stripDoubleQuotation([fieldNameArray objectAtIndex:k]);
      NSString *fieldType = stripDoubleQuotation([fieldTypeArray objectAtIndex:k]);
      NSString *inputString = stripDoubleQuotation([inputArray objectAtIndex:k]);
      
      id value;
      
      // 0 : string
      if ([fieldType isEqualToString:@"0"]) {
        value = inputString;
        
      // 1 : number
      } else if ([fieldType isEqualToString:@"1"]) {
        value = [NSNumber numberWithInteger:[inputString integerValue]];
      
      // 2 : data
      } else if ([fieldType isEqualToString:@"2"]) {
        value = [inputString dataUsingEncoding:NSUTF8StringEncoding];

      } else {
        value = inputString;
      }
      
      [entry setValue:value forKey:targetField];
    }
  }
  printf("\n");
  
  // Save the managed object context
  
  NSError *error = nil;    
  if (![context save:&error]) {
    NSLog(@"Error while saving %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
    return 8;
  }
  
  printf("Success!! Saved to %d contents. \n", (int)[lineArray count]-2);

  return 0;
}

#pragma mark - 

void usage(void) {
  //printf("Parameter error\n");
  printf("USAGE --\n");
  printf("  importCSVtoCoreData [table-name]_xxxxxx.csv [sqlite-file-name] [xcmodel-name]\n");
  printf("  ex)\n");
  printf("     importCSVtoCoreData Members_mycompany.csv importCSVtoCoreData.sqlite importCSVtoCoreData.momd\n");
}

NSString *extractTableName(NSString *filePath) {
  NSString *fileNameNoExt = [[filePath lastPathComponent] stringByDeletingPathExtension];
  NSRange range = [fileNameNoExt rangeOfString:@"_"];
  if (range.location == NSNotFound) {
    return fileNameNoExt;
  }
  return [fileNameNoExt substringToIndex:range.location];
}

NSString *stripDoubleQuotation(NSString *src) {
  NSString *ret = src;
  
  if ([ret length] < 2) return ret;
  
  if ([ret length] > 2) {
    ret = [ret stringByReplacingOccurrencesOfString:@"\"\""
                                         withString:@"\""];
  }
  
  if ([[ret substringToIndex:1] isEqualToString:@"\""]) {
    ret = [ret substringFromIndex:1];
    return [ret substringToIndex:([ret length] - 1)];
  }
  
  return ret;
}


#pragma mark - CoreData management

NSManagedObject *managedObject(NSManagedObjectContext *context, NSString *entityName) {
  NSManagedObject *entry = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                         inManagedObjectContext:context];
  return entry;
}


NSManagedObjectModel *managedObjectModel(NSString *momdPath) {
    
  static NSManagedObjectModel *model = nil;
    
  if (model != nil) {
      return model;
  }
    
  NSURL *momdUrl = [NSURL fileURLWithPath:momdPath];
  model = [[NSManagedObjectModel alloc] initWithContentsOfURL:momdUrl];
    
  return model;
}

NSManagedObjectContext *managedObjectContext(NSString *sqlitePath,  NSString *momdPath) {

  static NSManagedObjectContext *context = nil;
  if (context != nil) {
      return context;
  }

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];        
  context = [[NSManagedObjectContext alloc] init];
    
  NSPersistentStoreCoordinator *coordinator = 
  [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: managedObjectModel(momdPath)];
  [context setPersistentStoreCoordinator: coordinator];
    
  NSString *STORE_TYPE = NSSQLiteStoreType;
    
  NSString *path = [[[NSProcessInfo processInfo] arguments] objectAtIndex:0];
  path = [path stringByDeletingPathExtension];
  NSURL *url = [NSURL fileURLWithPath:sqlitePath];//[path stringByAppendingPathExtension:@"sqlite"]];
    
  NSError *error;
  NSPersistentStore *newStore = [coordinator 
                                 addPersistentStoreWithType:STORE_TYPE 
                                 configuration:nil URL:url options:nil error:&error];
    
  if (newStore == nil) {
      NSLog(@"Store Configuration Failure %@",
            ([error localizedDescription] != nil) ?
            [error localizedDescription] : @"Unknown Error");
  }
  [pool drain];
  return context;
}

