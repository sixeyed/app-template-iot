using System;
using System.Diagnostics;
using System.Threading.Tasks;

namespace IotStarterKit.Docker.Commands
{
    public abstract class Command
    {
        private readonly string _host;
        private readonly string _certPath;
        public Target Target {get; private set;}

        protected abstract string GetCommandArgs();

        public Command(Target target)
        {
            Target= target;
            switch(target)
            {
                case Target.TestServer:
                    _host = Secret.Read("server-dns");
                    _certPath = "/certs/server";
                    break;
                case Target.LocalDevice:
                    _host = Secret.Read("device-ip");
                    _certPath = "/certs/device";
                    break;
            }
        }

        public string Run() 
        {
            var hostArgs = $"--host tcp://{_host}:2376 --tlsverify --tlscacert {_certPath}/ca.pem --tlscert {_certPath}/cert.pem --tlskey {_certPath}/key.pem";
            var commandArgs = GetCommandArgs();
                        
            var process = new Process
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = "docker",
                    Arguments = $"{hostArgs} {commandArgs}",
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    RedirectStandardError = false,
                    CreateNoWindow = true
                }

            };
            process.Start();
            var output = process.StandardOutput.ReadToEnd();            
            
            process.WaitForExit();
            return output;
        }
    }
}