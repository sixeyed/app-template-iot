using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;

namespace TelemetryService.Controllers
{
    [Route("stats")]
    [ApiController]
    public class StatisticsController : ControllerBase
    {
        private IMemoryCache _cache;

        public StatisticsController(IMemoryCache memoryCache)
        {
            _cache = memoryCache;
        }

        [HttpGet]
        public async Task<ActionResult<Statistics>> Get()
        {
            return await GetStatisticsAsync();
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
