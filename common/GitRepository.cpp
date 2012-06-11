#include "GitObjects.h"
#include <wchar.h>

CGitRepository::CGitRepository(char *path){
    this->path = strdup(path);
}

CGitRepository::~CGitRepository(void){
}
