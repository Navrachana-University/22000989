Title: Custom Compiler using Lex and Bison for a Mythology-Inspired Language

--------------------------------------------
Overview:
--------------------------------------------
This compiler project is built using Lex (Flex) and Bison (Yacc) and supports a custom programming language inspired by Indian mythology and gaming terminology.

The compiler:
1. Takes a source code file written in the custom language.
2. Parses the file using Bison grammar.
3. Lexes tokens using Flex rules.
4. Generates intermediate code in the form of **Three Address Code (TAC)**.

--------------------------------------------
Language Keywords Mapping:
--------------------------------------------
Custom Language | Standard Equivalent
----------------|---------------------
yudh            | if
kriya           | else
chakra          | while
arambh          | {
samapt          | }
praapt          | =

This allows the language to feel like a mythological or fantasy game language while functioning like a C-style programming language.

--------------------------------------------
Key Features:
--------------------------------------------
✅ Variable declaration and assignment  
✅ Arithmetic operations: `+`, `-`, `*`, `/`  
✅ Conditional operations: `<`, `>`, `==`, `!=`  
✅ if, else, while control structures  
✅ Block-level grouping using arambh/samapt  
✅ Generation of Three Address Code (TAC)

--------------------------------------------
Lex Code (lexer.l):
--------------------------------------------
- Uses regex to match keywords like `yudh`, `kriya`, etc.
- Recognizes numbers, identifiers, and operators.
- Returns tokens defined in `compiler.y` (Bison file).

Example:
"yudh" { return IF; }
"kriya" { return ELSE; }
"chakra" { return WHILE; }
"praapt" { return ASSIGN; }
[0-9]+ { yylval.num = atoi(yytext); return NUM; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.id = strdup(yytext); return ID; }


--------------------------------------------
Bison Code (compiler.y):
--------------------------------------------
- Defines grammar rules for statements and expressions.
- Builds TAC using temporary variables and labels.
- Uses helper functions:
  - `new_temp()` for generating temporary variables like `t1`, `t2`, ...
  - `new_label()` for labels like `L1`, `L2`, ...
  - `concat()` for string concatenation during code generation.

Supports constructs like:
- Assignment: `x praapt 10;`
- if-else:


--------------------------------------------
Sample Input File (input.txt):
--------------------------------------------


--------------------------------------------
Running Instructions (Linux/macOS Command Line):
--------------------------------------------
1. Save the lexer in `lexer.l`
2. Save the parser in `compiler.y`
3. Create a source code input file (e.g., `input.txt`) with the custom language code.

4. Compile and Run:


This will output the corresponding Three Address Code for the input program.

--------------------------------------------
Notes:
--------------------------------------------
- Use `strdup()` and `malloc()` carefully to manage memory for dynamic strings.
- Ensure your input file is saved with proper UTF-8 encoding if you're using non-ASCII characters in comments.
- This compiler is designed to output human-readable intermediate TAC, making it easier to visualize logic translation.

--------------------------------------------
Future Enhancements (Optional Ideas):
--------------------------------------------
- Add support for functions or procedures.
- Introduce more comparison operators.
- Add symbol table and type checking.
- Support nested control structures.
- Implement backend for assembly or bytecode.

--------------------------------------------
Author:
--------------------------------------------
Anand Patel
3rd Year B.Tech CSE  
Project: Custom Lex+Bison Compiler with Three Address Code  
Language Theme: Mythology + Gaming  
