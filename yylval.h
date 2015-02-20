#ifndef _YYLVAL_H
#define _YYLVAL_H

enum type_o_thing{
	TYPE_INT,
	TYPE_DOUBLE,
	TYPE_FLOAT,
	TYPE_LONG,
	TYPE_LONGLONG,
	TYPE_SIGNED,
	TYPE_UNSIGNED
};
typedef union {
	struct string{
		char* yystring;
		int str_len;
	}word;
		
	struct number{
		int yyint;
		unsigned int yyuint;
		long yylong;
		unsigned long yyulong;
		long long yylonglong;
		unsigned long long yyulonglong;
		double yydouble;
		float yyfloat;
		long double yyldouble;
		enum type_o_thing num_type;
		enum type_o_thing num_sign;
	}number;

} YYSTYPE;

extern YYSTYPE yylval;

#endif
