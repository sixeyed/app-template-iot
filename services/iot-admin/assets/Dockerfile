FROM mcr.microsoft.com/dotnet/core/sdk:3.0.100-preview6 AS builder

WORKDIR /src
COPY src/IotKitAdmin.csproj .
RUN dotnet restore

COPY src /src
RUN dotnet publish -c Release -o /app IotKitAdmin.csproj

# app
FROM mcr.microsoft.com/dotnet/core/aspnet:3.0.0-preview6

# this image is multi-arch linux only;
COPY --from=docker:18.09 /usr/local/bin/docker /usr/bin

EXPOSE 80
ENTRYPOINT ["dotnet", "/app/IotKitAdmin.dll"]

COPY ./secrets /run/secrets

COPY --from=builder /app /app