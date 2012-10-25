#include "GitObjects.h"
#ifdef WIN32
#else
#include <unistd.h>
#endif

CGitProcess::CGitProcess(const char *cmd, char **args, char *workDir, bool stderr2stdout){
	_cmd = strdup(cmd);
    _args = args;
	_workDir = workDir?strdup(workDir):NULL;
    _stderr2stdout = stderr2stdout;
    _stderr = _stdout = _stdin = 0;
    _pid = 0;
    _running = false;
}

CGitProcess::~CGitProcess(void){
}

void CGitProcess::launch(){
#ifdef WIN32
	//create the pipes for stdout and stderr
	HANDLE stdoutReadTmp=NULL, stdoutRead=NULL, stdoutWrite=NULL, stderrReadTmp=NULL, stderrRead=NULL, stderrWrite=NULL;
	SECURITY_ATTRIBUTES sa; 
	sa.nLength = sizeof(SECURITY_ATTRIBUTES); 
	sa.bInheritHandle = TRUE; 
	sa.lpSecurityDescriptor = NULL; 
	
	CreatePipe(&stdoutReadTmp, &stdoutWrite, &sa, 0);	
	// Create new output read handle. Set
    // the Properties to FALSE. Otherwise, the child inherits the
    // properties and, as a result, non-closeable handles to the pipes
    // are created.
	DuplicateHandle(GetCurrentProcess(),stdoutReadTmp,GetCurrentProcess(),
		&stdoutRead,0,false,DUPLICATE_SAME_ACCESS);
	CloseHandle(stdoutReadTmp);
	if(stderr2stdout){
		DuplicateHandle(GetCurrentProcess(),stdoutWrite,
                           GetCurrentProcess(),&stderrWrite,0,
                           TRUE,DUPLICATE_SAME_ACCESS);
	}else{
		CreatePipe(&stderrReadTmp, &stderrWrite, &sa, 0);
		DuplicateHandle(GetCurrentProcess(),stderrReadTmp,GetCurrentProcess(),
			&stderrRead,0,false,DUPLICATE_SAME_ACCESS);
		CloseHandle(stderrReadTmp);	
	}
	
	_stdout = stdoutRead;
	_stderr = stderrRead;

	//launch the progress
	STARTUPINFO si;
	ZeroMemory(&si,sizeof(si));
	si.cb = sizeof(si);
	si.dwFlags = STARTF_USESTDHANDLES;
	si.hStdOutput = stdoutWrite;
	si.hStdError = stderrWrite;
	//TODO: perhaps would be useful to use the process information returned
	PROCESS_INFORMATION pi;
	ZeroMemory(&pi, sizeof(pi));
    CreateProcess(NULL,		//lpApplicationName
        _cmd,               //lpCommandLine
		NULL,				//lpProcessAttributes
		NULL,				//lpThreadAttributes
		true,				//bInheritHandles
		CREATE_NO_WINDOW,	//dwCreationFlags 
		NULL,				//lpEnvironment
		_workDir,			//lpCurrentDirectory
		&si,				//lpStartupInfo
		&pi);				//lpProcessInformation
	CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);
	// Close pipe handles (do not continue to modify the parent).
    // You need to make sure that no handles to the write end of the
    // output pipe are maintained in this process or else the pipe will
    // not close when the child process exits and the ReadFile will hang.
	CloseHandle(stdoutWrite);
	CloseHandle(stderrWrite);
#else
    int pipe_err[2], pipe_out[2], pipe_in[2];

    if (pipe(pipe_err) || pipe(pipe_out) || pipe(pipe_in)) { // abbreviated error detection
         printf("********pipe");
         return;
    }
    if(_stderr2stdout){
        close(pipe_err[0]);
        close(pipe_err[1]);
        pipe_err[0] = dup(pipe_out[0]);
        pipe_err[1] = dup(pipe_out[1]);
    }

    pid_t pid = fork();
    if (!pid) { // in child
        dup2(pipe_err[1], 2);
        dup2(pipe_out[1], 1);
        dup2(pipe_in[0], 0);
        close(pipe_err[0]);
        close(pipe_err[1]);
        close(pipe_out[0]);
        close(pipe_out[1]);
        close(pipe_in[0]);
        close(pipe_in[1]);

        // close any other files that you don't want the new program
        // to get access to here unless you know that they have the
        // O_CLOEXE bit set
        //printf("_workDir=%s",_workDir);
        if(_workDir) chdir(_workDir);
        execvp(_cmd, _args);
        /* only gets here if there is an error executing the program */
     } else { // in the parent
         if (pid < 0) {
             printf("********fork");
             close(pipe_err[0]);
             close(pipe_err[1]);
             close(pipe_out[0]);
             close(pipe_out[1]);
             close(pipe_in[0]);
             close(pipe_in[1]);
             return;
         }
         _pid = pid;
         _running = true;
         _stderr = pipe_err[0];
         close(pipe_err[1]);
         _stdout = pipe_out[0];
         close(pipe_out[1]);
         _stdin = pipe_in[1];
         close(pipe_in[0]);
    }
#endif
}

char *CGitProcess::grabOutput(){
#define BUF_SIZE 65535
	int maxLen = BUF_SIZE;
	int curLen = 0;
	char *result = (char*)malloc(BUF_SIZE+1);
    long dwRead = 0;
#ifdef WIN32    
	while(ReadFile((HANDLE)_stdout, result+curLen, BUF_SIZE/2, &dwRead, NULL))
#else
    while((dwRead = read(_stdout, result+curLen, BUF_SIZE/2)) > 0)
#endif
    {
		curLen += dwRead;
		if(curLen > maxLen - BUF_SIZE/2){
			char *tmp = (char*)malloc(maxLen+BUF_SIZE+1);
			memcpy(tmp,result,curLen);
			free(result);
			result = tmp;
			maxLen += BUF_SIZE;
		}
	}
	result[curLen] = 0;
	return result;
}

bool CGitProcess::running(bool block){
    int status = 0;
    if(waitpid(_pid, &status, block?0:WNOHANG)){
        _running = false;
        _exitCode = WEXITSTATUS(status);
    }else{
        printf("not yet\n");
    }
	return _running;
}

int CGitProcess::exitCode(){
	return _exitCode;
}

