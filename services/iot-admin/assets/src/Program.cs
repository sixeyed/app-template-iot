using System;
using System.Collections.Generic;
using io = System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using IotStarterKit.Docker;

namespace IotStarterKit
{
    public class Program
    {
        public static void Main(string[] args)
        {
            InterpolateTemplatedFiles()
            CreateHostBuilder(args).Build().Run();
        }

        private static void InterpolateTemplatedFiles()
        {
            //fancy name for a hacky method
            var composeFilePath = io.Path.Combine(io.Directory.GetCurrentDirectory(), "stacks", "device.yml");
            var stack = io.File.ReadAllText(composeFilePath);
            stack = stack.Replace("{server-dns}", Secret.Read("server-dns"));
            io.File.WriteAllText(composeFilePath, stack);
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStartup<Startup>();
                });
    }
}
