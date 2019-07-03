using System;
using System.IO;

namespace IotStarterKit.Docker
{
    public static class Secret
    {
        public static string Read(string secretName, bool trim=true)
        {
            var secret = File.ReadAllText($"/run/secrets/{secretName}");
            return trim ? secret.Trim() : secret;
        }
    }
}
