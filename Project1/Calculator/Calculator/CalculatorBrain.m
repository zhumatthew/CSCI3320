//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Matt Zhu on 1/31/15.
//  Copyright (c) 2015 CS193p. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
@end

@implementation CalculatorBrain

- (NSMutableArray *)programStack
{
    if (!_programStack) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}

- (id)program
{
    return [self.programStack mutableCopy];
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSString *description;
    NSMutableArray *stack = program;
    description = [self obtainStackTerm:stack];
    while ([stack count]) {
        description = [NSString stringWithFormat:@"%@, %@", description, [self obtainStackTerm:stack]];
    }
    
    return description;
}

+ (NSString *)obtainStackTerm:(NSMutableArray *)stack
{
    NSString *description = @"";
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        description = [NSString stringWithFormat:@"%@", topOfStack];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        if ([[self validOperations] containsObject:topOfStack]) {
            NSString *operation = topOfStack;
            if ([operation isEqualToString:@"+"]) {
                id addend = [self obtainStackTerm:stack];
                description = [NSString stringWithFormat:@"(%@ + %@)", [self obtainStackTerm:stack], addend];
            } else if ([@"*" isEqualToString:operation]) {
                id multiplier = [self obtainStackTerm:stack];
                description = [NSString stringWithFormat:@"(%@ * %@)", [self obtainStackTerm:stack], multiplier];
            } else if ([operation isEqualToString:@"-"]) {
                id subtrahend = [self obtainStackTerm:stack];
                description = [NSString stringWithFormat:@"(%@ - %@)", [self obtainStackTerm:stack], subtrahend];
            } else if ([operation isEqualToString:@"/"]) {
                id divisor = [self obtainStackTerm:stack];
                description = [NSString stringWithFormat:@"(%@ / %@)", [self obtainStackTerm:stack], divisor];
                // if divisor
            } else if ([operation isEqualToString:@"sin"]) {
                description = [NSString stringWithFormat:@"sin(%@)", [self obtainStackTerm:stack]];
            } else if ([operation isEqualToString:@"cos"]) {
                description = [NSString stringWithFormat:@"cos(%@)", [self obtainStackTerm:stack]];
            } else if ([operation isEqualToString:@"sqrt"]) {
                description = [NSString stringWithFormat:@"sqrt(%@)", [self obtainStackTerm:stack]];
            } else if ([operation isEqualToString:@"π"]) {
                description = [NSString stringWithFormat:@"π"];
            } else if ([operation isEqualToString:@"+/-"]) {
                NSString *operand = [self obtainStackTerm:stack];
                if ([operand hasPrefix:@"-"]) {
                    description = [operand substringFromIndex:1];
                } else {
                    description = [NSString stringWithFormat:@"-%@", operand];
                }
            }
        } else {
            description = topOfStack;
        }
    }
    return description;
}

- (void)pushOperand:(id)operand
{
    [self.programStack addObject:operand];
}

- (double)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program];
}

- (void)pushOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
}

+ (double)popOperandOffProgramStack:(NSMutableArray *)stack
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffProgramStack:stack] +
            [self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"*"]) {
            result = [self popOperandOffProgramStack:stack] *
            [self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"-"]) {
            double subtrahend = [self popOperandOffProgramStack:stack];
            result = [self popOperandOffProgramStack:stack] - subtrahend;
        } else if ([operation isEqualToString:@"/"]) {
            double divisor = [self popOperandOffProgramStack:stack];
            if (divisor) result = [self popOperandOffProgramStack:stack] / divisor;
        } else if ([operation isEqualToString:@"sin"]) {
            result = sin([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"cos"]) {
            result = cos([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"sqrt"]) {
            result = sqrt([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"π"]) {
            result = M_PI;
        } else if ([operation isEqualToString:@"+/-"]) {
            result = -1 * [self popOperandOffProgramStack:stack];
        }
    }
    
    return result;
}

+ (NSArray *)validOperations
{
    return @[@"+", @"*", @"-", @"/", @"sin", @"cos", @"sqrt", @"π", @"+/-"];
}

+ (double)runProgram:(id)program
{
    return [self runProgram:program usingVariableValues:nil];
}

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    for (int i = 0; i < [stack count]; i++) {
        if ([stack[i] isKindOfClass:[NSString class]]) {
            if (variableValues[stack[i]]) {
                [stack replaceObjectAtIndex:i withObject:variableValues[stack[i]]];
            } else if (![[self validOperations] containsObject:stack[i]]) {
                [stack replaceObjectAtIndex:i withObject:@(0)];
            }
        }
    }
    return [self popOperandOffProgramStack:stack];
}

+ (NSSet *)variablesUsedInProgram:(id)program
{
    NSMutableArray *variables = [[NSMutableArray alloc] init];
    for (id obj in program) {
        if (![[self validOperations] containsObject:obj] && [obj isKindOfClass:[NSString class]]) {
            [variables addObject:obj];
        }
    }
    if ([variables count]) {
        return [NSSet setWithArray:variables];
    }
    return nil;
}

@end