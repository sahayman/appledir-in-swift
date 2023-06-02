//
//  LDAPConnection.m
//  appledir
//
//  Created by Steve Hayman on 2023-06-02.
//

#import <Foundation/Foundation.h>
#import "LDAPConnection.h"
// ObjC stuff until I can figure out how to do this in Swift

LDAP *ld;

int verbose = 1;
static NSMutableDictionary *lookupCache;

@implementation LDAPConnection

- (void) establishConnection
{
    if ( ld == NULL ) {

        if ( verbose ) NSLog(@"Establishing LDAP connection");
        ld = ldap_init("lookup.apple.com", LDAP_PORT);
        // NSLog(@"ldap is: %x", ld);
        
        int result;
        result = ldap_simple_bind_s(ld, NULL, NULL);
        if ( result != LDAP_SUCCESS ) {
            NSLog(@"ldap_simple_bind_s: lookup.apple.com: %s", ldap_err2string(result));
        }
        
       // lookupCache = [NSMutableDictionary dictionary];
    }
    lookupCache = [NSMutableDictionary dictionary];

    
    NSLog(@"LDAP connection ready");
    
}

- (instancetype)init {
    self = [super init];
    [self establishConnection];
    return self;
}

- (NSArray *)peopleForQuery: (NSString *)query searchBase:(NSString *)searchBase
{
    int result;
    LDAPMessage *res = NULL;
    BerElement *berEl;
    NSMutableArray *ma = [NSMutableArray array];
    
    // Keys we want to fetch for each user
    
    if ( lookupCache[query] ) {
        return lookupCache[query];
    }
    [self establishConnection];

    // Try to avoid fetching every possible key. For our purposes we don't need "userCertificate;binary" or "sshPublicKey"
    
    char *attrs[] = {
        "apple-generateduid",
        "appleAIMOfficial",
        "appleAIMPreferred",
        "appleAlternateDSID",
        "appleDSID",
        "appleISTFlag",
        "appleLastName",
        "appleLocation",
        "appleLocationCd",
        "appleManager",
        "appleMapBuildingDN-pict",
        "appleNickName",
        "appleOfficialMobile",
        "applePhoneSearch",
        "applePhotoOfficial-jpeg",
        "applePhotoOfficialThumbnail-jpeg",
        "applePhotoPreferred-jpeg",
        "applePreferredEmail",
        "appleSearchText",
        "appleSystemAccount",
        "appleWebexInfo",
        "buildingName",
        "c",
        "cn",
        "co",
        "departmentNumber",
        "destinationIndicator",
        "dn",
        "employeeType",
        "givenName",
        "jpegPhoto",
        "l",
        "mail",
        "manager",
        "mobile",
        "o",
        "objectClass",
        "ou",
        "postalAddress",
        "postalCode",
        "sn",
        "st",
        "street",
        "telephoneNumber",
        NULL };
        
    //char *attrs[] = {"*", NULL};
    // to get all attributes:
    // char *attrs[] = {NULL};
    
    result = ldap_search_s( ld, [searchBase UTF8String],
                           LDAP_SCOPE_SUBTREE,
                           [query UTF8String],
                           attrs,        // all attributes - instead of 'attrs'
                           0,
                           &res );
    if ( result == -1 ) {
        // try once to reestablish connection
        if ( verbose ) NSLog(@"Reestablishing LDAP connection");
        ld = NULL;
        [[self class] establishConnection];
        result = ldap_search_s( ld, [searchBase UTF8String],
                               LDAP_SCOPE_SUBTREE,
                               [query UTF8String],
                               attrs,        // all attributes - instead of 'attrs'
                               0,
                               &res );

    }
    if (res != 0) {
        LDAPMessage *entry;
        
        for ( entry = ldap_first_entry( ld, res ); entry != NULL; entry = ldap_next_entry(ld, entry) ) {
            NSMutableDictionary *d = [NSMutableDictionary dictionary];
            
            char *attrName;
            for ( attrName = ldap_first_attribute( ld, entry, &berEl );
                 attrName != NULL;
                 attrName = ldap_next_attribute( ld, entry, berEl ) ) {
                
                struct berval **vals;
                int valIndex;
                
                NSString *key = [NSString stringWithUTF8String:attrName];
                
                if(( vals = ldap_get_values_len(   ld, entry, attrName )) != NULL)
                {
                    for( valIndex = 0 ; vals[valIndex] != NULL; valIndex++ ) {
                        //(void)lstrcat( theBuffer, vals[valIndex] );
                        id value;
                        
                        //if ( strcmp(attrName, "applePhotoOfficialThumbnail-jpeg") == 0 ) {
                        if ( strcmp(attrName, "applePhotoOfficial-jpeg") == 0 ) {
                            value = [NSData dataWithBytes:vals[valIndex]->bv_val  length: vals[valIndex]->bv_len];
                            
                        } else {
                            
                            value = [[NSString alloc] initWithBytes:vals[valIndex]->bv_val length:vals[valIndex]->bv_len encoding:NSUTF8StringEncoding];
                        }
                        //[d setObject: value      forKey: key];
                        
                        if ( value ) {
                            // some keys, e.g. appleNickName, may have multiple values
                            if ( [d objectForKey:key]) {
                                id oldVal = [d objectForKey:key];
                                // already an array?
                                if ( [oldVal isKindOfClass:[NSMutableArray class]] ) {
                                    [oldVal addObject:value];
                                } else {
                                    NSMutableArray *a = [NSMutableArray arrayWithObjects:oldVal, value, nil];
                                    [d setObject: a forKey:key];
                                }
                            } else {
                                [d setObject:value forKey:key];
                            }
                        }
                    }
                    
                }
                //ldap_value_free_len( vals );
                
                //ldap_memfree( attrName );
            }
            //if ( berEl != NULL )       ber_free(berEl,0);
            
           // ApplePerson *p = [ApplePerson personWithDictionary:d];
            [ma addObject:d];
            
        }
        
        //    NSLog(@"Returning: %@ from query %@", [ma valueForKeyPath:@"@unionOfObjects.cn"], query);
        
        lookupCache[query] = ma;
        return ma;
        
    } else {
        // FIXME, something with errors, this is totally the wrong place for this
        
        //NSRunAlertPanel(@"Cannot find Apple Directory", @"Gotta be on the Apple Network", @"OK", nil, nil);
        NSString *errorMessage = [NSString stringWithFormat:@"Unable to search the directory service: error %d (%s).", result, ldap_err2string(result)];
        NSLog(@"%@", errorMessage);

//        [[NSNotificationCenter defaultCenter]
//         postNotificationName:LDAPConnectionProblem
//         object:nil
//         userInfo:@{@"message" : errorMessage}];
        
        return nil;
    }
    
    
}


@end
