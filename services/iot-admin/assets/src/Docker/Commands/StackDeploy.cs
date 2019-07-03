using System;
using System.Diagnostics;
using System.Threading.Tasks;
using IotStarterKit.Docker;

namespace IotStarterKit.Docker.Commands
{
    public class StackDeploy : Command
    {
        private readonly string _composeFilePath;

        public StackDeploy(string composeFilePath, Target target) : base(target) 
        {
            _composeFilePath = composeFilePath;
        }

        protected override string GetCommandArgs()
        {
            return $"stack deploy -c {_composeFilePath} iotkit";
        }
    }
}