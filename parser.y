%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <math.h>
    
    int tempCounter = 1;
    char sign[50];
    double vars[26];
    double temps[1000];
    
    extern int yylex();
    extern FILE *yyin;
    extern FILE *yyout;

 
    int reverse(int number) {
        int reversed = 0;
        while (number != 0) {
            reversed = reversed * 10 + (number % 10);
            number /= 10;
        }
        return reversed;
    }

   
    double needReverese(double value) {
        
        int sign = (value < 0) ? -1 : 1;
        double absVal = fabs(value);
    
        int intPart = (int)absVal;          


        if (intPart != 0 && (intPart % 10) != 0) {
            intPart = reverse(intPart);
        }
        
        return sign * (intPart);
    }

  
    double getValue(const char* str) {
        if(str[0] == 't') {
            int index = atoi(str+1);
            return temps[index];
        } else if(str[0] >= 'a' && str[0] <= 'z') {
            return vars[str[0] - 'a'];
        } else {
            return atof(str);
        }
    }

    void yyerror(char *msg) {
        fprintf(stderr, "Parser error: %s\n", msg);
        exit(1);
    }

%}

%start program

%union {
    char id[500];
    char num[500];
    char nonTerminal[500];
}

%token <num> NUM
%token <id>  ID
%token ADD SUB MUL DIV
%token SEMICOLON
%token LPAREN RPAREN
%token UMINUS

%type <nonTerminal> program stmt expr assignment

%right '='   
%left  MUL DIV
%right ADD SUB
%right UMINUS

%%
program 
  : stmt
  | program stmt
  ;

stmt
  : expr SEMICOLON         
    {
      printf("Statement completed\n");
    }
  | assignment SEMICOLON   
    {
      printf("Statement completed\n");
    }
  
  ;

assignment
  : ID '=' expr
    {
       double val = getValue($3);
       vars[$1[0] - 'a'] = val;
       printf("%s = %s \n",  $1, $3);
       printf("%d;\n", (int)val);
    }
  

expr : expr ADD expr 
    {
      sprintf($$, "t%d", tempCounter);
      double val1 = getValue($1);
      double val2 = getValue($3);
      double result  = val1 + val2;
      double finalResult  = needReverese(result);

      temps[tempCounter] = finalResult;
   
      printf("%s = %s + %s;\n", $$, $1, $3);
      tempCounter++;
    }
  
  | expr SUB expr
    {
      sprintf($$, "t%d", tempCounter);
      double val1 = getValue($1);
      double val2 = getValue($3);
      double result  = val1 - val2;
      double finalResult  = needReverese(result);

      temps[tempCounter] = finalResult;
    
      printf("%s = %s - %s;\n", $$, $1, $3);
      tempCounter++;
    }
    
  | expr DIV expr
    {
      sprintf($$, "t%d", tempCounter);
      double val1 = getValue($1);
      double val2 = getValue($3);

      if(val2 == 0) {
        fprintf(stderr, "Division by zero error\n");
        exit(1);
      }

      double result  = val1 / val2;
      double finalResult  = needReverese(result);

      temps[tempCounter] = finalResult;
      printf("%s = %s / %s;\n", $$, $1, $3);
      tempCounter++;
    }
  
  | expr MUL expr
    {
      sprintf($$, "t%d", tempCounter);
      double val1 = getValue($1);
      double val2 = getValue($3);
      double result  = val1 * val2;
      double finalResult  = needReverese(result);

      temps[tempCounter] = finalResult;
      printf("%s = %s * %s;\n", $$, $1, $3);
      tempCounter++;
    }
  
  | LPAREN expr RPAREN
    {
      strcpy($$, $2);
    }

  | NUM
    {
      double result = atof($1);
      double number = needReverese(result);
      sprintf($$, "%g", number);
    }
  
  | ID
    {
      strcpy($$, $1);
    }
  
  | SUB expr %prec UMINUS
    {
      sprintf($$, "t%d", tempCounter);
      double val2 = getValue($2);
      double result  = -val2;
      double finalResult  = needReverese(result);

      temps[tempCounter] = finalResult;
      printf("%s = -%s;\n", $$, $2);
      tempCounter++;
    }
  ;

%%

int main(int argc, char **argv) {
    memset(vars, 0, sizeof(vars));
    memset(temps, 0, sizeof(temps));
    
    if (argc > 1) {
        if (!(yyin = fopen(argv[1], "r"))) {
            perror(argv[1]);
            return 1;
        }
    }

    yyparse();
    
    if (argc > 1) {
        fclose(yyin);
    }
    
    return 0;
}
