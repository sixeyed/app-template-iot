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
            JenkinsUrl = io.File.ReadAllText("/jenkins-url");
            JenkinsUsername = io.File.ReadAllText("/run/secrets/jenkins-username");
            JenkinsPassword = io.File.ReadAllText("/run/secrets/jenkins-password");

            var githubRepo = io.File.ReadAllText("/github-repo");
            var githubUser = io.File.ReadAllText("/github-username");
            GitHubUrl = $"https://github.com/{githubRepo}/{githubUser}.git";
        }      

        public void OnGet()
        {
        }
    }
}
