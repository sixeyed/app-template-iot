using System;

namespace Device
{  
    public class DeviceReading
    {
        public string DeviceId {get; set;}

        public DateTime Timestamp {get; set;}

        public int Reading {get; set;}
    }
}