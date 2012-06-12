using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace GitWrapperUI
{
    class GitRepository : GitObject
    {
        public enum GitRepositoryStatus
        {
            GitRepositoryStatusNone,
            GitRepositoryStatusNoRepository,
            GitRepositoryStatusEmpty,
            GitRepositoryStatusRegular
        }

        private String path;
        private GitRepositoryStatus status;
        private List<GitCommit> commits;
        private List<GitBranch> branches;
        private GitBranch activeBranch;

        public String Path { get { return path; } }
        private GitRepositoryStatus Status { get { return status; } }
        private List<GitCommit> Commits { get { return commits; } }
        private List<GitBranch> Branches { get { return branches; } }
        private GitBranch ActiveBranch { get { return activeBranch; } }

        [DllImport("GitWrapper", EntryPoint = "?CreateCGitCommands@@YAPAXPBD@Z")]
        private static extern IntPtr CreateCGitCommands(String path);

        [DllImport("GitWrapper", EntryPoint="?CreateCGitRepository@@YAPAXPAX@Z")]
        private static extern IntPtr CreateCGitRepository(IntPtr gitCommands);

        [DllImport("GitWrapper", EntryPoint = "?CGitRepository_open@@YAXPAXPBD@Z")]
        private static extern IntPtr CGitRepository_open(IntPtr ptr, String path);

        [DllImport("GitWrapper", EntryPoint = "?CGitRepository_path@@YAPADPAX@Z")]
        private static extern string CGitRepository_path(IntPtr ptr);

        public GitRepository()
            : base(CreateCGitRepository(CreateCGitCommands(@"d:\cygwin\bin\git.exe")))
        {
            
        }

        public void open(String path)
        {
            CGitRepository_open(cppObject, path);
            setupFromCppObject(cppObject);
        }

        protected override void setupFromCppObject(IntPtr cppObject)
        {
        }
    }
}
