using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;

namespace TelemetryService.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class ReadingsController : ControllerBase
    {
        private IMemoryCache _cache;

        public ReadingsController(IMemoryCache memoryCache)
        {
            _cache = memoryCache;
        }

        [HttpPost]
        public async Task<ActionResult> Post([FromBody] DeviceReading reading)
        {
            var readings = await GetReadingsAsync();
            readings.Add(reading);

            var statistics = await GetStatisticsAsync();
            statistics.DeviceCount = readings.Select(r => r.DeviceId).Distinct().Count();
            statistics.ReadingCount = readings.Count();
            statistics.AverageReading = readings.Average(r => r.Reading);
            statistics.MaximumReading = readings.Max(r => r.Reading);
            statistics.MinimumReading = readings.Min(r => r.Reading);

            return Ok();
        }

        private async Task<List<DeviceReading>> GetReadingsAsync()
        {
            return await _cache.GetOrCreateAsync<List<DeviceReading>>(DeviceReading.CacheKey, entry =>
            {
                entry.SlidingExpiration = TimeSpan.FromHours(6);
                return Task.FromResult(new List<DeviceReading>());
            });
        }

        private async Task<Statistics> GetStatisticsAsync()
        {
            return await _cache.GetOrCreateAsync<Statistics>(Statistics.CacheKey, entry =>
            {
                entry.SlidingExpiration = TimeSpan.FromHours(12);
                return Task.FromResult(new Statistics());
            });
        }
    }
}
