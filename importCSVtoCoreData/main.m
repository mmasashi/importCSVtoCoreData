//
//  main.m
//  importCSVtoCoreData
//
//  Created by Miyazaki Masashi on 11/09/23.
//  Copyright 2011 mmasashi.jp. All rights reserved.
//

NSManagedObjectModel *managedObjectModel(void);
NSManagedObjectContext *managedObjectContext(void);

int main (int argc, const char * argv[])
{

      NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

      // Create the managed object context
      NSManagedObjectContext *context = managedObjectContext();
      
      // Custom code here...
      // Save the managed object context
      NSError *error = nil;    
      if (![context save:&error]) {
          NSLog(@"Error while saving %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
          [pool drain]; 
          exit(1);
      }
      [pool drain];
    return 0;
}

NSManagedObjectModel *managedObjectModel() {
    
    static NSManagedObjectModel *model = nil;
    
    if (model != nil) {
        return model;
    }
    
    NSString *path = [[[NSProcessInfo processInfo] arguments] objectAtIndex:0];
    path = [path stringByDeletingPathExtension];
    NSURL *modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"momd"]];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return model;
}

NSManagedObjectContext *managedObjectContext() {

    static NSManagedObjectContext *context = nil;
    if (context != nil) {
        return context;
    }

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];        
    context = [[NSManagedObjectContext alloc] init];
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: managedObjectModel()];
    [context setPersistentStoreCoordinator: coordinator];
    
    NSString *STORE_TYPE = NSSQLiteStoreType;
    
    NSString *path = [[[NSProcessInfo processInfo] arguments] objectAtIndex:0];
    path = [path stringByDeletingPathExtension];
    NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"sqlite"]];
    
    NSError *error;
    NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:nil error:&error];
    
    if (newStore == nil) {
        NSLog(@"Store Configuration Failure %@",
              ([error localizedDescription] != nil) ?
              [error localizedDescription] : @"Unknown Error");
    }
    [pool drain];
    return context;
}

