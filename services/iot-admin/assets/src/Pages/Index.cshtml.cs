using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Logging;
using IotStarterKit.Docker;
using IotStarterKit.Docker.Commands;

namespace IotStarterKit.Pages
{
    public class IndexModel : PageModel
    {        
        private readonly ILogger _logger;

        public string JenkinsUrl {get; private set;}
        public string JenkinsUsername {get; private set;}
        public string JenkinsPassword {get; private set;}
        public string GitHubUrl {get; private set;}

        public IndexModel(ILogger<IndexModel> logger)
        {
            _logger = logger;

            JenkinsUrl = Secret.Read("jenkins-url");
            JenkinsUsername = Secret.Read("jenkins-username");
            JenkinsPassword = Secret.Read("jenkins-password");

            var githubRepo = Secret.Read("github-repo");
            var githubUser = Secret.Read("github-username");
            GitHubUrl = $"https://github.com/{githubUser}/{githubRepo}.git";
        }      

        public void OnGet()
        {
        }

        
        public void OnPostTest()
        {
            _logger.LogInformation("Running Stack Deploy command on Test Server");
            var cmd = new StackDeploy(Target.TestServer);
            var output = cmd.Run();
            _logger.LogDebug(output);
        }

        public void OnPostLocal()
        {           
            _logger.LogInformation("Running Stack Deploy command on Local Device");
            var cmd = new StackDeploy(Target.LocalDevice);
            var output = cmd.Run();
            _logger.LogDebug(output);
        }
    }
}
