using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;

namespace GitWrapperUI
{
    class GitBranch: GitObject
    {
        private GitRepository repository;
        private String name;
        private String sha1;
        private bool active;

        public GitRepository Repository { get { return repository; } }
        public String Name { get { return name; } }
        public String Sha1 { get { return sha1; } }
        public bool Active { get { return active; } }

        [DllImport("GitWrapper", EntryPoint = "?CGitBranch_name@@YAPBDPAX@Z")]
        private static extern string CGitBranch_name(IntPtr ptr);

        [DllImport("GitWrapper", EntryPoint = "?CGitBranch_sha1@@YAPBDPAX@Z")]
        private static extern string CGitBranch_sha1(IntPtr ptr);

        [DllImport("GitWrapper", EntryPoint = "?CGitBranch_active@@YA_NPAX@Z")]
        private static extern bool CGitBranch_active(IntPtr ptr);

        public GitBranch(GitRepository repository, IntPtr cppObject)
            : base(cppObject)
        {
            this.repository = repository;
        }

        protected override void setupFromCppObject(IntPtr cppObject)
        {
            name = CGitBranch_name(cppObject);
            sha1 = CGitBranch_sha1(cppObject);
            active = CGitBranch_active(cppObject);
        }
    }
}
