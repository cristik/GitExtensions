#pragma once

typedef enum{
    GitRepositoryStatusNone,
    GitRepositoryStatusNoRepository,
    GitRepositoryStatusEmpty,
    GitRepositoryStatusRegular
}GitRepositoryStatus;

class CGitRepository{
private:
    wchar_t *path;
    GitRepositoryStatus status;
public:
    CGitRepository(void);
    ~CGitRepository(void);
};
