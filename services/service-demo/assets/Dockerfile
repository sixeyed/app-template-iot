FROM mcr.microsoft.com/dotnet/core/sdk:3.0.100-preview4 AS builder

WORKDIR /src
COPY src/TelemetryService.csproj .
RUN dotnet restore

COPY src /src
RUN dotnet publish -c Release -o /app TelemetryService.csproj

# app
FROM mcr.microsoft.com/dotnet/core/aspnet:3.0.0-preview4

EXPOSE 80
ENTRYPOINT ["dotnet", "/app/TelemetryService.dll"]

COPY --from=builder /app /app