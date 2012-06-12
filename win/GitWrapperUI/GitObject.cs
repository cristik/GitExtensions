using System;
using System.Collections.Generic;
using System.Text;

namespace GitWrapperUI
{
    class GitObject
    {
        protected IntPtr cppObject;

        public GitObject(IntPtr cppObject)
        {
            this.cppObject = cppObject;
            setupFromCppObject(cppObject);
        }

        public GitObject()
        {
        }

        protected virtual void setupFromCppObject(IntPtr cppObject)
        {
        }
    }
}
