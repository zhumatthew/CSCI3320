//
//  ViewController.m
//  Calculator
//
//  Created by Matt Zhu on 1/28/15.
//  Copyright (c) 2015 CS193p. All rights reserved.
//

#import "ViewController.h"
#import "CalculatorBrain.h"

@interface ViewController ()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL decimalPresent;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (weak, nonatomic) IBOutlet UILabel *variablesLabel;
@property (nonatomic, strong) NSDictionary *testVariableValues;
@end

@implementation ViewController

- (IBAction)backspace
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        if ([self.display.text hasSuffix:@"."]) {
            self.decimalPresent = NO;
        }
        self.display.text = [self.display.text substringToIndex:self.display.text.length - 1];
        
        if (self.display.text.length == 0) {
            self.userIsInTheMiddleOfEnteringANumber = NO;
            self.display.text = @"0";
        }
    }
    self.descriptionLabel.text = [[self.brain class] descriptionOfProgram:self.brain.program];
}

- (IBAction)clear
{
    self.display.text = nil;
    self.variablesLabel.text = nil;
    self.descriptionLabel.text = nil;
    self.brain = nil;
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.decimalPresent = NO;
}

- (CalculatorBrain *)brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (IBAction)digitPressed:(UIButton *)sender
{
    NSString *digit = [sender currentTitle];
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
    self.descriptionLabel.text = [[self.brain class] descriptionOfProgram:self.brain.program];
}

- (IBAction)decimalPressed
{
    if (!self.decimalPresent) {
        self.decimalPresent = YES;
        if (self.userIsInTheMiddleOfEnteringANumber) {
            self.display.text = [self.display.text stringByAppendingString:@"."];
        } else {
            self.display.text = @".";
            self.userIsInTheMiddleOfEnteringANumber = YES;
        }
    }
    self.descriptionLabel.text = [[self.brain class] descriptionOfProgram:self.brain.program];
}

- (IBAction)makeOpposite
{
    // change history label as well
    if ([self.display.text hasPrefix:@"-"]) {
        self.display.text = [self.display.text substringFromIndex:1];

    } else {
        self.display.text = [NSString stringWithFormat:@"-%@", self.display.text];
    }
    self.descriptionLabel.text = [[self.brain class] descriptionOfProgram:self.brain.program];
}


- (IBAction)operationPressed:(UIButton *)sender
{
    NSString *operation = sender.currentTitle;
    if (self.userIsInTheMiddleOfEnteringANumber && ![operation isEqualToString:@"+/-"]) {
        [self enterPressed];
    }
    [self.brain pushOperation:operation];
    double result = [[self.brain class] runProgram:self.brain.program usingVariableValues:self.testVariableValues];
    self.display.text = [NSString stringWithFormat:@"%g", result];
    self.descriptionLabel.text = [[self.brain class] descriptionOfProgram:self.brain.program];
}

- (IBAction)enterPressed
{
    double text = [self.display.text doubleValue];
    if (text) {
        [self.brain pushOperand:@(text)];
    } else {
        [self.brain pushOperand:self.display.text];
    }
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.decimalPresent = NO;
    self.descriptionLabel.text = [[self.brain class] descriptionOfProgram:self.brain.program];
    [self updateUI];
}

- (IBAction)variablePressed:(UIButton *)sender
{
    NSString *variable = [sender currentTitle];
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:variable];
    } else {
        self.display.text = variable;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
    self.descriptionLabel.text = [[self.brain class] descriptionOfProgram:self.brain.program];
    [self updateUI];
}

- (void)updateUI
{
    NSString *variables = @"";
    for (NSString *variable in [CalculatorBrain variablesUsedInProgram:self.brain.program]) {
        variables = [NSString stringWithFormat:@"%@ %@ = %@ ", variables, variable, self.testVariableValues[variable] ? self.testVariableValues[variable] : @(0)];
    }
    self.variablesLabel.text = variables;
}

- (IBAction)presetPressed:(UIButton *)sender
{
    int preset = [[sender currentTitle] intValue];
    switch (preset) {
        case 1:
            self.testVariableValues = @{ @"a" : @(4.8), @"b" : @(5.0), @"r" : @(2.3), @"x" : @(7.8)};
            break;
        case 2:
            self.testVariableValues = @{ @"a" : @(3.3), @"b" : @(1.5), @"r" : @(2.3), @"x" : @(2.8)};
            break;
        case 3:
            self.testVariableValues = @{ @"a" : @(0.8), @"b" : @(5.0), @"r" : @(9.0), @"x" : @(1.8)};
            break;
        default:
            self.testVariableValues = nil;
            break;
    }
    [self updateUI];
}

@end
