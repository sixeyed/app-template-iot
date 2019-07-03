public class Statistics
{
    public int DeviceCount {get; set;}

    public int ReadingCount {get; set; }

    public double? AverageReading {get; set;}

    public int? MaximumReading {get; set;}

    public int? MinimumReading {get; set;}

    public const string CacheKey = "_Statistics";
}