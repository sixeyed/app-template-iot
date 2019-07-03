using System;
using System.Diagnostics;
using System.Threading.Tasks;
using IotStarterKit.Docker;

namespace IotStarterKit.Docker.Commands
{
    public class StackRemove : Command
    {
        public StackRemove(Target target) : base(target) {}

        protected override string GetCommandArgs()
        {
            return $"stack rm iotkit";
        }
    }
}