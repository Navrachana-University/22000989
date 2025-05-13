%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int temp_count = 0;
int label_count = 0;
extern FILE* yyin; // input file handle from Flex

// Function to create a new temporary variable
char* new_temp() {
    char* temp = malloc(10);
    sprintf(temp, "t%d", temp_count++);
    return temp;
}

// Function to create a new label
char* new_label() {
    char* label = malloc(10);
    sprintf(label, "L%d", label_count++);
    return label;
}

// Function to concatenate strings with dynamic allocation
char* concat(const char* s1, const char* s2) {
    char* result = malloc(strlen(s1) + strlen(s2) + 1);
    strcpy(result, s1);
    strcat(result, s2);
    return result;
}

void yyerror(const char* s) {
    printf("Error: %s\n", s);
}

int yylex();
%}

%union {
    int num;
    char* id;
    struct {
        char* code;  // Code to be executed before using the place
        char* place; // Name of the variable/temp holding the result
    } expr;
    char* stmt_code; // Code for statements
}

%expect 16

%token IF ELSE WHILE LBRACE RBRACE ASSIGN
%token LT GT EQ NE PLUS MINUS MUL DIV
%token SEMICOLON LPAREN RPAREN
%token <num> NUM
%token <id> ID

%type <expr> expression
%type <expr> condition
%type <stmt_code> statement
%type <stmt_code> statement_list

%%

program:
    statement_list
    {
        printf("%s", $1 ? $1 : "");
    }
    ;

statement_list:
    statement_list statement
    {
        if ($1 && $2) {
            $$ = concat($1, $2);
            free($1);
            free($2);
        } else if ($1) {
            $$ = $1;
        } else if ($2) {
            $$ = $2;
        } else {
            $$ = strdup("");
        }
    }
    |
    /* empty */
    {
        $$ = strdup("");
    }
    ;

statement:
    IF LPAREN condition RPAREN LBRACE statement_list RBRACE
    {
        char* l1 = new_label();
        char* l2 = new_label();
        char buffer[1024];
        
        // Generate code with proper order
        sprintf(buffer, "%s"              // Condition evaluation code
                       "if %s goto %s\n"  // Branch if condition is true
                       "goto %s\n"        // Otherwise skip the block
                       "%s:\n"            // Start of if block
                       "%s"               // If block code
                       "%s:\n",           // End label
                $3.code ? $3.code : "",
                $3.place, l1,
                l2,
                l1,
                $6 ? $6 : "",
                l2);
        
        $$ = strdup(buffer);
        free($6);
        if ($3.code) free($3.code);
    }
    |
    IF LPAREN condition RPAREN LBRACE statement_list RBRACE ELSE LBRACE statement_list RBRACE
    {
        char* l1 = new_label();
        char* l2 = new_label();
        char* l3 = new_label();
        char buffer[1024];
        
        // Generate code with proper order
        sprintf(buffer, "%s"              // Condition evaluation code
                       "if %s goto %s\n"  // Branch if condition is true
                       "goto %s\n"        // Otherwise go to else
                       "%s:\n"            // Start of if block
                       "%s"               // If block code
                       "goto %s\n"        // Skip else after executing if
                       "%s:\n"            // Start of else block
                       "%s"               // Else block code
                       "%s:\n",           // End label
                $3.code ? $3.code : "",
                $3.place, l1,
                l2,
                l1,
                $6 ? $6 : "",
                l3,
                l2,
                $10 ? $10 : "",
                l3);
        
        $$ = strdup(buffer);
        free($6);
        free($10);
        if ($3.code) free($3.code);
    }
    |
    WHILE LPAREN condition RPAREN LBRACE statement_list RBRACE
    {
        char* l1 = new_label();
        char* l2 = new_label();
        char* l3 = new_label();
        char buffer[1024];
        
        // Generate code with proper order for while loop
        sprintf(buffer, "%s:\n"           // Loop start label
                       "%s"               // Condition evaluation code
                       "if %s goto %s\n"  // Branch if condition is true
                       "goto %s\n"        // Otherwise exit loop
                       "%s:\n"            // Start of loop body
                       "%s"               // Loop body code
                       "goto %s\n"        // Jump back to condition check
                       "%s:\n",           // Exit label
                l1,
                $3.code ? $3.code : "",
                $3.place, l2,
                l3,
                l2,
                $6 ? $6 : "",
                l1,
                l3);
        
        $$ = strdup(buffer);
        free($6);
        if ($3.code) free($3.code);
    }
    |
    ID ASSIGN expression SEMICOLON
    {
        char buffer[1024];
        
        // Generate code with proper order
        sprintf(buffer, "%s"           // Expression evaluation code
                       "%s = %s\n",    // Assignment statement
                $3.code ? $3.code : "",
                $1, $3.place);
        
        $$ = strdup(buffer);
        free($1);
        if ($3.code) free($3.code);
    }
    ;

condition:
    expression LT expression
    {
        char* temp = new_temp();
        char buffer[1024];
        
        // Concatenate both expression codes and add comparison
        sprintf(buffer, "%s"           // Left expression code
                       "%s"           // Right expression code
                       "%s = %s < %s\n", // Comparison operation
                $1.code ? $1.code : "",
                $3.code ? $3.code : "",
                temp, $1.place, $3.place);
        
        $$.code = strdup(buffer);
        $$.place = temp;
        if ($1.code) free($1.code);
        if ($3.code) free($3.code);
    }
    |
    expression GT expression
    {
        char* temp = new_temp();
        char buffer[1024];
        
        // Concatenate both expression codes and add comparison
        sprintf(buffer, "%s"           // Left expression code
                       "%s"           // Right expression code
                       "%s = %s > %s\n", // Comparison operation
                $1.code ? $1.code : "",
                $3.code ? $3.code : "",
                temp, $1.place, $3.place);
        
        $$.code = strdup(buffer);
        $$.place = temp;
        if ($1.code) free($1.code);
        if ($3.code) free($3.code);
    }
    |
    expression EQ expression
    {
        char* temp = new_temp();
        char buffer[1024];
        
        // Concatenate both expression codes and add comparison
        sprintf(buffer, "%s"           // Left expression code
                       "%s"           // Right expression code
                       "%s = %s == %s\n", // Comparison operation
                $1.code ? $1.code : "",
                $3.code ? $3.code : "",
                temp, $1.place, $3.place);
        
        $$.code = strdup(buffer);
        $$.place = temp;
        if ($1.code) free($1.code);
        if ($3.code) free($3.code);
    }
    |
    expression NE expression
    {
        char* temp = new_temp();
        char buffer[1024];
        
        // Concatenate both expression codes and add comparison
        sprintf(buffer, "%s"           // Left expression code
                       "%s"           // Right expression code
                       "%s = %s != %s\n", // Comparison operation
                $1.code ? $1.code : "",
                $3.code ? $3.code : "",
                temp, $1.place, $3.place);
        
        $$.code = strdup(buffer);
        $$.place = temp;
        if ($1.code) free($1.code);
        if ($3.code) free($3.code);
    }
    |
    expression /* Allow expressions to be conditions */
    {
        $$.code = $1.code;
        $$.place = $1.place;
    }
    ;

expression:
    expression PLUS expression
    {
        char* temp = new_temp();
        char buffer[1024];
        
        // Concatenate both expression codes and add addition
        sprintf(buffer, "%s"           // Left expression code
                       "%s"           // Right expression code
                       "%s = %s + %s\n", // Addition operation
                $1.code ? $1.code : "",
                $3.code ? $3.code : "",
                temp, $1.place, $3.place);
        
        $$.code = strdup(buffer);
        $$.place = temp;
        if ($1.code) free($1.code);
        if ($3.code) free($3.code);
    }
    |
    expression MINUS expression
    {
        char* temp = new_temp();
        char buffer[1024];
        
        // Concatenate both expression codes and add subtraction
        sprintf(buffer, "%s"           // Left expression code
                       "%s"           // Right expression code
                       "%s = %s - %s\n", // Subtraction operation
                $1.code ? $1.code : "",
                $3.code ? $3.code : "",
                temp, $1.place, $3.place);
        
        $$.code = strdup(buffer);
        $$.place = temp;
        if ($1.code) free($1.code);
        if ($3.code) free($3.code);
    }
    |
    expression MUL expression
    {
        char* temp = new_temp();
        char buffer[1024];
        
        // Concatenate both expression codes and add multiplication
        sprintf(buffer, "%s"           // Left expression code
                       "%s"           // Right expression code
                       "%s = %s * %s\n", // Multiplication operation
                $1.code ? $1.code : "",
                $3.code ? $3.code : "",
                temp, $1.place, $3.place);
        
        $$.code = strdup(buffer);
        $$.place = temp;
        if ($1.code) free($1.code);
        if ($3.code) free($3.code);
    }
    |
    expression DIV expression
    {
        char* temp = new_temp();
        char buffer[1024];
        
        // Concatenate both expression codes and add division
        sprintf(buffer, "%s"           // Left expression code
                       "%s"           // Right expression code
                       "%s = %s / %s\n", // Division operation
                $1.code ? $1.code : "",
                $3.code ? $3.code : "",
                temp, $1.place, $3.place);
        
        $$.code = strdup(buffer);
        $$.place = temp;
        if ($1.code) free($1.code);
        if ($3.code) free($3.code);
    }
    |
    ID
    {
        $$.code = strdup(""); // No code needed for ID reference
        $$.place = $1;
    }
    |
    NUM
    {
        char* temp = malloc(10);
        sprintf(temp, "%d", $1);
        $$.code = strdup(""); // No code needed for number
        $$.place = temp;
    }
    |
    LPAREN expression RPAREN
    {
        $$.code = $2.code;
        $$.place = $2.place;
    }
    ;

%%

int main(int argc, char** argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("Cannot open input file");
            return 1;
        }
    }
    yyparse();
    return 0;
}