#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include <string.h>
#include <stdarg.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>

enum iris_value_type {
  IRIS_T_INT = 0x00,
  IRIS_T_FLOAT,
  IRIS_T_BOOL,
  IRIS_T_CHAR,
  IRIS_T_FUNCTION,
  IRIS_T_UNIT,
};

#define T_INT IRIS_T_INT
#define T_FLOAT IRIS_T_FLOAT
#define T_BOOL IRIS_T_BOOL
#define T_CHAR IRIS_T_CHAR
#define T_FUNCTION IRIS_T_FUNCTION
#define T_UNIT IRIS_T_UNIT

/*
 * Consider using a union instead.
 */
struct value_t {
  int type_val;
  long int_val;       /* Iris Int value */
  double float_val;   /* Iris Float value */
  bool bool_val;      /* Iris Bool value */
  char char_val;      /* Iris Char value */

  /* Iris Function value */
  struct value_t *(*function_val)(struct value_t *);
};

char
*string_of_bool(bool b)
{
  return (b != 0) ? "true" : "false";
}

void
print_value(struct value_t *v)
{
  /* avoid segfaults */
  if (v == NULL)
  {
    printf("Unit = ()");
    return;
  }

  switch (v->type_val)
  {
    case T_INT:
      printf("Int = %ld", v->int_val);
      break;
    case T_FLOAT:
      printf("Float = %f", v->float_val);
      break;
    case T_BOOL:
      printf("Bool = %s", string_of_bool(v->bool_val));
      break;
    case T_CHAR:
      printf("Char = %c", v->char_val);
      break;
    case T_FUNCTION:
      printf("Function = <fun>");
      break;
    case T_UNIT:
      printf("Unit = ()");
      break;
    default:
      printf("Unknown type: %d", v->type_val);
  }
}

value
box_value(struct value_t *v)
{
  value int_block = caml_alloc(1, T_INT);
  value float_block = caml_alloc(1, T_FLOAT);
  value float_value = caml_alloc(1, Double_tag);
  value bool_block = caml_alloc(1, T_BOOL);
  value char_block = caml_alloc(1, T_CHAR);

  switch (v->type_val)
  {
    case T_INT:
      Store_field(int_block, 0, Val_long(v->int_val));
      return int_block;
    case T_FLOAT:
      Store_double_field(float_value, 0, v->float_val);
      Store_field(float_block, 0, float_value);
      return float_block;
    case T_BOOL:
      Store_field(bool_block, 0, Val_int(!!v->bool_val));
      return bool_block;
    case T_CHAR:
      Store_field(char_block, 0, Val_int(v->char_val));
      return char_block;
    case T_UNIT:
      return Val_int(0);
    default:
      printf("Don't know how to box type: %d", v->type_val);
      exit(1); /* exit with error */
  }
}

value
unbox_value(value ptr_value)
{
  CAMLparam1(ptr_value);
  struct value_t *v = (struct value_t *) ptr_value;
  CAMLreturn(box_value(v));
}
