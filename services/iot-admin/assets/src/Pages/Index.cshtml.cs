using System;
using System.Collections.Generic;
using io = System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace IotStarterKit.Pages
{
    public class IndexModel : PageModel
    {        
        public string JenkinsUrl {get; private set;}
        public string JenkinsUsername {get; private set;}
        public string JenkinsPassword {get; private set;}

        public string GitHubUrl {get; private set;}

        public IndexModel()
        {
            JenkinsUrl = ReadSecret("jenkins-url");
            JenkinsUsername = ReadSecret("jenkins-username");
            JenkinsPassword = ReadSecret("jenkins-password");

            var githubRepo = ReadSecret("github-repo");
            var githubUser = ReadSecret("github-username");
            GitHubUrl = $"https://github.com/{githubUser}/{githubRepo}.git";
        }      

        public void OnGet()
        {
        }

        private string ReadSecret(string secretName)
        {
            return io.File.ReadAllText($"/run/secrets/{secretName}");
        }
    }
}
