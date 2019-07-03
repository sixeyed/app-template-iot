using System;
using System.Diagnostics;
using System.Threading.Tasks;
using IotStarterKit.Docker;

namespace IotStarterKit.Docker.Commands
{
    public class StackDeploy : Command
    {
        /*
        bundle stacks
        */

        public StackDeploy(Target target) : base(target) {}

        protected override string GetCommandArgs()
        {
            return "version";
        }
    }
}