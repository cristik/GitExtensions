#pragma once
#ifndef GitExtensions_GitProcess_h_
#define GitExtensions_GitProcess_h_

class CGitProcess
{
private:
	char *_cmd;
    char *_args;
	char *_workDir;
    bool _stderr2stdout;
	int _stdin;
	int _stdout;
	int _stderr;
	bool _running;
	int _pid;
	int _exitCode;
	
public:
	CGitProcess(char *cmd, char *args[], char *workDir = NULL, bool stderr2stdout = false);
	~CGitProcess(void);

	void launch();
	char *grabOutput();

	bool running();
	int exitCode();
};

#endif