using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;

namespace Device
{
    class Program
    {
        private static Random _Random = new Random();        
        private static ManualResetEvent _ResetEvent = new ManualResetEvent(false);
        private static readonly HttpClient _Client = new HttpClient();

        private static Timer _Timer;
        private static string _DeviceId;
        public static IConfiguration _Config;

        static async Task Main(string[] args)
        {
            _DeviceId = _Random.Next().ToString();

            _Config = new ConfigurationBuilder()
                            .AddJsonFile("appsettings.json")
                            .AddEnvironmentVariables()
                            .Build();

            _Client.DefaultRequestHeaders.Accept.Clear();
            _Client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

            _Timer = new Timer(async delegate 
                { 
                    PostTelemetry(); 
                }, null, int.Parse(_Config["Timer:DelayMilliseconds"]), int.Parse(_Config["Timer:PeriodMilliseconds"]));

            _ResetEvent.WaitOne();
        }

        private static async Task PostTelemetry()
        {   
            var reading = new DeviceReading
            {
                DeviceId = _DeviceId,
                Timestamp = DateTime.UtcNow,
                Reading = _Random.Next()
            };

            var json = JsonConvert.SerializeObject(reading);
            var buffer = Encoding.UTF8.GetBytes(json);
            var content = new ByteArrayContent(buffer);
            content.Headers.ContentType = new MediaTypeHeaderValue("application/json");
         
            Console.WriteLine($"Device ID: {_DeviceId}, posting reading: {reading.Reading}...");
            await _Client.PostAsync(_Config["TelemetryService:Url"], content);
            Console.WriteLine($"Device ID: {_DeviceId}, posted reading: {reading.Reading}, at: {DateTime.Now:HH:mm:ss.fff}");
        }
    }
}
