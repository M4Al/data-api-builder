# Stage image versions mirror https://hub.docker.com/_/microsoft-dotnet-aspnet

FROM mcr.microsoft.com/dotnet/sdk:8.0-cbl-mariner2.0 AS build

WORKDIR /src

# Copy project files first to maximize layer caching during restore
COPY ["Nuget.config", "."]
COPY ["global.json", "."]
COPY ["src/Directory.Build.props", "src/"]
COPY ["src/Directory.Packages.props", "src/"]
COPY ["src/Azure.DataApiBuilder.sln", "src/"]
COPY ["src/Service/Azure.DataApiBuilder.Service.csproj", "src/Service/"]
COPY ["src/Azure.DataApiBuilder.Mcp/Azure.DataApiBuilder.Mcp.csproj", "src/Azure.DataApiBuilder.Mcp/"]
COPY ["src/Core/Azure.DataApiBuilder.Core.csproj", "src/Core/"]
COPY ["src/Auth/Azure.DataApiBuilder.Auth.csproj", "src/Auth/"]
COPY ["src/Config/Azure.DataApiBuilder.Config.csproj", "src/Config/"]
COPY ["src/Product/Azure.DataApiBuilder.Product.csproj", "src/Product/"]
COPY ["src/Service.GraphQLBuilder/Azure.DataApiBuilder.Service.GraphQLBuilder.csproj", "src/Service.GraphQLBuilder/"]
RUN dotnet restore "src/Service/Azure.DataApiBuilder.Service.csproj" -r linux-x64

# Copy the remaining source and publish the service
COPY . .
RUN dotnet publish "src/Service/Azure.DataApiBuilder.Service.csproj" -c Release -f net8.0 -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0-cbl-mariner2.0 AS runtime

WORKDIR /app
COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:5000
EXPOSE 5000

ENTRYPOINT ["dotnet", "Azure.DataApiBuilder.Service.dll"]
