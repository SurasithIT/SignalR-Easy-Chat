FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["SignalR.Easy.Chat.WebAPI/SignalR.Easy.Chat.WebAPI.csproj", "SignalR.Easy.Chat.WebAPI/"]
RUN dotnet restore "SignalR.Easy.Chat.WebAPI/SignalR.Easy.Chat.WebAPI.csproj"
COPY . .
WORKDIR "/src/SignalR.Easy.Chat.WebAPI"
RUN dotnet build "SignalR.Easy.Chat.WebAPI.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "SignalR.Easy.Chat.WebAPI.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "SignalR.Easy.Chat.WebAPI.dll"]
