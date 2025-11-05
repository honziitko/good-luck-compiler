#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define DEST        "include/randable.h"
#define NUM_STATES  6
#define NUM_SYMBOLS 2

int main(void) {
    unsigned symb, state;
    FILE* out_file;

    srand(time(NULL));
    out_file = fopen(DEST, "w");
    if (out_file == NULL) {
        fprintf(stderr, "Error opening "DEST"\n");
        return 1;
    }
    fprintf(out_file, "#pragma once\n"
            "#include \"glc.h\"\n"
            "namespace glc {\n"
            "template <State, Symbol> struct randable {};\n"
           );
    for (state = 1; state <= NUM_STATES; state++) {
        for (symb = 0; symb < NUM_SYMBOLS; symb++) {
            const int dest_state = rand() % (NUM_STATES + 1);
            const int dest_symbol = rand() % NUM_SYMBOLS;
            const char *direction = rand() % 2 == 0 ? "left" : "right";
            fprintf(out_file, "template<> struct randable<%u, %u> : transition_entry<%d, %d, Direction::%s> {};\n", state, symb, dest_state, dest_symbol, direction);
        }
    }
    fprintf(out_file, "}\n");
    return 0;
}
