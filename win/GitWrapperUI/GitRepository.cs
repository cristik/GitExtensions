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
        public GitRepositoryStatus Status { get { return status; } }
        public List<GitCommit> Commits { get { return commits; } }
        public List<GitBranch> Branches { get { return branches; } }
        public GitBranch ActiveBranch { get { return activeBranch; } }

        [DllImport("GitWrapper", EntryPoint = "?CreateCGitCommands@@YAPAXPBD@Z")]
        private static extern IntPtr CreateCGitCommands(String path);

        [DllImport("GitWrapper", EntryPoint="?CreateCGitRepository@@YAPAXPAX@Z")]
        private static extern IntPtr CreateCGitRepository(IntPtr gitCommands);

        [DllImport("GitWrapper", EntryPoint = "?CGitRepository_open@@YAXPAXPBD@Z")]
        private static extern IntPtr CGitRepository_open(IntPtr ptr, String path);

        [DllImport("GitWrapper", EntryPoint = "?CGitRepository_path@@YAPADPAX@Z")]
        private static extern string CGitRepository_path(IntPtr ptr);

        [DllImport("GitWrapper", EntryPoint = "?CGitRepository_branches@@YAPAXPAXPAH@Z")]
        private static extern IntPtr CGitRepository_branches(IntPtr ptr, out int len);

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
            branches = new List<GitBranch>();
            int len;
            IntPtr cppData = CGitRepository_branches(cppObject, out len);
            if (len > 0)
            {
                IntPtr[] cppBranches = new IntPtr[len];
                Marshal.Copy(cppData, cppBranches, 0, len);
                foreach (IntPtr cppBranch in cppBranches)
                {
                    branches.Add(new GitBranch(this, cppBranch));
                }
            }            
        }
    }
}
