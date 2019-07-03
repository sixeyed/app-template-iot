FROM mcr.microsoft.com/dotnet/core/sdk:3.0.100-preview6 AS builder

WORKDIR /src
COPY src/Device.csproj .
RUN dotnet restore

COPY src /src
RUN dotnet publish -c Release -o /app Device.csproj

# app
FROM mcr.microsoft.com/dotnet/core/runtime:3.0.0-preview6

EXPOSE 80
ENTRYPOINT ["dotnet", "/app/Device.dll"]

COPY --from=builder /app /app