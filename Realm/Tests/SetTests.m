////////////////////////////////////////////////////////////////////////////
//
// Copyright 2020 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

#import "RLMTestCase.h"

@implementation DogSetObject
@end

@interface SetTests : RLMTestCase
@end

@implementation SetTests

#pragma mark Unmanaged tests

- (void)testUnmanagedSet {
    SetPropertyObject *setObj = [SetPropertyObject new];
    XCTAssertNotNil(setObj.stringSet);
    [setObj.stringSet addObject:[[StringObject alloc] initWithValue:@[@"string1"]]];
    XCTAssertEqual(setObj.stringSet.count, 1U);
    XCTAssertEqualObjects([setObj.stringSet firstObject].stringCol, @"string1");
    [setObj.stringSet addObjects:@[@"string1", @"string2", @"string3"]]; // should not accept duplicates
    XCTAssertEqual(setObj.stringSet.count, 3U);
    XCTAssertEqualObjects(setObj.stringSet[1], @"string2");
    XCTAssertEqualObjects(setObj.stringSet[2], @"string3");

    NSSet *aSet = [NSSet setWithArray:@[@"string1", @"string4"]];
    [setObj.stringSet addObjects:aSet];
    XCTAssertEqual(setObj.stringSet.count, 4U);

    StringObject *strObj = [[StringObject alloc] initWithValue:@[@"meFirst"]];
    [setObj.stringSet addObject:strObj];
    XCTAssertEqualObjects(setObj.stringSet[0], @"string1");
    XCTAssertEqual(setObj.stringSet.count, 5U);

    XCTAssertThrows([((id)setObj.stringSet) addObject:[[IntObject alloc] initWithValue:@[@123]]]);

    [setObj.stringSet removeLastObject];
    XCTAssertEqual(setObj.stringSet.count, 4U);

    [setObj.stringSet removeObject:strObj];
    XCTAssertEqual(setObj.stringSet.count, 3U);
    XCTAssertEqualObjects(setObj.stringSet[0], @"string1");

    [setObj.stringSet removeAllObjects];
    XCTAssertEqual(setObj.stringSet.count, 0U);
}

- (void)testUnmanagedSetComparison {
    SetPropertyObject *setObj1 = [SetPropertyObject new];
    SetPropertyObject *setObj2 = [SetPropertyObject new];
    StringObject *strObj1 = [[StringObject alloc] initWithValue:@[@"one"]];
    StringObject *strObj2 = [[StringObject alloc] initWithValue:@[@"two"]];
    StringObject *strObj3 = [[StringObject alloc] initWithValue:@[@"three"]];

    [setObj1.stringSet addObjects:@[strObj1, strObj2, strObj3]];
    [setObj2.stringSet addObjects:@[strObj1, strObj2, strObj3]];
    XCTAssertTrue([setObj1.stringSet isEqual:setObj2.stringSet]);

    [setObj1.stringSet addObject:[[StringObject alloc] initWithValue:@[@"four"]]];
    XCTAssertFalse([setObj1.stringSet isEqual:setObj2.stringSet]);
}

- (void)testUnmanagedSetUnion {
    AllPrimitiveSets *setObj1 = [AllPrimitiveSets new];
    AllPrimitiveSets *setObj2 = [AllPrimitiveSets new];
    AllPrimitiveSets *setObj3 = [AllPrimitiveSets new];

    [setObj1.stringObj addObjects:@[@"one", @"two", @"three", @"four", @"five"]];
    [setObj2.stringObj addObjects:@[@"one", @"two", @"three"]];
    [setObj3.stringObj addObjects:@[@"one", @"two", @"three", @"four", @"five"]];

    [setObj1.stringObj unionSet:setObj2.stringObj];

    XCTAssertEqual(setObj1.stringObj.count, 5U);
    XCTAssertTrue([setObj1.stringObj isEqual:setObj3.stringObj]);
}

- (void)testUnmanagedSetIntersect {
    AllPrimitiveSets *setObj1 = [AllPrimitiveSets new];
    AllPrimitiveSets *setObj2 = [AllPrimitiveSets new];
    AllPrimitiveSets *setObj3 = [AllPrimitiveSets new];

    [setObj1.stringObj addObjects:@[@"ten", @"one", @"nine", @"two", @"eight"]];
    [setObj2.stringObj addObjects:@[@"five", @"six", @"seven", @"eight", @"nine"]];
    [setObj3.stringObj addObjects:@[@"nine", @"eight"]];

    [setObj1.stringObj intersectSet:setObj2.stringObj];
    XCTAssertTrue([setObj1.stringObj intersectsSet:setObj2.stringObj]);

    XCTAssertEqual(setObj1.stringObj.count, 2U);
    XCTAssertTrue([setObj1.stringObj isEqual:setObj3.stringObj]);
}

- (void)testUnmanagedSetMinus {
    AllPrimitiveSets *setObj1 = [AllPrimitiveSets new];
    AllPrimitiveSets *setObj2 = [AllPrimitiveSets new];
    AllPrimitiveSets *setObj3 = [AllPrimitiveSets new];

    [setObj1.stringObj addObjects:@[@"ten", @"one", @"nine", @"two", @"eight"]];
    [setObj2.stringObj addObjects:@[@"five", @"six", @"seven", @"eight", @"nine"]];
    [setObj3.stringObj addObjects:@[@"ten", @"one", @"two"]];

    [setObj1.stringObj minusSet:setObj2.stringObj];

    XCTAssertEqual(setObj1.stringObj.count, 3U);
    XCTAssertTrue([setObj1.stringObj isEqual:setObj3.stringObj]);
}

- (void)testUnmanagedSetIsSubsetOfSet {
    AllPrimitiveSets *setObj1 = [AllPrimitiveSets new];
    AllPrimitiveSets *setObj2 = [AllPrimitiveSets new];
    AllPrimitiveSets *setObj3 = [AllPrimitiveSets new];

    [setObj1.stringObj addObjects:@[@"ten", @"one", @"nine", @"two", @"eight"]];
    [setObj2.stringObj addObjects:@[@"five", @"six", @"seven", @"eight", @"nine"]];
    [setObj3.stringObj addObjects:@[@"two", @"one", @"ten"]];

    XCTAssertFalse([setObj1.stringObj isSubsetOfSet:setObj2.stringObj]);
    XCTAssertTrue([setObj3.stringObj isSubsetOfSet:setObj1.stringObj]);
}

- (void)testDeleteObjectInUnmanagedSet {
    SetPropertyObject *set = [[SetPropertyObject alloc] init];
    set.name = @"name";

    StringObject *stringObj1 = [[StringObject alloc] init];
    stringObj1.stringCol = @"a";
    StringObject *stringObj2 = [[StringObject alloc] init];
    stringObj2.stringCol = @"b";
    StringObject *stringObj3 = [[StringObject alloc] init];
    stringObj3.stringCol = @"c";
    [set.stringSet addObject:stringObj1];
    [set.stringSet addObject:stringObj2];
    [set.stringSet addObject:stringObj3];

    IntObject *intObj1 = [[IntObject alloc] init];
    intObj1.intCol = 0;
    IntObject *intObj2 = [[IntObject alloc] init];
    intObj2.intCol = 1;
    IntObject *intObj3 = [[IntObject alloc] init];
    intObj3.intCol = 2;
    [set.intSet addObject:intObj1];
    [set.intSet addObject:intObj2];
    [set.intSet addObject:intObj3];

    XCTAssertEqualObjects(set.stringSet[0], stringObj1, @"Objects should be equal");
    XCTAssertEqualObjects(set.stringSet[1], stringObj2, @"Objects should be equal");
    XCTAssertEqualObjects(set.stringSet[2], stringObj3, @"Objects should be equal");
    XCTAssertEqual(set.stringSet.count, 3U, @"Should have 3 elements in string set");

    XCTAssertEqualObjects(set.intSet[0], intObj1, @"Objects should be equal");
    XCTAssertEqualObjects(set.intSet[1], intObj2, @"Objects should be equal");
    XCTAssertEqualObjects(set.intSet[2], intObj3, @"Objects should be equal");
    XCTAssertEqual(set.intSet.count, 3U, @"Should have 3 elements in int set");

    [set.stringSet removeLastObject];

    XCTAssertEqualObjects(set.stringSet[0], stringObj1, @"Objects should be equal");
    XCTAssertEqualObjects(set.stringSet[1], stringObj2, @"Objects should be equal");
    XCTAssertEqual(set.stringSet.count, 2U, @"Should have 2 elements in string set");

    [set.stringSet removeLastObject];

    XCTAssertEqualObjects(set.stringSet[0], stringObj1, @"Objects should be equal");
    XCTAssertEqual(set.stringSet.count, 1U, @"Should have 1 elements in string set");

    [set.stringSet removeLastObject];

    XCTAssertEqual(set.stringSet.count, 0U, @"Should have 0 elements in string set");

    [set.intSet removeAllObjects];
    XCTAssertEqual(set.intSet.count, 0U, @"Should have 0 elements in int set");
}

- (void)testUnmanagedSetIndexOf {
    AllPrimitiveSets *setObj1 = [AllPrimitiveSets new];
    [setObj1.stringObj addObjects:@[@"ten", @"one", @"nine", @"two", @"eight"]];

    XCTAssertEqual([setObj1.stringObj indexOfObject:@"nonexistent"], NSNotFound);
    XCTAssertEqual([setObj1.stringObj indexOfObject:@"eight"], 4U);

    XCTAssertEqual(([setObj1.stringObj indexOfObjectWhere:@"SELF == %@", @"one"]), 1U);
    XCTAssertEqual(([setObj1.stringObj indexOfObjectWhere:@"SELF == %@", @"nonexistent"]), NSNotFound);

    XCTAssertEqual(([setObj1.stringObj indexOfObjectWhere:@"SELF == 'one'"]), 1U);
    XCTAssertEqual(([setObj1.stringObj indexOfObjectWhere:@"SELF == 'nonexistent'"]), NSNotFound);

    XCTAssertEqual(([setObj1.stringObj indexOfObjectWithPredicate:[NSPredicate predicateWithFormat:@"SELF == %@", @"one"]]), 1U);
    XCTAssertEqual(([setObj1.stringObj indexOfObjectWithPredicate:[NSPredicate predicateWithFormat:@"SELF == %@", @"nonexistent"]]), NSNotFound);
}

- (void)testUnmanagedSetSort {
    AllPrimitiveSets *setObj1 = [AllPrimitiveSets new];
    XCTAssertThrows([setObj1.stringObj sortedResultsUsingKeyPath:@"age" ascending:YES]);
    XCTAssertThrows([setObj1.stringObj sortedResultsUsingDescriptors:@[]]);
    XCTAssertThrows([setObj1.stringObj distinctResultsUsingKeyPaths:@[]]);
}

- (void)testUnmanagedSetObjectAtIndexedSubscript {
    AllPrimitiveSets *setObj1 = [AllPrimitiveSets new];
    [setObj1.stringObj addObjects:@[@"one", @"two", @"three", @"four", @"five"]];
    XCTAssertTrue([[setObj1.stringObj objectAtIndexedSubscript:1] isEqualToString:@"two"]);

    [setObj1.stringObj setObject:@"hello!" atIndexedSubscript:1];
    XCTAssertTrue([[setObj1.stringObj objectAtIndexedSubscript:1] isEqualToString:@"hello!"]);
}

- (void)testSetAggregate {
    SetPropertyObject *setObj = [[SetPropertyObject alloc] initWithValue:@[@"setObject", @[], @[@1, @2, @3, @-1, @0, @0]]];

    XCTAssertEqual(5, [setObj.intSet sumOfProperty:@"intCol"].intValue);
    XCTAssertEqual(1, [setObj.intSet averageOfProperty:@"intCol"].intValue);
    XCTAssertEqual(-1, [[setObj.intSet minOfProperty:@"intCol"] intValue]);
    XCTAssertEqual(3, [[setObj.intSet maxOfProperty:@"intCol"] intValue]);
    XCTAssertThrows([setObj.intSet sumOfProperty:@"prop 1"]);
}

#pragma mark Managed Set

- (void)testPopulateEmptySet {
    RLMRealm *r = [self realmWithTestPath];
    [r beginWriteTransaction];
    SetPropertyObject *setObj1 = [SetPropertyObject new];
    XCTAssertNotNil(setObj1.stringSet, @"Should be able to get an empty set");
    XCTAssertEqual(setObj1.stringSet.count, 0U, @"Should start with no set elements");

    StringObject *str1 = [StringObject createInRealm:r withValue:@[@"a"]];
    StringObject *str2 = [StringObject createInRealm:r withValue:@[@"b"]];
    StringObject *str3 = [StringObject createInRealm:r withValue:@[@"c"]];
    IntObject *int1 = [IntObject createInRealm:r withValue:@[@1]];
    IntObject *int2 = [IntObject createInRealm:r withValue:@[@2]];
    IntObject *int3 = [IntObject createInRealm:r withValue:@[@3]];

    [setObj1.stringSet addObjects:@[str1, str2, str3, str1, str2, str3]];
    [setObj1.intSet addObjects:@[int1, int2, int3, int1, int2, int3]];

    [r addObject:setObj1];
    [r commitWriteTransaction];

    RLMResults<SetPropertyObject *> *results = [SetPropertyObject allObjectsInRealm:r];

    XCTAssertFalse(setObj1.isInvalidated);
    XCTAssertEqual(results.count, 1U);

    XCTAssertEqual(results[0].stringSet.count, 3U);
    XCTAssertEqualObjects(results[0].stringSet, setObj1.stringSet);

    XCTAssertEqual(results[0].intSet.count, 3U);
    XCTAssertEqualObjects(results[0].intSet, setObj1.intSet);

    RLMSet *setProp = setObj1.stringSet;
    RLMAssertThrowsWithReasonMatching([setProp addObject:@"another one"], @"write transaction");

    // make sure we can fast enumerate
    for (RLMObject *obj in setObj1.stringSet) {
        XCTAssertTrue(obj.description.length, @"Object should have description");
    }
}

-(void)testModifyDetatchedSet {
    RLMRealm *realm = [self realmWithTestPath];

    [realm beginWriteTransaction];
    SetPropertyObject *setObj = [SetPropertyObject createInRealm:realm withValue:@[@"setObject", @[], @[]]];
    XCTAssertNotNil(setObj.stringSet, @"Should be able to get an empty set");
    XCTAssertEqual(setObj.stringSet.count, 0U, @"Should start with no set elements");

    StringObject *obj = [[StringObject alloc] init];
    obj.stringCol = @"a";
    RLMSet *set = setObj.stringSet;
    [set addObject:obj];
    [set addObject:[StringObject createInRealm:realm withValue:@[@"b"]]];
    [realm commitWriteTransaction];

    XCTAssertEqual(set.count, 2U, @"Should have two elements in set");
    XCTAssertEqualObjects([set[0] stringCol], @"a", @"First element should have property value 'a'");
    XCTAssertEqualObjects([setObj.stringSet[1] stringCol], @"b", @"Second element should have property value 'b'");

    RLMAssertThrowsWithReasonMatching([set addObject:obj], @"write transaction");
}

- (void)testDeleteUnmanagedObjectWithSetProperty {
    AllPrimitiveSets *setObj = [AllPrimitiveSets new];
    [setObj.stringObj addObject:@"a"];
    RLMSet *stringSet = setObj.stringObj;
    XCTAssertFalse(stringSet.isInvalidated, @"stringObj should be valid after creation.");
    setObj = nil;
    XCTAssertFalse(stringSet.isInvalidated, @"stringObj should still be valid after parent deletion.");
}

- (void)testDeleteObjectWithSetProperty {
    RLMRealm *realm = [self realmWithTestPath];

    [realm beginWriteTransaction];
    SetPropertyObject *setObj = [SetPropertyObject createInRealm:realm withValue:@[@"setObject", @[@[@"a"]], @[]]];
    RLMSet *stringSet = setObj.stringSet;
    XCTAssertFalse(stringSet.isInvalidated, @"stringSet should be valid after creation.");
    [realm deleteObject:setObj];
    XCTAssertTrue(stringSet.isInvalidated, @"stringSet should be invalid after parent deletion.");
    [realm commitWriteTransaction];
}

- (void)testDeleteObjectInSetProperty {
    RLMRealm *realm = [self realmWithTestPath];

    [realm beginWriteTransaction];
    SetPropertyObject *setObj = [SetPropertyObject createInRealm:realm withValue:@[@"setObject", @[@[@"a"]], @[]]];
    RLMSet *stringSet = setObj.stringSet;
    StringObject *firstObject = stringSet.firstObject;
    [realm deleteObjects:[StringObject allObjectsInRealm:realm]];
    XCTAssertFalse(stringSet.isInvalidated, @"stringSet should be valid after member object deletion.");
    XCTAssertTrue(firstObject.isInvalidated, @"firstObject should be invalid after deletion.");
    XCTAssertEqual(stringSet.count, 0U, @"stringSet.count should be zero after deleting its only member.");
    [realm commitWriteTransaction];
}

-(void)testInsertMultiple {
    RLMRealm *realm = [self realmWithTestPath];

    [realm beginWriteTransaction];
    SetPropertyObject *obj = [SetPropertyObject createInRealm:realm withValue:@[@"setObject", @[], @[]]];
    StringObject *child1 = [StringObject createInRealm:realm withValue:@[@"a"]];
    StringObject *child2 = [[StringObject alloc] init];
    child2.stringCol = @"b";
    [obj.stringSet addObjects:@[child2, child1]];
    [realm commitWriteTransaction];

    RLMResults *children = [StringObject allObjectsInRealm:realm];
    XCTAssertEqualObjects([children[0] stringCol], @"a", @"First child should be 'a'");
    XCTAssertEqualObjects([children[1] stringCol], @"b", @"Second child should be 'b'");
}

- (void)testAddInvalidated {
    RLMRealm *realm = [RLMRealm defaultRealm];

    [realm beginWriteTransaction];
    CompanyObject *company = [CompanyObject createInDefaultRealmWithValue:@[@"company", @[]]];

    EmployeeObject *person = [[EmployeeObject alloc] init];
    person.name = @"Mary";
    [realm addObject:person];
    [realm deleteObjects:[EmployeeObject allObjects]];

    RLMAssertThrowsWithReasonMatching([company.employeeSet addObject:person], @"invalidated");

    [realm cancelWriteTransaction];
}

- (void)testAddNil {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    CompanyObject *company = [CompanyObject createInDefaultRealmWithValue:@[@"company", @[]]];

    RLMAssertThrowsWithReason([company.employeeSet addObject:self.nonLiteralNil],
                              @"Invalid nil value for set of 'EmployeeObject'.");
    [realm cancelWriteTransaction];
}

- (void)testUnmanaged {
    RLMRealm *realm = [self realmWithTestPath];

    SetPropertyObject *setObj = [[SetPropertyObject alloc] init];
    setObj.name = @"name";
    XCTAssertNotNil(setObj.stringSet, @"RLMSet property should get created on access");

    XCTAssertNil(setObj.stringSet.firstObject, @"No objects added yet");
    XCTAssertNil(setObj.stringSet.lastObject, @"No objects added yet");

    StringObject *obj1 = [[StringObject alloc] init];
    obj1.stringCol = @"a";
    StringObject *obj2 = [[StringObject alloc] init];
    obj2.stringCol = @"b";
    StringObject *obj3 = [[StringObject alloc] init];
    obj3.stringCol = @"c";
    [setObj.stringSet addObject:obj1];
    [setObj.stringSet addObject:obj2];
    [setObj.stringSet addObject:obj3];

    XCTAssertEqualObjects(setObj.stringSet.firstObject, obj1, @"Objects should be equal");
    XCTAssertEqualObjects(setObj.stringSet.lastObject, obj3, @"Objects should be equal");
    XCTAssertEqualObjects([setObj.stringSet objectAtIndex:1], obj2, @"Objects should be equal");

    [realm beginWriteTransaction];
    [realm addObject:setObj];
    [realm commitWriteTransaction];

    XCTAssertEqual(setObj.stringSet.count, 3U, @"Should have two elements in array");
    XCTAssertEqualObjects([setObj.stringSet[0] stringCol], @"a", @"First element should have property value 'a'");
    XCTAssertEqualObjects([setObj.stringSet[1] stringCol], @"b", @"Second element should have property value 'b'");

    [realm beginWriteTransaction];
    setObj.stringSet[0] = obj1;
    // replacing an object by subscript will fail until Core supports Set::set(ndx, etc..)
    // XCTAssertTrue([obj1 isEqualToObject:[setObj.stringSet objectAtIndex:0]], @"Objects should be replaced");

    [setObj.stringSet removeLastObject];
    XCTAssertEqual(setObj.stringSet.count, 2U, @"2 objects left");
    [setObj.stringSet addObject:obj1];
    [setObj.stringSet removeAllObjects];
    XCTAssertEqual(setObj.stringSet.count, 0U, @"All objects removed");
    [realm commitWriteTransaction];

    SetPropertyObject *setObj2 = [[SetPropertyObject alloc] init];
    IntObject *intObj = [[IntObject alloc] init];
    intObj.intCol = 1;
    RLMAssertThrowsWithReasonMatching([setObj2.stringSet addObject:(id)intObj], @"IntObject.*StringObject");
    [setObj2.intSet addObject:intObj];

    XCTAssertThrows([setObj2.intSet objectsWhere:@"intCol == 1"], @"Should throw on unmanaged RLMSet");
    XCTAssertThrows(([setObj2.intSet objectsWithPredicate:[NSPredicate predicateWithFormat:@"intCol == %i", 1]]), @"Should throw on unmanaged RLMSet");
    XCTAssertThrows([setObj2.intSet sortedResultsUsingKeyPath:@"intCol" ascending:YES], @"Should throw on unmanaged RLMSet");

    XCTAssertEqual(0U, [setObj2.intSet indexOfObjectWhere:@"intCol == 1"]);
    XCTAssertEqual(0U, ([setObj2.intSet indexOfObjectWithPredicate:[NSPredicate predicateWithFormat:@"intCol == %i", 1]]));

    XCTAssertEqual([setObj2.intSet indexOfObject:intObj], 0U, @"Should be first element");
    XCTAssertEqual([setObj2.intSet indexOfObject:intObj], 0U, @"Should be first element");

    // test unmanaged with literals
    __unused SetPropertyObject *obj = [[SetPropertyObject alloc] initWithValue:@[@"n", @[], @[[[IntObject alloc] initWithValue: @[@1]]]]];
}

- (void)testUnmanagedComparision {
    RLMRealm *realm = [self realmWithTestPath];

    SetPropertyObject *set = [[SetPropertyObject alloc] init];
    SetPropertyObject *set2 = [[SetPropertyObject alloc] init];

    set.name = @"name";
    set.name = @"name2";
    XCTAssertNotNil(set.stringSet, @"RLMSet property should get created on access");
    XCTAssertNotNil(set2.stringSet, @"RLMSet property should get created on access");
    XCTAssertTrue([set.stringSet isEqual:set2.stringSet], @"Empty sets should be equal");

    XCTAssertNil(set.stringSet.firstObject, @"No objects added yet");
    XCTAssertNil(set2.stringSet.lastObject, @"No objects added yet");

    StringObject *obj1 = [[StringObject alloc] init];
    obj1.stringCol = @"a";
    StringObject *obj2 = [[StringObject alloc] init];
    obj2.stringCol = @"b";
    StringObject *obj3 = [[StringObject alloc] init];
    obj3.stringCol = @"c";
    [set.stringSet addObject:obj1];
    [set.stringSet addObject:obj2];
    [set.stringSet addObject:obj3];

    [set2.stringSet addObject:obj1];
    [set2.stringSet addObject:obj2];
    [set2.stringSet addObject:obj3];

    XCTAssertTrue([set.stringSet isEqual:set2.stringSet], @"Sets should be equal");
    [set2.stringSet removeLastObject];
    XCTAssertFalse([set.stringSet isEqual:set2.stringSet], @"Sets should not be equal");
    [set2.stringSet addObject:obj3];
    XCTAssertTrue([set.stringSet isEqual:set2.stringSet], @"Sets should be equal");

    [realm beginWriteTransaction];
    [realm addObject:set];
    [realm commitWriteTransaction];

    XCTAssertFalse([set.stringSet isEqual:set2.stringSet], @"Comparing a managed set to an unmanaged one should fail");
    XCTAssertFalse([set2.stringSet isEqual:set.stringSet], @"Comparing a managed set to an unmanaged one should fail");
}

- (void)testUnmanagedPrimitive {
    AllPrimitiveSets *obj = [[AllPrimitiveSets alloc] init];
    XCTAssertTrue([obj.intObj isKindOfClass:[RLMSet class]]);
    XCTAssertTrue([obj.floatObj isKindOfClass:[RLMSet class]]);
    XCTAssertTrue([obj.doubleObj isKindOfClass:[RLMSet class]]);
    XCTAssertTrue([obj.boolObj isKindOfClass:[RLMSet class]]);
    XCTAssertTrue([obj.stringObj isKindOfClass:[RLMSet class]]);
    XCTAssertTrue([obj.dataObj isKindOfClass:[RLMSet class]]);
    XCTAssertTrue([obj.dateObj isKindOfClass:[RLMSet class]]);

    [obj.intObj addObject:@1];
    XCTAssertEqualObjects(obj.intObj[0], @1);
    XCTAssertThrows([obj.intObj addObject:@""]);

    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    obj = [AllPrimitiveSets createInRealm:realm withValue:@[@[],@[],@[],@[],@[],@[],@[]]];

    XCTAssertTrue([obj.intObj isKindOfClass:[RLMSet class]]);
    XCTAssertTrue([obj.floatObj isKindOfClass:[RLMSet class]]);
    XCTAssertTrue([obj.doubleObj isKindOfClass:[RLMSet class]]);
    XCTAssertTrue([obj.boolObj isKindOfClass:[RLMSet class]]);
    XCTAssertTrue([obj.stringObj isKindOfClass:[RLMSet class]]);
    XCTAssertTrue([obj.dataObj isKindOfClass:[RLMSet class]]);
    XCTAssertTrue([obj.dateObj isKindOfClass:[RLMSet class]]);

    [obj.intObj addObject:@5];
    XCTAssertEqualObjects(obj.intObj.firstObject, @5);
    [realm cancelWriteTransaction];
}

- (void)testIndexOfObject {
    RLMRealm *realm = [RLMRealm defaultRealm];

    [realm beginWriteTransaction];
    EmployeeObject *po1 = [EmployeeObject createInRealm:realm withValue:@{@"name": @"Joe",  @"age": @40, @"hired": @YES}];
    EmployeeObject *po2 = [EmployeeObject createInRealm:realm withValue:@{@"name": @"John", @"age": @30, @"hired": @NO}];
    EmployeeObject *po3 = [EmployeeObject createInRealm:realm withValue:@{@"name": @"Jill", @"age": @25, @"hired": @YES}];
    EmployeeObject *deleted = [EmployeeObject createInRealm:realm withValue:@{@"name": @"Jill", @"age": @25, @"hired": @YES}];
    EmployeeObject *indirectlyDeleted = [EmployeeObject allObjectsInRealm:realm].lastObject;
    [realm deleteObject:deleted];

    // create company
    CompanyObject *company = [[CompanyObject alloc] init];
    company.name = @"name";

    RLMResults<EmployeeObject *> *objects = [EmployeeObject allObjects];
    [company.employeeSet addObjects:objects];

    [company.employeeSet removeObject:po2];
    XCTAssertEqual(2U, company.employeeSet.count);

    // test unmanaged
    XCTAssertEqual(0U, [company.employeeSet indexOfObject:po1]);
    XCTAssertEqual(1U, [company.employeeSet indexOfObject:po3]);
    XCTAssertEqual((NSUInteger)NSNotFound, [company.employees indexOfObject:po2]);

    // add to realm
    [realm addObject:company];
    [realm commitWriteTransaction];

    // test LinkView RLMSet
    XCTAssertEqual(0U, [company.employeeSet indexOfObject:po1]);
    XCTAssertEqual(1U, [company.employeeSet indexOfObject:po3]);
    XCTAssertEqual((NSUInteger)NSNotFound, [company.employeeSet indexOfObject:po2]);

    // non realm employee
    EmployeeObject *notInRealm = [[EmployeeObject alloc] initWithValue:@[@"NoName", @1, @NO]];
    XCTAssertEqual((NSUInteger)NSNotFound, [company.employeeSet indexOfObject:po2]);

    // invalid object
    XCTAssertThrows([company.employeeSet indexOfObject:(EmployeeObject *)company]);
    RLMAssertThrowsWithReasonMatching([company.employeeSet indexOfObject:deleted], @"invalidated");
    RLMAssertThrowsWithReasonMatching([company.employeeSet indexOfObject:indirectlyDeleted], @"invalidated");

    RLMResults *employees = [company.employeeSet objectsWhere:@"age = %@", @40];
    XCTAssertEqual(0U, [employees indexOfObject:po1]);
    XCTAssertEqual((NSUInteger)NSNotFound, [employees indexOfObject:po3]);
}

- (void)testIndexOfObjectWhere
{
    RLMRealm *realm = [RLMRealm defaultRealm];

    [realm beginWriteTransaction];
    EmployeeObject *po1 = [EmployeeObject createInRealm:realm withValue:@{@"name": @"Joe",  @"age": @40, @"hired": @YES}];
    [EmployeeObject createInRealm:realm withValue:@{@"name": @"John", @"age": @30, @"hired": @NO}];
    EmployeeObject *po3 = [EmployeeObject createInRealm:realm withValue:@{@"name": @"Jill", @"age": @25, @"hired": @YES}];
    EmployeeObject *po4 = [EmployeeObject createInRealm:realm withValue:@{@"name": @"Bill", @"age": @55, @"hired": @YES}];

    // create company
    CompanyObject *company = [[CompanyObject alloc] init];
    company.name = @"name";
    [company.employeeSet addObjects:@[po3, po1, po4]];

    // test unmanaged
    XCTAssertEqual(0U, [company.employeeSet indexOfObjectWhere:@"name = 'Jill'"]);
    XCTAssertEqual(1U, [company.employeeSet indexOfObjectWhere:@"name = 'Joe'"]);
    XCTAssertEqual((NSUInteger)NSNotFound, [company.employeeSet indexOfObjectWhere:@"name = 'John'"]);

    // add to realm
    [realm addObject:company];
    [realm commitWriteTransaction];

    // test LinkView RLMSet
    XCTAssertEqual(0U, [company.employeeSet indexOfObjectWhere:@"name = 'Joe'"]);
    XCTAssertEqual(1U, [company.employeeSet indexOfObjectWhere:@"name = 'Jill'"]);
    XCTAssertEqual((NSUInteger)NSNotFound, [company.employeeSet indexOfObjectWhere:@"name = 'John'"]);

    RLMResults *results = [company.employeeSet objectsWhere:@"age > 30"];
    XCTAssertEqual(0U, [results indexOfObjectWhere:@"name = 'Joe'"]);
    XCTAssertEqual(1U, [results indexOfObjectWhere:@"name = 'Bill'"]);
    XCTAssertEqual((NSUInteger)NSNotFound, [results indexOfObjectWhere:@"name = 'John'"]);
    XCTAssertEqual((NSUInteger)NSNotFound, [results indexOfObjectWhere:@"name = 'Jill'"]);
}

- (void)testFastEnumeration
{
    RLMRealm *realm = self.realmWithTestPath;

    [realm beginWriteTransaction];
    CompanyObject *company = [[CompanyObject alloc] init];
    company.name = @"name";
    [realm addObject:company];
    [realm commitWriteTransaction];

    // enumerate empty set
    for (__unused id obj in company.employeeSet) {
        XCTFail(@"Should be empty");
    }

    [realm beginWriteTransaction];
    for (int i = 0; i < 30; ++i) {
        EmployeeObject *eo = [EmployeeObject createInRealm:realm withValue:@{@"name": @"Joe",  @"age": @40, @"hired": @YES}];
        [company.employeeSet addObject:eo];
    }
    [realm commitWriteTransaction];

    XCTAssertEqual(company.employeeSet.count, 30U);

    __weak id objects[30];
    NSInteger count = 0;
    for (EmployeeObject *e in company.employeeSet) {
        XCTAssertNotNil(e, @"Object is not nil and accessible");
        if (count > 16) {
            // 16 is the size of blocks fast enumeration happens to ask for at
            // the moment, but of course that's just an implementation detail
            // that may change
            XCTAssertNil(objects[count - 16]);
        }
        objects[count++] = e;
    }

    XCTAssertEqual(count, 30, @"should have enumerated 30 objects");

    for (int i = 0; i < count; i++) {
        XCTAssertNil(objects[i], @"Object should have been released");
    }

    @autoreleasepool {
        for (EmployeeObject *e in company.employeeSet) {
            objects[0] = e;
            break;
        }
    }
    XCTAssertNil(objects[0], @"Object should have been released");
}

- (void)testModifyDuringEnumeration {
    RLMRealm *realm = self.realmWithTestPath;

    [realm beginWriteTransaction];
    CompanyObject *company = [[CompanyObject alloc] init];
    company.name = @"name";
    [realm addObject:company];

    const size_t totalCount = 40;
    for (size_t i = 0; i < totalCount; ++i) {
        [company.employeeSet addObject:[EmployeeObject createInRealm:realm withValue:@[@"name", @(i), @NO]]];
    }

    size_t count = 0;
    for (EmployeeObject *eo in company.employeeSet) {
        ++count;
        [company.employeeSet removeObject:eo];
    }
    XCTAssertEqual(totalCount, count);
    XCTAssertEqual(0U, company.employeeSet.count);

    [realm cancelWriteTransaction];

    // Unmanaged set
    company = [[CompanyObject alloc] init];
    for (size_t i = 0; i < totalCount; ++i) {
        [company.employeeSet addObject:[[EmployeeObject alloc] initWithValue:@[@"name", @(i), @NO]]];
    }

    count = 0;
    for (EmployeeObject *eo in company.employeeSet) {
        ++count;
        [company.employeeSet addObject:eo];
    }
    XCTAssertEqual(totalCount, count);
    XCTAssertEqual(totalCount, company.employeeSet.count);
}

- (void)testDeleteDuringEnumeration {
    RLMRealm *realm = self.realmWithTestPath;

    [realm beginWriteTransaction];
    CompanyObject *company = [[CompanyObject alloc] init];
    company.name = @"name";
    [realm addObject:company];

    const size_t totalCount = 40;
    for (size_t i = 0; i < totalCount; ++i) {
        [company.employeeSet addObject:[EmployeeObject createInRealm:realm withValue:@[@"name", @(i), @NO]]];
    }

    [realm commitWriteTransaction];

    [realm beginWriteTransaction];
    for (__unused EmployeeObject *eo in company.employeeSet) {
        [realm deleteObjects:company.employeeSet];
    }
    [realm commitWriteTransaction];
}

- (void)testValueForKey {
    RLMRealm *realm = self.realmWithTestPath;

    [realm beginWriteTransaction];
    CompanyObject *company = [[CompanyObject alloc] init];
    company.name = @"name";
    XCTAssertEqual(((NSSet *)[company.employeeSet valueForKey:@"name"]).count, 0U);
    [realm addObject:company];
    [realm commitWriteTransaction];

    XCTAssertEqual(((NSSet *)[company.employeeSet valueForKey:@"name"]).count, 0U);

    // managed
    NSMutableOrderedSet *ages = [NSMutableOrderedSet orderedSet];
    [realm beginWriteTransaction];
    for (int i = 0; i < 30; ++i) {
        [ages addObject:@(i)];
        EmployeeObject *eo = [EmployeeObject createInRealm:realm withValue:@{@"name": @"Joe",  @"age": @(i), @"hired": @YES}];
        [company.employeeSet addObject:eo];
    }
    [realm commitWriteTransaction];

    RLM_GENERIC_SET(EmployeeObject) *employeeObjects = [company valueForKey:@"employeeSet"];
    NSMutableOrderedSet *kvcAgeProperties = [NSMutableOrderedSet orderedSet];
    for (EmployeeObject *employee in employeeObjects) {
        [kvcAgeProperties addObject:@(employee.age)];
    }
    XCTAssertEqualObjects(kvcAgeProperties, ages);

    XCTAssertEqualObjects([company.employeeSet valueForKey:@"age"], ages);
    XCTAssertTrue([[[company.employeeSet valueForKey:@"self"] firstObject] isEqualToObject:company.employeeSet.firstObject]);
    XCTAssertTrue([[[company.employeeSet valueForKey:@"self"] lastObject] isEqualToObject:company.employeeSet.lastObject]);

    XCTAssertEqual([[company.employeeSet valueForKeyPath:@"@count"] integerValue], 30);
    XCTAssertEqual([[company.employeeSet valueForKeyPath:@"@min.age"] integerValue], 0);
    XCTAssertEqual([[company.employeeSet valueForKeyPath:@"@max.age"] integerValue], 29);
    XCTAssertEqualWithAccuracy([[company.employeeSet valueForKeyPath:@"@avg.age"] doubleValue], 14.5, 0.1f);

    XCTAssertEqualObjects([company.employeeSet valueForKeyPath:@"@unionOfObjects.age"],
                          (@[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11, @12, @13, @14, @15, @16, @17, @18, @19, @20, @21, @22, @23, @24, @25, @26, @27, @28, @29]));
    XCTAssertEqualObjects([company.employeeSet valueForKeyPath:@"@distinctUnionOfObjects.name"], (@[@"Joe"]));

    RLMAssertThrowsWithReasonMatching([company.employeeSet valueForKeyPath:@"@sum.dogs.@sum.age"], @"Nested key paths.*not supported");

    // unmanaged object
    company = [[CompanyObject alloc] init];
    ages = [NSMutableOrderedSet orderedSet];
    for (int i = 0; i < 30; ++i) {
        [ages addObject:@(i)];
        EmployeeObject *eo = [[EmployeeObject alloc] initWithValue:@{@"name": @"Joe",  @"age": @(i), @"hired": @YES}];
        [company.employeeSet addObject:eo];
    }

    XCTAssertEqualObjects([company.employeeSet valueForKey:@"age"], ages);
    XCTAssertTrue([[[company.employeeSet valueForKey:@"self"] firstObject] isEqualToObject:company.employeeSet.firstObject]);
    XCTAssertTrue([[[company.employeeSet valueForKey:@"self"] lastObject] isEqualToObject:company.employeeSet.lastObject]);

    XCTAssertEqual([[company.employeeSet valueForKeyPath:@"@count"] integerValue], 30);
    XCTAssertEqual([[company.employeeSet valueForKeyPath:@"@min.age"] integerValue], 0);
    XCTAssertEqual([[company.employeeSet valueForKeyPath:@"@max.age"] integerValue], 29);
    XCTAssertEqualWithAccuracy([[company.employeeSet valueForKeyPath:@"@avg.age"] doubleValue], 14.5, 0.1f);

    RLMAssertThrowsWithReasonMatching([company.employeeSet valueForKeyPath:@"@unionOfObjects.age"], @"this class does not implement the unionOfObjects");
    RLMAssertThrowsWithReasonMatching([company.employeeSet valueForKeyPath:@"@distinctUnionOfObjects.name"], @"this class does not implement the distinctUnionOfObjects");

    RLMAssertThrowsWithReasonMatching([company.employeeSet valueForKeyPath:@"@sum.dogs.@sum.age"], @"Nested key paths.*not supported");
}

- (void)testSetValueForKey {
    RLMRealm *realm = self.realmWithTestPath;

    [realm beginWriteTransaction];
    CompanyObject *company = [[CompanyObject alloc] init];
    company.name = @"name";

    [company.employeeSet setValue:@"name" forKey:@"name"];
    XCTAssertEqual(((NSSet *)[company.employeeSet valueForKey:@"name"]).count, 0U);

    [realm addObject:company];
    [realm commitWriteTransaction];

    XCTAssertThrows([company.employeeSet setValue:@10 forKey:@"age"]);
    XCTAssertEqual(((NSSet *)[company.employeeSet valueForKey:@"name"]).count, 0U);

    // managed
    NSMutableOrderedSet *ages = [NSMutableOrderedSet orderedSet];
    [realm beginWriteTransaction];
    for (int i = 0; i < 30; ++i) {
        [ages addObject:@(20)];
        EmployeeObject *eo = [EmployeeObject createInRealm:realm withValue:@{@"name": @"Joe",  @"age": @(i), @"hired": @YES}];
        [company.employeeSet addObject:eo];
    }

    [company.employeeSet setValue:@20 forKey:@"age"];
    [realm commitWriteTransaction];

    XCTAssertEqualObjects([company.employeeSet valueForKey:@"age"], ages);

    // unmanaged object
    company = [[CompanyObject alloc] init];
    ages = [NSMutableOrderedSet orderedSet];
    for (int i = 0; i < 30; ++i) {
        [ages addObject:@(20)];
        EmployeeObject *eo = [[EmployeeObject alloc] initWithValue:@{@"name": @"Joe",  @"age": @(i), @"hired": @YES}];
        [company.employeeSet addObject:eo];
    }

    [company.employeeSet setValue:@20 forKey:@"age"];

    XCTAssertEqualObjects([company.employeeSet valueForKey:@"age"], ages);
}

- (void)testObjectAggregate {
    RLMRealm *realm = [RLMRealm defaultRealm];

    AggregateSetObject *obj = [AggregateSetObject new];
    XCTAssertEqual(0, [obj.set sumOfProperty:@"intCol"].intValue);
    XCTAssertNil([obj.set averageOfProperty:@"intCol"]);
    XCTAssertNil([obj.set minOfProperty:@"intCol"]);
    XCTAssertNil([obj.set maxOfProperty:@"intCol"]);

    NSDate *dateMinInput = [NSDate date];
    NSDate *dateMaxInput = [dateMinInput dateByAddingTimeInterval:1000];

    [realm transactionWithBlock:^{
        [AggregateObject createInRealm:realm withValue:@[@0, @1.2f, @0.0, @YES, dateMinInput]];
        [AggregateObject createInRealm:realm withValue:@[@1, @0.2f, @2.5, @NO, dateMaxInput]];
        [AggregateObject createInRealm:realm withValue:@[@2, @1.2f, @0.0, @YES, dateMinInput]];
        [AggregateObject createInRealm:realm withValue:@[@3, @0.0f, @2.5, @NO, dateMaxInput]];
        [AggregateObject createInRealm:realm withValue:@[@4, @1.2f, @0.0, @YES, dateMinInput]];
        [AggregateObject createInRealm:realm withValue:@[@5, @0.0f, @2.5, @NO, dateMaxInput]];
        [AggregateObject createInRealm:realm withValue:@[@6, @1.2f, @0.0, @YES, dateMinInput]];
        [AggregateObject createInRealm:realm withValue:@[@7, @0.0f, @2.5, @NO, dateMaxInput]];
        [AggregateObject createInRealm:realm withValue:@[@8, @1.2f, @0.0, @YES, dateMinInput]];
        [AggregateObject createInRealm:realm withValue:@[@9, @1.2f, @0.0, @YES, dateMinInput]];

        [obj.set addObjects:[AggregateObject allObjectsInRealm:realm]];
    }];

    void (^test)(void) = ^{
        RLMSet *set = obj.set;
        // NSSet will always return distinct values for primitive properties. This does match Cores implementation.
        // Leaving this test open for questions ATM.
        // SUM
        XCTAssertEqual([set sumOfProperty:@"intCol"].integerValue, 45);
        XCTAssertEqualWithAccuracy([set sumOfProperty:@"floatCol"].floatValue, 1.4f, 0.1f);
        XCTAssertEqualWithAccuracy([set sumOfProperty:@"doubleCol"].doubleValue, 2.5, 0.1f);
        RLMAssertThrowsWithReasonMatching([set sumOfProperty:@"foo"], @"foo.*AggregateObject");
        RLMAssertThrowsWithReasonMatching([set sumOfProperty:@"boolCol"], @"sum.*bool");
        RLMAssertThrowsWithReasonMatching([set sumOfProperty:@"dateCol"], @"sum.*date");

        // Average
        XCTAssertEqualWithAccuracy([set averageOfProperty:@"intCol"].doubleValue, 4.5, 0.1f);
        XCTAssertEqualWithAccuracy([set averageOfProperty:@"floatCol"].doubleValue, 0.46, 0.1f);
        XCTAssertEqualWithAccuracy([set averageOfProperty:@"doubleCol"].doubleValue, 1.25, 0.1f);
        RLMAssertThrowsWithReasonMatching([set averageOfProperty:@"foo"], @"foo.*AggregateObject");
        RLMAssertThrowsWithReasonMatching([set averageOfProperty:@"boolCol"], @"average.*bool");
        RLMAssertThrowsWithReasonMatching([set averageOfProperty:@"dateCol"], @"average.*date");

        // MIN
        XCTAssertEqual(0, [[set minOfProperty:@"intCol"] intValue]);
        XCTAssertEqual(0.0f, [[set minOfProperty:@"floatCol"] floatValue]);
        XCTAssertEqual(0.0, [[set minOfProperty:@"doubleCol"] doubleValue]);
        XCTAssertEqualObjects(dateMinInput, [set minOfProperty:@"dateCol"]);
        RLMAssertThrowsWithReasonMatching([set minOfProperty:@"foo"], @"foo.*AggregateObject");
        RLMAssertThrowsWithReasonMatching([set minOfProperty:@"boolCol"], @"min.*bool");

        // MAX
        XCTAssertEqual(9, [[set maxOfProperty:@"intCol"] intValue]);
        XCTAssertEqual(1.2f, [[set maxOfProperty:@"floatCol"] floatValue]);
        XCTAssertEqual(2.5, [[set maxOfProperty:@"doubleCol"] doubleValue]);
        XCTAssertEqualObjects(dateMaxInput, [set maxOfProperty:@"dateCol"]);
        RLMAssertThrowsWithReasonMatching([set maxOfProperty:@"foo"], @"foo.*AggregateObject");
        RLMAssertThrowsWithReasonMatching([set maxOfProperty:@"boolCol"], @"max.*bool");
    };

    test();
    [realm transactionWithBlock:^{ [realm addObject:obj]; }];
    test();
}

- (void)testRenamedPropertyAggregate {
    RLMRealm *realm = [RLMRealm defaultRealm];

    LinkToRenamedProperties1 *obj = [LinkToRenamedProperties1 new];
    XCTAssertEqual(0, [obj.set sumOfProperty:@"propA"].intValue);
    XCTAssertNil([obj.set averageOfProperty:@"propA"]);
    XCTAssertNil([obj.set minOfProperty:@"propA"]);
    XCTAssertNil([obj.set maxOfProperty:@"propA"]);
    XCTAssertThrows([obj.set sumOfProperty:@"prop 1"]);

    [realm transactionWithBlock:^{
        [RenamedProperties1 createInRealm:realm withValue:@[@1, @""]];
        [RenamedProperties1 createInRealm:realm withValue:@[@2, @""]];
        [RenamedProperties1 createInRealm:realm withValue:@[@3, @""]];

        [obj.set addObjects:[RenamedProperties1 allObjectsInRealm:realm]];
    }];

    XCTAssertEqual(6, [obj.set sumOfProperty:@"propA"].intValue);
    XCTAssertEqual(2.0, [obj.set averageOfProperty:@"propA"].doubleValue);
    XCTAssertEqual(1, [[obj.set minOfProperty:@"propA"] intValue]);
    XCTAssertEqual(3, [[obj.set maxOfProperty:@"propA"] intValue]);

    [realm transactionWithBlock:^{ [realm addObject:obj]; }];

    XCTAssertEqual(6, [obj.set sumOfProperty:@"propA"].intValue);
    XCTAssertEqual(2.0, [obj.set averageOfProperty:@"propA"].doubleValue);
    XCTAssertEqual(1, [[obj.set minOfProperty:@"propA"] intValue]);
    XCTAssertEqual(3, [[obj.set maxOfProperty:@"propA"] intValue]);
}

- (void)testValueForCollectionOperationKeyPath
{
    RLMRealm *realm = [RLMRealm defaultRealm];

    [realm beginWriteTransaction];
    EmployeeObject *e1 = [PrimaryEmployeeObject createInRealm:realm withValue:@{@"name": @"A", @"age": @20, @"hired": @YES}];
    EmployeeObject *e2 = [PrimaryEmployeeObject createInRealm:realm withValue:@{@"name": @"B", @"age": @30, @"hired": @NO}];
    EmployeeObject *e3 = [PrimaryEmployeeObject createInRealm:realm withValue:@{@"name": @"C", @"age": @40, @"hired": @YES}];
    EmployeeObject *e4 = [PrimaryEmployeeObject createInRealm:realm withValue:@{@"name": @"D", @"age": @50, @"hired": @YES}];
    PrimaryCompanyObject *c1 = [PrimaryCompanyObject createInRealm:realm withValue:@{@"name": @"ABC AG", @"employeesSet": @[e1, e2, e3, e2]}];
    PrimaryCompanyObject *c2 = [PrimaryCompanyObject createInRealm:realm withValue:@{@"name": @"ABC AG 2", @"employeesSet": @[e1, e4]}];

    SetOfPrimaryCompanies *companies = [SetOfPrimaryCompanies createInRealm:realm withValue:@[@[c1, c2]]];
    [realm commitWriteTransaction];

    // count operator
    XCTAssertEqual([[c1.employeesSet valueForKeyPath:@"@count"] integerValue], 3);

    // numeric operators
    XCTAssertEqual([[c1.employeesSet valueForKeyPath:@"@min.age"] intValue], 20);
    XCTAssertEqual([[c1.employeesSet valueForKeyPath:@"@max.age"] intValue], 40);
    XCTAssertEqual([[c1.employeesSet valueForKeyPath:@"@sum.age"] integerValue], 90);
    XCTAssertEqualWithAccuracy([[c1.employeesSet valueForKeyPath:@"@avg.age"] doubleValue], 30, 0.1f);

    // collection
//    XCTAssertEqualObjects([c1.employeesSet valueForKeyPath:@"@unionOfObjects.name"],
//                          (@[@"C", @"A", @"B"]));
//
//    XCTAssertEqualObjects([[c1.employeesSet valueForKeyPath:@"@distinctUnionOfObjects.name"] sortedArrayUsingSelector:@selector(compare:)],
//                          (@[@"A", @"B", @"C"]));
//    XCTAssertEqualObjects([companies.companies valueForKeyPath:@"@unionOfArrays.employees"],
//                          (@[e1, e2, e3, e4]));
//    NSComparator cmp = ^NSComparisonResult(id obj1, id obj2) { return [[obj1 name] compare:[obj2 name]]; };
//    XCTAssertEqualObjects([[companies.companies valueForKeyPath:@"@distinctUnionOfSets.employees"] sortedArrayUsingComparator:cmp],
//                          (@[e1, e2, e3, e4]));

    // invalid key paths
    RLMAssertThrowsWithReasonMatching([c1.employeesSet valueForKeyPath:@"@invalid.name"],
                                      @"Unsupported KVC collection operator found in key path '@invalid.name'");
    RLMAssertThrowsWithReasonMatching([c1.employeesSet valueForKeyPath:@"@sum"],
                                      @"Missing key path for KVC collection operator sum in key path '@sum'");
    RLMAssertThrowsWithReasonMatching([c1.employeesSet valueForKeyPath:@"@sum."],
                                      @"Missing key path for KVC collection operator sum in key path '@sum.'");
    RLMAssertThrowsWithReasonMatching([c1.employeesSet valueForKeyPath:@"@sum.employees.@sum.age"],
                                      @"Nested key paths.*not supported");
}

- (void)testCrossThreadAccess
{
    CompanyObject *company = [[CompanyObject alloc] init];
    company.name = @"name";

    EmployeeObject *eo = [[EmployeeObject alloc] init];
    eo.name = @"Joe";
    eo.age = 40;
    eo.hired = YES;
    [company.employeeSet addObject:eo];
    RLMSet *employees = company.employeeSet;

    // Unmanaged object can be accessed from other threads
    [self dispatchAsyncAndWait:^{
        XCTAssertNoThrow(company.employeeSet);
        XCTAssertNoThrow([employees lastObject]);
    }];

    [RLMRealm.defaultRealm beginWriteTransaction];
    [RLMRealm.defaultRealm addObject:company];
    [RLMRealm.defaultRealm commitWriteTransaction];

    employees = company.employeeSet;
    XCTAssertNoThrow(company.employeeSet);
    XCTAssertNoThrow([employees lastObject]);
    [self dispatchAsyncAndWait:^{
        XCTAssertThrows(company.employeeSet);
        XCTAssertThrows([employees lastObject]);
    }];
}

- (void)testSortByNoColumns {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    DogObject *a2 = [DogObject createInDefaultRealmWithValue:@[@"a", @2]];
    DogObject *b1 = [DogObject createInDefaultRealmWithValue:@[@"b", @1]];
    DogObject *a1 = [DogObject createInDefaultRealmWithValue:@[@"a", @1]];
    DogObject *b2 = [DogObject createInDefaultRealmWithValue:@[@"b", @2]];

    RLMSet<DogObject *> *set = [DogSetObject createInDefaultRealmWithValue:@[@[a2, b1, a1, b2]]].dogs;
    [realm commitWriteTransaction];

    RLMResults *notActuallySorted = [set sortedResultsUsingDescriptors:@[]];
    XCTAssertTrue([set[0] isEqualToObject:notActuallySorted[0]]);
    XCTAssertTrue([set[1] isEqualToObject:notActuallySorted[1]]);
    XCTAssertTrue([set[2] isEqualToObject:notActuallySorted[2]]);
    XCTAssertTrue([set[3] isEqualToObject:notActuallySorted[3]]);
}

- (void)testSortByMultipleColumns {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    DogObject *a1 = [DogObject createInDefaultRealmWithValue:@[@"a", @1]];
    DogObject *a2 = [DogObject createInDefaultRealmWithValue:@[@"a", @2]];
    DogObject *b1 = [DogObject createInDefaultRealmWithValue:@[@"b", @1]];
    DogObject *b2 = [DogObject createInDefaultRealmWithValue:@[@"b", @2]];

    DogSetObject *set = [DogSetObject createInDefaultRealmWithValue:@[@[a1, a2, b1, b2]]];
    [realm commitWriteTransaction];

    bool (^checkOrder)(NSArray *, NSArray *, NSArray *) = ^bool(NSArray *properties, NSArray *ascending, NSArray *dogs) {
        NSArray *sort = @[[RLMSortDescriptor sortDescriptorWithKeyPath:properties[0] ascending:[ascending[0] boolValue]],
                          [RLMSortDescriptor sortDescriptorWithKeyPath:properties[1] ascending:[ascending[1] boolValue]]];
        RLMResults *actual = [set.dogs sortedResultsUsingDescriptors:sort];

        return [actual[0] isEqualToObject:dogs[0]]
            && [actual[1] isEqualToObject:dogs[1]]
            && [actual[2] isEqualToObject:dogs[2]]
            && [actual[3] isEqualToObject:dogs[3]];
    };

    // Check each valid sort
    XCTAssertTrue(checkOrder(@[@"dogName", @"age"], @[@YES, @YES], @[a1, a2, b1, b2]));
    XCTAssertTrue(checkOrder(@[@"dogName", @"age"], @[@YES, @NO], @[a2, a1, b2, b1]));
    XCTAssertTrue(checkOrder(@[@"dogName", @"age"], @[@NO, @YES], @[b1, b2, a1, a2]));
    XCTAssertTrue(checkOrder(@[@"dogName", @"age"], @[@NO, @NO], @[b2, b1, a2, a1]));
    XCTAssertTrue(checkOrder(@[@"age", @"dogName"], @[@YES, @YES], @[a1, b1, a2, b2]));
    XCTAssertTrue(checkOrder(@[@"age", @"dogName"], @[@YES, @NO], @[b1, a1, b2, a2]));
    XCTAssertTrue(checkOrder(@[@"age", @"dogName"], @[@NO, @YES], @[a2, b2, a1, b1]));
    XCTAssertTrue(checkOrder(@[@"age", @"dogName"], @[@NO, @NO], @[b2, a2, b1, a1]));
}

- (void)testSortByRenamedColumns {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    id value = @{@"set": @[@[@1, @"c"], @[@2, @"b"], @[@3, @"a"]]};
    LinkToRenamedProperties1 *obj = [LinkToRenamedProperties1 createInRealm:realm withValue:value];

    // FIXME: sorting has to use the column names because the parsing is done by
    // the object store. This is not ideal.
    XCTAssertEqualObjects([[obj.set sortedResultsUsingKeyPath:@"prop 1" ascending:YES] valueForKeyPath:@"propA"],
                          (@[@1, @2, @3]));
    XCTAssertEqualObjects([[obj.set sortedResultsUsingKeyPath:@"prop 2" ascending:YES] valueForKeyPath:@"propA"],
                          (@[@3, @2, @1]));

    LinkToRenamedProperties2 *obj2 = [LinkToRenamedProperties2 allObjectsInRealm:realm].firstObject;
    XCTAssertEqualObjects([[obj2.set sortedResultsUsingKeyPath:@"prop 1" ascending:YES] valueForKeyPath:@"propC"],
                          (@[@1, @2, @3]));
    XCTAssertEqualObjects([[obj2.set sortedResultsUsingKeyPath:@"prop 2" ascending:YES] valueForKeyPath:@"propC"],
                          (@[@3, @2, @1]));

    [realm cancelWriteTransaction];
}

- (void)testDeleteLinksAndObjectsInSet
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    EmployeeObject *po1 = [EmployeeObject createInRealm:realm withValue:@[@"Joe", @40, @YES]];
    EmployeeObject *po2 = [EmployeeObject createInRealm:realm withValue:@[@"John", @30, @NO]];
    EmployeeObject *po3 = [EmployeeObject createInRealm:realm withValue:@[@"Jill", @25, @YES]];

    CompanyObject *company = [[CompanyObject alloc] init];
    company.name = @"name";
    [company.employeeSet addObjects:[EmployeeObject allObjects]];
    [realm addObject:company];

    [realm commitWriteTransaction];

    RLMSet *peopleInCompany = company.employeeSet;

    // Delete link to employee
    XCTAssertThrowsSpecificNamed([peopleInCompany removeObject:po2], NSException, @"RLMException", @"Not allowed in read transaction");
    XCTAssertEqual(peopleInCompany.count, 3U, @"No links should have been deleted");

    [realm beginWriteTransaction];
    XCTAssertNoThrow([peopleInCompany removeObject:po3], @"Should delete link to employee");
    [realm commitWriteTransaction];

    XCTAssertEqual(peopleInCompany.count, 2U, @"link deleted when accessing via links");
    EmployeeObject *test = peopleInCompany[0];
    XCTAssertEqual(test.age, po1.age, @"Should be equal");
    XCTAssertEqualObjects(test.name, po1.name, @"Should be equal");
    XCTAssertEqual(test.hired, po1.hired, @"Should be equal");
    XCTAssertTrue([test isEqualToObject:po1], @"Should be equal");

    test = peopleInCompany[1];
    XCTAssertEqual(test.age, po2.age, @"Should be equal");
    XCTAssertEqualObjects(test.name, po2.name, @"Should be equal");
    XCTAssertEqual(test.hired, po2.hired, @"Should be equal");
    XCTAssertTrue([test isEqualToObject:po2], @"Should be equal");

    XCTAssertThrowsSpecificNamed([peopleInCompany removeLastObject], NSException, @"RLMException", @"Not allowed in read transaction");
    XCTAssertThrowsSpecificNamed([peopleInCompany removeAllObjects], NSException, @"RLMException", @"Not allowed in read transaction");
    XCTAssertThrowsSpecificNamed([peopleInCompany addObject:po2], NSException, @"RLMException", @"Not allowed in read transaction");

    [realm beginWriteTransaction];
    XCTAssertNoThrow([peopleInCompany removeLastObject], @"Should delete last link");
    XCTAssertEqual(peopleInCompany.count, 1U, @"1 remaining link");


    [peopleInCompany removeObject:po2];
    XCTAssertEqual(peopleInCompany.count, 1U, @"1 link replaced");
    [peopleInCompany addObject:po1];
    XCTAssertEqual(peopleInCompany.count, 1U, @"1 link");
    XCTAssertNoThrow([peopleInCompany removeAllObjects], @"Should delete all links");
    XCTAssertEqual(peopleInCompany.count, 0U, @"0 remaining links");
    [realm commitWriteTransaction];

    RLMResults *allPeople = [EmployeeObject allObjects];
    XCTAssertEqual(allPeople.count, 3U, @"Only links should have been deleted, not the employees");
}

- (void)testSetDescription {
    RLMRealm *realm = [RLMRealm defaultRealm];

    [realm beginWriteTransaction];
    RLMSet<EmployeeObject *> *employees = [CompanyObject createInDefaultRealmWithValue:@[@"company"]].employeeSet;
    RLMSet<NSNumber *> *ints = [AllPrimitiveSets createInDefaultRealmWithValue:@[]].intObj;
    for (NSInteger i = 0; i < 1012; ++i) {
        EmployeeObject *person = [[EmployeeObject alloc] init];
        person.name = @"Mary";
        person.age = 24;
        person.hired = YES;
        [employees addObject:person];
        [ints addObject:@(i + 100)];
    }
    [realm commitWriteTransaction];

    RLMAssertMatches(employees.description,
                     @"(?s)RLMSet\\<EmployeeObject\\> \\<0x[a-z0-9]+\\> \\(\n"
                     @"\t\\[0\\] EmployeeObject \\{\n"
                     @"\t\tname = Mary;\n"
                     @"\t\tage = 24;\n"
                     @"\t\thired = 1;\n"
                     @"\t\\},\n"
                     @".*\n"
                     @"\t... 912 objects skipped.\n"
                     @"\\)");
    RLMAssertMatches(ints.description,
                     @"(?s)RLMSet\\<int\\> \\<0x[a-z0-9]+\\> \\(\n"
                     @"\t\\[0\\] 100,\n"
                     @"\t\\[1\\] 101,\n"
                     @"\t\\[2\\] 102,\n"
                     @".*\n"
                     @"\t... 912 objects skipped.\n"
                     @"\\)");
}

- (void)testUnmanagedAssignment {
    IntObject *io1 = [[IntObject alloc] init];
    IntObject *io2 = [[IntObject alloc] init];
    IntObject *io3 = [[IntObject alloc] init];

    SetPropertyObject *set1 = [[SetPropertyObject alloc] init];
    SetPropertyObject *set2 = [[SetPropertyObject alloc] init];

    set1.intSet = (id)@[io1, io2];
    set2.intSet = (id)@[io1, io2];

    XCTAssertEqualObjects([set1.intSet valueForKey:@"self"], [set2.intSet valueForKey:@"self"]);

    [set1 setValue:@[io3, io1] forKey:@"intSet"];
    [set2 setValue:@[io3, io1] forKey:@"intSet"];
    XCTAssertEqualObjects([set1.intSet valueForKey:@"self"], [set2.intSet valueForKey:@"self"]);

    set1[@"intSet"] = @[io2, io3];
    set2[@"intSet"] = @[io2, io3];
    XCTAssertEqualObjects([set1.intSet valueForKey:@"self"], [set2.intSet valueForKey:@"self"]);

    // Assigning RLMSet shallow copies
    set2.intSet = set1.intSet;
    XCTAssertEqualObjects([set2.intSet valueForKey:@"self"], [set1.intSet valueForKey:@"self"]);

    [set1.intSet removeAllObjects];
    [set2.intSet removeAllObjects];
    XCTAssertEqualObjects([set2.intSet valueForKey:@"self"], [set1.intSet valueForKey:@"self"]);
}

- (void)testManagedAssignment {
    RLMRealm *realm = self.realmWithTestPath;
    [realm beginWriteTransaction];

    IntObject *io1 = [IntObject createInRealm:realm withValue:@[@1]];
    IntObject *io2 = [IntObject createInRealm:realm withValue:@[@2]];
    IntObject *io3 = [IntObject createInRealm:realm withValue:@[@3]];

    SetPropertyObject *set1 = [SetPropertyObject createInRealm:realm withValue:@[@""]];
    SetPropertyObject *set2 = [SetPropertyObject createInRealm:realm withValue:@[@""]];

    set1.intSet = (id)@[io1, io2];
    set2.intSet = (id)@[io1, io2];

    XCTAssertEqualObjects([set1.intSet valueForKey:@"self"], [set2.intSet valueForKey:@"self"]);

    [set1 setValue:@[io3, io1] forKey:@"intSet"];
    [set2 setValue:@[io3, io1] forKey:@"intSet"];
    XCTAssertEqualObjects([set1.intSet valueForKey:@"self"], [set2.intSet valueForKey:@"self"]);

    set1[@"intSet"] = @[io2, io3];
    set2[@"intSet"] = @[io2, io3];
    XCTAssertEqualObjects([set1.intSet valueForKey:@"self"], [set2.intSet valueForKey:@"self"]);

    // Assigning RLMSet shallow copies
    set2.intSet = set1.intSet;
    XCTAssertEqualObjects([set2.intSet valueForKey:@"self"], [set1.intSet valueForKey:@"self"]);

    [set1.intSet removeAllObjects];
    [set2.intSet removeAllObjects];
    XCTAssertEqualObjects([set2.intSet valueForKey:@"self"], [set1.intSet valueForKey:@"self"]);

    [realm cancelWriteTransaction];
}
// Start Wednesday
- (void)testAssignIncorrectType {
    RLMRealm *realm = self.realmWithTestPath;
    [realm beginWriteTransaction];
    ArrayPropertyObject *array = [ArrayPropertyObject createInRealm:realm
                                                          withValue:@[@"", @[@[@"a"]], @[@[@0]]]];
    RLMAssertThrowsWithReason(array.intArray = (id)array.array,
                              @"RLMArray<StringObject> does not match expected type 'IntObject' for property 'ArrayPropertyObject.intArray'.");
    RLMAssertThrowsWithReason(array[@"intArray"] = array[@"array"],
                              @"RLMArray<StringObject> does not match expected type 'IntObject' for property 'ArrayPropertyObject.intArray'.");
    [realm cancelWriteTransaction];
}

- (void)testNotificationSentInitially {
    RLMRealm *realm = self.realmWithTestPath;
    [realm beginWriteTransaction];
    SetPropertyObject *set = [SetPropertyObject createInRealm:realm withValue:@[@"", @[], @[]]];
    [realm commitWriteTransaction];

    id expectation = [self expectationWithDescription:@""];
    id token = [set.intSet addNotificationBlock:^(RLMSet *set, RLMCollectionChange *change, NSError *error) {
        XCTAssertNotNil(set);
        XCTAssertNil(change);
        XCTAssertNil(error);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2.0 handler:nil];
    [(RLMNotificationToken *)token invalidate];
}

- (void)testNotificationSentAfterCommit {
    RLMRealm *realm = self.realmWithTestPath;
    [realm beginWriteTransaction];
    SetPropertyObject *set = [SetPropertyObject createInRealm:realm withValue:@[@"", @[], @[]]];
    [realm commitWriteTransaction];

    __block bool first = true;
    __block id expectation = [self expectationWithDescription:@""];
    id token = [set.stringSet addNotificationBlock:^(RLMSet *set, RLMCollectionChange *change, NSError *error) {
        XCTAssertNotNil(set);
        XCTAssert(first ? !change : !!change);
        XCTAssertNil(error);
        first = false;
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    expectation = [self expectationWithDescription:@""];
    [self dispatchAsyncAndWait:^{
        RLMRealm *realm = self.realmWithTestPath;
        [realm transactionWithBlock:^{
            RLMSet *set = ((SetPropertyObject *)[SetPropertyObject allObjectsInRealm:realm].firstObject).stringSet;
            [set addObject:[[StringObject alloc] init]];
        }];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    [(RLMNotificationToken *)token invalidate];
}

- (void)testNotificationNotSentForUnrelatedChange {
    RLMRealm *realm = self.realmWithTestPath;
    [realm beginWriteTransaction];
    SetPropertyObject *set = [SetPropertyObject createInRealm:realm withValue:@[@"", @[], @[]]];
    [realm commitWriteTransaction];

    id expectation = [self expectationWithDescription:@""];
    id token = [set.intSet addNotificationBlock:^(__unused RLMSet *set, __unused RLMCollectionChange *change, __unused NSError *error) {
        // will throw if it's incorrectly called a second time due to the
        // unrelated write transaction
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    // All notification blocks are called as part of a single runloop event, so
    // waiting for this one also waits for the above one to get a chance to run
    [self waitForNotification:RLMRealmDidChangeNotification realm:realm block:^{
        [self dispatchAsyncAndWait:^{
            RLMRealm *realm = self.realmWithTestPath;
            [realm transactionWithBlock:^{
                [SetPropertyObject createInRealm:realm withValue:@[@"", @[], @[]]];
            }];
        }];
    }];
    [(RLMNotificationToken *)token invalidate];
}

- (void)testNotificationSentOnlyForActualRefresh {
    RLMRealm *realm = self.realmWithTestPath;
    [realm beginWriteTransaction];
    SetPropertyObject *set = [SetPropertyObject createInRealm:realm withValue:@[@"", @[], @[]]];
    [realm commitWriteTransaction];

    __block id expectation = [self expectationWithDescription:@""];
    id token = [set.stringSet addNotificationBlock:^(RLMSet *set, __unused RLMCollectionChange *change, NSError *error) {
        XCTAssertNotNil(set);
        XCTAssertNil(error);
        // will throw if it's called a second time before we create the new
        // expectation object immediately before manually refreshing
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    // Turn off autorefresh, so the background commit should not result in a notification
    realm.autorefresh = NO;

    // All notification blocks are called as part of a single runloop event, so
    // waiting for this one also waits for the above one to get a chance to run
    [self waitForNotification:RLMRealmRefreshRequiredNotification realm:realm block:^{
        [self dispatchAsyncAndWait:^{
            RLMRealm *realm = self.realmWithTestPath;
            [realm transactionWithBlock:^{
                RLMSet *set = ((SetPropertyObject *)[SetPropertyObject allObjectsInRealm:realm].firstObject).stringSet;
                [set addObject:[[StringObject alloc] init]];
            }];
        }];
    }];

    expectation = [self expectationWithDescription:@""];
    [realm refresh];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    [(RLMNotificationToken *)token invalidate];
}

- (void)testDeletingObjectWithNotificationsRegistered {
    RLMRealm *realm = self.realmWithTestPath;
    [realm beginWriteTransaction];
    SetPropertyObject *set = [SetPropertyObject createInRealm:realm withValue:@[@"", @[], @[]]];
    [realm commitWriteTransaction];

    __block id expectation = [self expectationWithDescription:@""];
    id token = [set.stringSet addNotificationBlock:^(RLMSet *set, __unused RLMCollectionChange *change, NSError *error) {
        XCTAssertNotNil(set);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];

    [realm beginWriteTransaction];
    [realm deleteObject:set];
    [realm commitWriteTransaction];

    [(RLMNotificationToken *)token invalidate];
}

static RLMSet<IntObject *> *managedTestSet() {
    RLMRealm *realm = [RLMRealm defaultRealm];
    __block RLMSet *set;
    [realm transactionWithBlock:^{
        SetPropertyObject *obj = [SetPropertyObject createInDefaultRealmWithValue:@[@"", @[], @[@[@0], @[@1]]]];
        set = obj.intSet;
    }];
    return set;
}

- (void)testAllMethodsCheckThread {
    RLMSet<IntObject *> *set = managedTestSet();
    IntObject *io = set.firstObject;
    RLMRealm *realm = set.realm;
    [realm beginWriteTransaction];

    [self dispatchAsyncAndWait:^{
        RLMAssertThrowsWithReasonMatching([set count], @"thread");
        RLMAssertThrowsWithReasonMatching([set objectAtIndex:0], @"thread");
        RLMAssertThrowsWithReasonMatching([set firstObject], @"thread");
        RLMAssertThrowsWithReasonMatching([set lastObject], @"thread");

        RLMAssertThrowsWithReasonMatching([set addObject:io], @"thread");
        RLMAssertThrowsWithReasonMatching([set addObjects:@[io]], @"thread");
        RLMAssertThrowsWithReasonMatching([set removeLastObject], @"thread");
        RLMAssertThrowsWithReasonMatching([set removeAllObjects], @"thread");

        RLMAssertThrowsWithReasonMatching([set indexOfObject:[IntObject allObjects].firstObject], @"thread");
        RLMAssertThrowsWithReasonMatching([set indexOfObjectWhere:@"intCol = 0"], @"thread");
        RLMAssertThrowsWithReasonMatching([set indexOfObjectWithPredicate:[NSPredicate predicateWithFormat:@"intCol = 0"]], @"thread");
        RLMAssertThrowsWithReasonMatching([set objectsWhere:@"intCol = 0"], @"thread");
        RLMAssertThrowsWithReasonMatching([set objectsWithPredicate:[NSPredicate predicateWithFormat:@"intCol = 0"]], @"thread");
        RLMAssertThrowsWithReasonMatching([set sortedResultsUsingKeyPath:@"intCol" ascending:YES], @"thread");
        RLMAssertThrowsWithReasonMatching([set sortedResultsUsingDescriptors:@[[RLMSortDescriptor sortDescriptorWithKeyPath:@"intCol" ascending:YES]]], @"thread");
        RLMAssertThrowsWithReasonMatching(set[0], @"thread");
        RLMAssertThrowsWithReasonMatching(set[0] = io, @"thread");
        RLMAssertThrowsWithReasonMatching([set valueForKey:@"intCol"], @"thread");
        RLMAssertThrowsWithReasonMatching([set setValue:@1 forKey:@"intCol"], @"thread");
        RLMAssertThrowsWithReasonMatching({for (__unused id obj in set);}, @"thread");
    }];
    [realm cancelWriteTransaction];
}

- (void)testAllMethodsCheckForInvalidation {
    RLMSet<IntObject *> *set = managedTestSet();
    IntObject *io = set.firstObject;
    RLMRealm *realm = set.realm;

    [realm beginWriteTransaction];

    XCTAssertNoThrow([set objectClassName]);
    XCTAssertNoThrow([set realm]);
    XCTAssertNoThrow([set isInvalidated]);

    XCTAssertNoThrow([set count]);
    XCTAssertNoThrow([set objectAtIndex:0]);
    XCTAssertNoThrow([set firstObject]);
    XCTAssertNoThrow([set lastObject]);

    XCTAssertNoThrow([set addObject:io]);
    XCTAssertNoThrow([set addObjects:@[io]]);
    XCTAssertNoThrow([set removeLastObject]);
    XCTAssertNoThrow([set removeAllObjects]);
    [set addObjects:@[io, io, io]];

    XCTAssertNoThrow([set indexOfObject:[IntObject allObjects].firstObject]);
    XCTAssertNoThrow([set indexOfObjectWhere:@"intCol = 0"]);
    XCTAssertNoThrow([set indexOfObjectWithPredicate:[NSPredicate predicateWithFormat:@"intCol = 0"]]);
    XCTAssertNoThrow([set objectsWhere:@"intCol = 0"]);
    XCTAssertNoThrow([set objectsWithPredicate:[NSPredicate predicateWithFormat:@"intCol = 0"]]);
    XCTAssertNoThrow([set sortedResultsUsingKeyPath:@"intCol" ascending:YES]);
    XCTAssertNoThrow([set sortedResultsUsingDescriptors:@[[RLMSortDescriptor sortDescriptorWithKeyPath:@"intCol" ascending:YES]]]);
    XCTAssertNoThrow(set[0]);
    XCTAssertNoThrow(set[0] = io);
    XCTAssertNoThrow([set valueForKey:@"intCol"]);
    XCTAssertNoThrow([set setValue:@1 forKey:@"intCol"]);
    XCTAssertNoThrow({for (__unused id obj in set);});

    [realm cancelWriteTransaction];
    [realm invalidate];
    [realm beginWriteTransaction];
    io = [IntObject createInDefaultRealmWithValue:@[@0]];

    XCTAssertNoThrow([set objectClassName]);
    XCTAssertNoThrow([set realm]);
    XCTAssertNoThrow([set isInvalidated]);

    RLMAssertThrowsWithReasonMatching([set count], @"invalidated");
    RLMAssertThrowsWithReasonMatching([set objectAtIndex:0], @"invalidated");
    RLMAssertThrowsWithReasonMatching([set firstObject], @"invalidated");
    RLMAssertThrowsWithReasonMatching([set lastObject], @"invalidated");

    RLMAssertThrowsWithReasonMatching([set addObject:io], @"invalidated");
    RLMAssertThrowsWithReasonMatching([set addObjects:@[io]], @"invalidated");
    RLMAssertThrowsWithReasonMatching([set removeLastObject], @"invalidated");
    RLMAssertThrowsWithReasonMatching([set removeAllObjects], @"invalidated");

    RLMAssertThrowsWithReasonMatching([set indexOfObject:[IntObject allObjects].firstObject], @"invalidated");
    RLMAssertThrowsWithReasonMatching([set indexOfObjectWhere:@"intCol = 0"], @"invalidated");
    RLMAssertThrowsWithReasonMatching([set indexOfObjectWithPredicate:[NSPredicate predicateWithFormat:@"intCol = 0"]], @"invalidated");
    RLMAssertThrowsWithReasonMatching([set objectsWhere:@"intCol = 0"], @"invalidated");
    RLMAssertThrowsWithReasonMatching([set objectsWithPredicate:[NSPredicate predicateWithFormat:@"intCol = 0"]], @"invalidated");
    RLMAssertThrowsWithReasonMatching([set sortedResultsUsingKeyPath:@"intCol" ascending:YES], @"invalidated");
    RLMAssertThrowsWithReasonMatching([set sortedResultsUsingDescriptors:@[[RLMSortDescriptor sortDescriptorWithKeyPath:@"intCol" ascending:YES]]], @"invalidated");
    RLMAssertThrowsWithReasonMatching(set[0], @"invalidated");
    RLMAssertThrowsWithReasonMatching(set[0] = io, @"invalidated");
    RLMAssertThrowsWithReasonMatching([set valueForKey:@"intCol"], @"invalidated");
    RLMAssertThrowsWithReasonMatching([set setValue:@1 forKey:@"intCol"], @"invalidated");
    RLMAssertThrowsWithReasonMatching({for (__unused id obj in set);}, @"invalidated");

    [realm cancelWriteTransaction];
}

- (void)testMutatingMethodsCheckForWriteTransaction {
    RLMSet<IntObject *> *set = managedTestSet();
    IntObject *io = set.firstObject;

    XCTAssertNoThrow([set objectClassName]);
    XCTAssertNoThrow([set realm]);
    XCTAssertNoThrow([set isInvalidated]);

    XCTAssertNoThrow([set count]);
    XCTAssertNoThrow([set objectAtIndex:0]);
    XCTAssertNoThrow([set firstObject]);
    XCTAssertNoThrow([set lastObject]);

    XCTAssertNoThrow([set indexOfObject:[IntObject allObjects].firstObject]);
    XCTAssertNoThrow([set indexOfObjectWhere:@"intCol = 0"]);
    XCTAssertNoThrow([set indexOfObjectWithPredicate:[NSPredicate predicateWithFormat:@"intCol = 0"]]);
    XCTAssertNoThrow([set objectsWhere:@"intCol = 0"]);
    XCTAssertNoThrow([set objectsWithPredicate:[NSPredicate predicateWithFormat:@"intCol = 0"]]);
    XCTAssertNoThrow([set sortedResultsUsingKeyPath:@"intCol" ascending:YES]);
    XCTAssertNoThrow([set sortedResultsUsingDescriptors:@[[RLMSortDescriptor sortDescriptorWithKeyPath:@"intCol" ascending:YES]]]);
    XCTAssertNoThrow(set[0]);
    XCTAssertNoThrow([set valueForKey:@"intCol"]);
    XCTAssertNoThrow({for (__unused id obj in set);});


    RLMAssertThrowsWithReasonMatching([set addObject:io], @"write transaction");
    RLMAssertThrowsWithReasonMatching([set addObjects:@[io]], @"write transaction");
    RLMAssertThrowsWithReasonMatching([set removeLastObject], @"write transaction");
    RLMAssertThrowsWithReasonMatching([set removeAllObjects], @"write transaction");

    RLMAssertThrowsWithReasonMatching(set[0] = io, @"write transaction");
    RLMAssertThrowsWithReasonMatching([set setValue:@1 forKey:@"intCol"], @"write transaction");
}

- (void)testIsFrozen {
    RLMSet *unfrozen = managedTestSet();
    RLMSet *frozen = [unfrozen freeze];
    XCTAssertFalse(unfrozen.isFrozen);
    XCTAssertTrue(frozen.isFrozen);
}

- (void)testFreezingFrozenObjectReturnsSelf {
    RLMSet *set = managedTestSet();
    RLMSet *frozen = [set freeze];
    XCTAssertNotEqual(set, frozen);
    XCTAssertNotEqual(set.freeze, frozen);
    XCTAssertEqual(frozen, frozen.freeze);
}

- (void)testFreezeFromWrongThread {
    RLMSet *set = managedTestSet();
    [self dispatchAsyncAndWait:^{
        RLMAssertThrowsWithReason([set freeze],
                                  @"Realm accessed from incorrect thread");
    }];
}

- (void)testAccessFrozenFromDifferentThread {
    RLMSet *frozen = [managedTestSet() freeze];
    [self dispatchAsyncAndWait:^{
        XCTAssertEqualObjects([(NSSet *)[frozen valueForKey:@"intCol"] allObjects], (@[@0, @1]));
    }];
}

- (void)testObserveFrozenSet {
    RLMSet *frozen = [managedTestSet() freeze];
    id block = ^(__unused BOOL deleted, __unused NSArray *changes, __unused NSError *error) {};
    RLMAssertThrowsWithReason([frozen addNotificationBlock:block],
                              @"Frozen Realms do not change and do not have change notifications.");
}

- (void)testQueryFrozenArray {
    RLMSet *frozen = [managedTestSet() freeze];
    XCTAssertEqualObjects([[frozen objectsWhere:@"intCol > 0"] valueForKey:@"intCol"], (@[@1]));
}

- (void)testFrozenArraysDoNotUpdate {
    RLMSet *set = managedTestSet();
    RLMSet *frozen = [set freeze];
    XCTAssertEqual(frozen.count, 2);
    [set.realm transactionWithBlock:^{
        [set removeLastObject];
    }];
    XCTAssertEqual(frozen.count, 2);
}

@end
