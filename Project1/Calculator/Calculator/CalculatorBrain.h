//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Matt Zhu on 1/31/15.
//  Copyright (c) 2015 CS193p. All rights reserved.
//

//#import <Foundation/Foundation.h>
//
//@interface CalculatorBrain : NSObject
//
//- (void)pushOperand:(double)operand;
//- (double)performOperation:(NSString *)operation;
//
//@end

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(id)operand;
- (double)performOperation:(NSString *)op;
- (void)pushOperation:(NSString *)op;


@property (nonatomic, readonly) id program;

+ (NSString *)descriptionOfProgram:(id)program;
+ (double)runProgram:(id)program;
+ (double)runProgram:(id)program
 usingVariableValues:(NSDictionary *)variableValues;
+ (NSSet *)variablesUsedInProgram:(id)program;

@end
