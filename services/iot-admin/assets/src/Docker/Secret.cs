using System;
using System.IO;

namespace IotStarterKit.Docker
{
    public static class Secret
    {
        public static string Read(string secretName)
        {
            return File.ReadAllText($"/run/secrets/{secretName}");
        }
    }
}
