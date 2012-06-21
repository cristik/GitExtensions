using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace GitWrapperUI
{
    public partial class MainForm : Form
    {
        GitRepository repository = new GitRepository();
        public MainForm()
        {
            InitializeComponent();
            repository.open(@"d:\Projects\Memeo\PersonalSpace\git\personal-space");
            gitBranchBindingSource.DataSource = repository.Branches;
        }
    }
}
