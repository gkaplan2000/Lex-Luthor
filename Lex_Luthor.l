%{
 /* Include stuff if needed */
int line_num = 1;
char string_buf[4096];
#include <stdio.h> 
#include <string.h>
#include <stdlib.h>
#include "token_names.h"
#include "tokens.h"
#include "yylval.h"
YYSTYPE yylval;
%}

/****************************************************/

%option noyywrap
%x string
%x charlit
/****************************************************/

LETTER		[a-zA-Z]
DIGIT		[0-9]
OCT		0[0-7]+
HEX		0[xX][0-9a-fA-F]+
EXP		e[\+-]?{DIGIT}+
PTHANG		p[\+-]?{DIGIT}+

/****************************************************/

%%
	char *string_buf_ptr;
[\n]							{ line_num++; 		}


                     /***** File Name ******/
\#[ ]{DIGIT}[ ]\".+\"[^\n]*				{ return -2;		}
 
                       /***** String *****/
L?[\"]							{ 	memset(string_buf,0,sizeof(string_buf)); 
								string_buf_ptr = string_buf; BEGIN(string); 	}

<string>[\"]						{ BEGIN(INITIAL); *string_buf_ptr = '\0'; return STRING;}

<string>[\n]						{ printf("error: unterminated string constant\n");	}
<string>\\x[0-9a-fA-F]+					{ /* hex escape sequence */
								int result; sscanf(yytext+2, "%x", &result);
								if(result > 0xff) {printf("Warning:Hex escape sequence %x out of range\n", result); result = 0xFF;}
								if(isprint(result)) (void) sprintf(string_buf_ptr++, "%c", result);
								else{
									switch((int) result){
									case 0x07:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'a'; break;
									case 0x08:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'b'; break;
									case 0x0C:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'f'; break;
									case 0x0A:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'n'; break;
									case 0x0D:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'r'; break;
									case 0x09:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 't'; break;
									case 0x0B:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'v'; break;
									case 0x5C:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = '\\'; break;
									case 0x27:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = '\''; break;
									case 0x22:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = '\"'; break;
									case 0x3F:
										*string_buf_ptr++ = '\?'; break;
									default:
										*string_buf_ptr++ = '\\'; sprintf(string_buf_ptr, "%03o", result);
										string_buf_ptr += 3;
										break;
									}
								}
							}

<string>\\\?						{*string_buf_ptr++ = '\?';				}
<string>\\\\						{*string_buf_ptr++ = '\\'; *string_buf_ptr++ = '\\';	}
<string>\\0						{*string_buf_ptr++ = '\\'; *string_buf_ptr++ = '0';	}
<string>\\n						{*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'n';	}
<string>\\t						{*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 't';	}
<string>\\r						{*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'r';	}
<string>\\b						{*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'b';	}
<string>\\f						{*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'f';	}
<string>\\v						{*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'v';	}
<string>\\a						{*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'a';	}
<string>\\\'						{*string_buf_ptr++ = '\\'; *string_buf_ptr++ = '\'';	}
<string>\\\"						{*string_buf_ptr++ = '\\'; *string_buf_ptr++ = '\"';	}
<string>[^\\\n\"]+					{strcpy(string_buf_ptr, yytext); string_buf_ptr = string_buf_ptr + strlen(yytext);}
 
<string>\\[0-7]{1,3}					{ /* octal escape sequence */
								int result; sscanf(yytext+1, "%o", &result);
								if(result > 0xff) {printf("Warning:Octal escape sequence %o out of range\n", result); result = 0xFF;}
								if(isprint(result)) sprintf(string_buf_ptr++, "%c", result);
								else{
									switch((int) result){
									case 0x07:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'a'; break;
									case 0x08:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'b'; break;
									case 0x0C:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'f'; break;
									case 0x0A:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'n'; break;
									case 0x0D:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'r'; break;
									case 0x09:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 't'; break;
									case 0x0B:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'v'; break;
									case 0x5C:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = '\\'; break;
									case 0x27:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = '\''; break;
									case 0x22:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = '\"'; break;
									case 0x3F:
										*string_buf_ptr++ = '\?'; break;
									default:
										*string_buf_ptr++ = '\\'; sprintf(string_buf_ptr, "%03o", result);
										string_buf_ptr += 3;
										break; 
									}
								}
							}

              /******** Char *********/
L?[\']							{ 	memset(string_buf,0,sizeof(string_buf)); 
								string_buf_ptr = string_buf; BEGIN(charlit); 	 }
<charlit>[\']						{ BEGIN(INITIAL); *string_buf_ptr = '\0'; 
								if(string_buf[0] == '\\') return CHARLIT;
								else string_buf[1] = '\0'; printf("Warning:Unsupported multibyte character literal truncated to first byte"); return CHARLIT;}

<charlit>[\n]						{ printf("error: unterminated string constant\n");	}
<charlit>\\x[0-9a-fA-F]+					{ /* hex escape sequence */
								int result; sscanf(yytext+2, "%x", &result);
								if(result > 0xff) {printf("Warning:Hex escape sequence %x out of range\n", result); result = 0xFF;}
								if(isprint(result)) (void) sprintf(string_buf_ptr++, "%c", result);
								else{
									switch((int) result){
									case 0x07:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'a'; break;
									case 0x08:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'b'; break;
									case 0x0C:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'f'; break;
									case 0x0A:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'n'; break;
									case 0x0D:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'r'; break;
									case 0x09:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 't'; break;
									case 0x0B:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'v'; break;
									case 0x5C:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = '\\'; break;
									case 0x27:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = '\''; break;
									case 0x22:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = '\"'; break;
									case 0x3F:
										*string_buf_ptr++ = '\?'; break;
									default:
										*string_buf_ptr++ = '\\'; sprintf(string_buf_ptr, "%03o", result);
										string_buf_ptr += 3;
										break;
									}
								}
							}

<charlit>\\\?						{*string_buf_ptr++ = '\?';				}
<charlit>\\\\						{*string_buf_ptr++ = '\\'; *string_buf_ptr++ = '\\';	}
<charlit>\\0						{*string_buf_ptr++ = '\\'; *string_buf_ptr++ = '0';	}
<charlit>\\n						{*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'n';	}
<charlit>\\t						{*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 't';	}
<charlit>\\r						{*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'r';	}
<charlit>\\b						{*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'b';	}
<charlit>\\f						{*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'f';	}
<charlit>\\v						{*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'v';	}
<charlit>\\a						{*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'a';	}
<charlit>\\\'						{*string_buf_ptr++ = '\\'; *string_buf_ptr++ = '\'';	}
<charlit>\\\"						{*string_buf_ptr++ = '\\'; *string_buf_ptr++ = '\"';	}
<charlit>[^\\\n\']+					{strcpy(string_buf_ptr, yytext); string_buf_ptr = string_buf_ptr + strlen(yytext);}
 
<charlit>\\[0-7]{1,3}					{ /* octal escape sequence */
								int result; sscanf(yytext+1, "%o", &result);
								if(result > 0xff) {printf("Warning:Octal escape sequence %o out of range\n", result); result = 0xFF;}
								if(isprint(result)) sprintf(string_buf_ptr++, "%c", result);
								else{
									switch((int) result){
									case 0x07:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'a'; break;
									case 0x08:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'b'; break;
									case 0x0C:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'f'; break;
									case 0x0A:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'n'; break;
									case 0x0D:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'r'; break;
									case 0x09:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 't'; break;
									case 0x0B:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = 'v'; break;
									case 0x5C:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = '\\'; break;
									case 0x27:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = '\''; break;
									case 0x22:
										*string_buf_ptr++ = '\\'; *string_buf_ptr++ = '\"'; break;
									case 0x3F:
										*string_buf_ptr++ = '\?'; break;
									default:
										*string_buf_ptr++ = '\\'; sprintf(string_buf_ptr, "%03o", result);
										string_buf_ptr += 3;
										break;
									}
								}
							}


	           /****** NUMBERS ******/
0|[1-9]{DIGIT}*						{ yylval.number.yyint = strtol(yytext, NULL, 10); return -4;	}
{HEX}							{ yylval.number.yyint = strtol(yytext, NULL, 16); return -4;	}
{OCT}							{ yylval.number.yyint = strtol(yytext, NULL, 8); return -4;	}
(0|[1-9]{DIGIT}*)[uU]					{ yytext[strlen(yytext)-1] = 0; yylval.number.yyuint = strtol(yytext, NULL, 10); return -5;	} 
{HEX}[uU]						{ yytext[strlen(yytext)-1] = 0; yylval.number.yyuint = strtol(yytext, NULL, 16); return -5;	}
{OCT}[uU]						{ yytext[strlen(yytext)-1] = 0; yylval.number.yyuint = strtol(yytext, NULL, 8); return -5;	}
(0|[1-9]{DIGIT}*)[lL]					{ yytext[strlen(yytext)-1] = 0; yylval.number.yylong = strtol(yytext, NULL, 10); return -6;	}
{HEX}[lL]						{ yytext[strlen(yytext)-1] = 0; yylval.number.yylong = strtol(yytext, NULL, 16); return -6;	}
{OCT}[lL]						{ yytext[strlen(yytext)-1] = 0; yylval.number.yylong = strtol(yytext, NULL, 8); return -6;	}
(0|[1-9]{DIGIT}*)(([uU][lL])|([lL][uU]))		{ yytext[strlen(yytext)-2] = 0; yylval.number.yyulong = strtoul(yytext, NULL, 10); return -7;	}
{HEX}(([uU][lL])|([lL][uU]))				{ yytext[strlen(yytext)-2] = 0; yylval.number.yyulong = strtoul(yytext, NULL, 16); return -7;	}
{OCT}(([uU][lL])|([lL][uU]))				{ yytext[strlen(yytext)-2] = 0; yylval.number.yyulong = strtoul(yytext, NULL, 8); return -7;	}
(0|[1-9]{DIGIT}*)((ll)|(LL))				{ yytext[strlen(yytext)-2] = 0; yylval.number.yylonglong = strtoll(yytext, NULL, 10); return -8;	} 
{HEX}((ll)|(LL))					{ yytext[strlen(yytext)-2] = 0; yylval.number.yylonglong = strtoll(yytext, NULL, 16); return -8;	}
{OCT}((ll)|(LL))					{ yytext[strlen(yytext)-2] = 0; yylval.number.yylonglong = strtoll(yytext, NULL, 8); return -8;		}
(0|[1-9]{DIGIT}*)(([uU]((ll)|(LL)))|(((ll)|(LL))[uU]))	{ yytext[strlen(yytext)-3] = 0; yylval.number.yyulonglong = strtoull(yytext, NULL, 10); return -9;	}
{HEX}(([uU]((ll)|(LL)))|(((ll)|(LL))[uU]))		{ yytext[strlen(yytext)-3] = 0; yylval.number.yyulonglong = strtoull(yytext, NULL, 16); return -9;	}
{OCT}(([uU]((ll)|(LL)))|(((ll)|(LL))[uU]))		{ yytext[strlen(yytext)-3] = 0; yylval.number.yyulonglong = strtoull(yytext, NULL, 8); return -9;	}

{DIGIT}+\.{DIGIT}*{EXP}?				{ yylval.number.yydouble = strtod(yytext, NULL); return -11;	}
{DIGIT}*\.{DIGIT}+{EXP}?				{ yylval.number.yydouble = strtod(yytext, NULL); return -11;	}
{DIGIT}+{EXP}						{ yylval.number.yydouble = strtod(yytext, NULL); return -11;	}
{HEX}{PTHANG}						{ yylval.number.yydouble = strtod(yytext, NULL); return -11;	}

{DIGIT}+\.{DIGIT}*{EXP}?[lL]				{ yytext[strlen(yytext)-1] = 0; yylval.number.yyldouble = strtold(yytext, NULL); return -12;	}
{DIGIT}*\.{DIGIT}+{EXP}?[lL]				{ yytext[strlen(yytext)-1] = 0; yylval.number.yyldouble = strtold(yytext, NULL); return -12;	}
{DIGIT}+{EXP}[lL]					{ yytext[strlen(yytext)-1] = 0; yylval.number.yyldouble = strtold(yytext, NULL); return -12;	}
{HEX}{PTHANG}[lL]					{ yytext[strlen(yytext)-1] = 0; yylval.number.yyldouble = strtold(yytext, NULL); return -12;	}

{DIGIT}+\.{DIGIT}*{EXP}[fF]				{ yytext[strlen(yytext)-1] = 0; yylval.number.yyfloat = strtof(yytext, NULL); return -10;	}
{DIGIT}*\.{DIGIT}+{EXP}[fF]				{ yytext[strlen(yytext)-1] = 0; yylval.number.yyfloat = strtof(yytext, NULL); return -10;	}
{DIGIT}+{EXP}[fF]					{ yytext[strlen(yytext)-1] = 0; yylval.number.yyfloat = strtof(yytext, NULL); return -10;	}
{HEX}{PTHANG}[fF]					{ yytext[strlen(yytext)-1] = 0; yylval.number.yyfloat = strtof(yytext, NULL); return -10;	}





		     /******* OP *******/
[\[\]\{\}\(\)\.\+\-\&\*~!/%\<\>\^\|\?\:\;\,]		{ 	memset(string_buf,0,sizeof(string_buf));
								strcpy(string_buf, yytext); return -3;	}
-\>							{ return INDSEL;	}
\+\+							{ return PLUSPLUS;	}
--							{ return MINUSMINUS;	}
\<\<							{ return SHL;		}
\>\>							{ return SHR;		}
\<=							{ return LTEQ;		}
\>=							{ return GTEQ;		}
==							{ return EQEQ;		}
!=							{ return NOTEQ;		}
&&							{ return LOGAND;	}
\|\|							{ return LOGOR;		}
\.\.\.							{ return ELLIPSIS;	}
\*=							{ return TIMESEQ;	}
\/=							{ return DIVEQ;		}
%=							{ return MODEQ;		}
\+=							{ return PLUSEQ;	}
-=							{ return MINUSEQ;	}
\<\<=							{ return SHLEQ;		}
\>\>=							{ return SHREQ;		}
&=							{ return ANDEQ;		}
\|=							{ return OREQ;		}
\^=							{ return XOREQ;		}

                   /***** Key Words ******/
auto							{ return AUTO;		}
break							{ return BREAK;		}
case							{ return CASE;		}
char							{ return CHAR;		}
const							{ return CONST;		}
continue						{ return CONTINUE;	}
default							{ return DEFAULT;	}
do							{ return DO;		}
double							{ return DOUBLE;	}
else							{ return ELSE;		}
enum							{ return ENUM;		}
extern							{ return EXTERN;	}

float							{ return FLOAT;		}
for							{ return FOR;		}
goto							{ return GOTO;		}
if							{ return IF;		}
inline							{ return INLINE;	}
int							{ return INT;		}
long							{ return LONG;		}
register						{ return REGISTER;	}
restrict						{ return RESTRICT;	}
return							{ return RETURN;	}
short							{ return SHORT;		}
signed							{ return SIGNED;	}
sizeof							{ return SIZEOF;	}
static							{ return STATIC;	}
struct							{ return STRUCT;	}
switch							{ return SWITCH;	}
typedef							{ return TYPEDEF;	}
union							{ return UNION;		}
unsigned						{ return UNSIGNED;	}
void							{ return VOID;		}
volatile						{ return VOLATILE;	}
while							{ return WHILE;		}
_Bool							{ return _BOOL;		}
_Complex						{ return _COMPLEX;	}
_Imaginary						{ return _IMAGINARY;	}

({LETTER}|_)({LETTER}|{DIGIT}|_)*			{ memset(string_buf,0,sizeof(string_buf));
							  strcpy(string_buf, yytext); return IDENT; }
%%

int main(void){
	int t;
	int start = 1;
	char * file_name = (char*) malloc(8191);
	while (t = yylex()){
		if (start == 1){
			strncpy(file_name, yytext, 8191);
			while(*file_name != '\"'){
				file_name++;
			}
			file_name++;
			while(file_name[strlen(file_name)-1] != '\"'){
				file_name[strlen(file_name)-1] = 0;
			}
			file_name[strlen(file_name)-1] = 0;
			line_num--;
			start = 0;		
		}
		else if((t==-2)&&(start == 0)){line_num--;}
		else if (t == 257){
			printf("%s\t%d\t%s\t%s\n", file_name, line_num, token_names[t], string_buf);
		}
		else if (t == 258){
			printf("%s\t%d\t%s\t%s\n", file_name, line_num, token_names[t], string_buf);
		}
		else if (t == 259){
			printf("%s\t%d\t%s\t%s\n", file_name, line_num, token_names[t], string_buf);
		}
		else if((t>260)&&(t<321)){
			printf("%s\t%d\t%s\n", file_name, line_num, token_names[t]);		
		}
		else if (t == -3){
			printf("%s\t%d\t%s\n", file_name, line_num, string_buf);
		}
		else if (t == -4){
			printf("%s\t%d\tNUMBER\tINTEGER\t%d\tINT\n", file_name, line_num, yylval.number.yyint);
		}
		else if (t == -5){
			printf("%s\t%d\tNUMBER\tINTEGER\t%u\tUNSIGNED,INT\n", file_name, line_num, yylval.number.yyuint);
		}
		else if (t == -6){
			printf("%s\t%d\tNUMBER\tINTEGER\t%d\tLONG\n", file_name, line_num, yylval.number.yylong);
		}
		else if (t == -7){
			printf("%s\t%d\tNUMBER\tINTEGER\t%u\tUNSIGNED,LONG\n", file_name, line_num, yylval.number.yyulong);
		}
		else if (t == -8){
			printf("%s\t%d\tNUMBER\tINTEGER\t%d\tLONGLONG\n", file_name, line_num, yylval.number.yylonglong);
		}
		else if (t == -9){
			printf("%s\t%d\tNUMBER\tINTEGER\t%u\tUNSIGNED,LONGLONG\n", file_name, line_num, yylval.number.yyulonglong);
		}
		else if (t == -10){
			if ((yylval.number.yyfloat < 0.01) || (yylval.number.yyfloat > 100)){
				printf("%s\t%d\tNUMBER\tREAL\t%.e\tFLOAT\n", file_name, line_num, yylval.number.yyfloat);
			}
			else{ printf("%s\t%d\tNUMBER\tREAL\t%g\tFLOAT\n", file_name, line_num, yylval.number.yyfloat);}
		}
		else if (t == -11){
			if ((yylval.number.yydouble < 0.01) || (yylval.number.yydouble > 100)){
				printf("%s\t%d\tNUMBER\tREAL\t%.1e\tDOUBLE\n", file_name, line_num, yylval.number.yydouble);
			}
			else{ printf("%s\t%d\tNUMBER\tREAL\t%g\tDOUBLE\n", file_name, line_num, yylval.number.yydouble);}
		}
		else if (t == -12){
			if ((yylval.number.yyldouble < 0.01) || (yylval.number.yyldouble > 100)){
				printf("%s\t%d\tNUMBER\tREAL\t%.1e\tLONGDOUBLE\n", file_name, line_num, yylval.number.yyldouble);
			}
			else{ printf("%s\t%d\tNUMBER\tREAL\t%Lg\tLONGDOUBLE\n", file_name, line_num, yylval.number.yyldouble);}
		}
	}
	/*free(file_name)*/;
}
