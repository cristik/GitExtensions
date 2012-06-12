using System;
using System.Collections.Generic;
using System.Text;

namespace GitWrapperUI
{
    class GitBranch: GitObject
    {
        private GitRepository repository;
        private String name;
        private String sha1;
        private bool active;

        public GitRepository Repository { get { return repository; } }
        public String Name { get { return Name; } }
        public String Sha1 { get { return sha1; } }
        public bool Active { get { return active; } }
    }
}
