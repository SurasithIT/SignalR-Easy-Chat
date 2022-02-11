using Microsoft.AspNetCore.SignalR;

namespace SignalR.Easy.Chat.WebAPI.SignalRHub;

// Mapping online user
using HubCallerContextDict = System.Collections.Concurrent.ConcurrentDictionary<string, HubCallerContext>;

public class ChatHub : Hub
{
    // Mapping online user
    static HubCallerContextDict _HubDict = new HubCallerContextDict();
    
    public override Task OnConnectedAsync()
    {
        string userName = Context.GetHttpContext().Request.Query["userName"];
        string connectionId = this.Context.ConnectionId;
        userName = (userName ?? "").ToLower();            
        _HubDict.TryAdd(userName, this.Context);
        
        return base.OnConnectedAsync();
    }

    public override Task OnDisconnectedAsync(Exception? exception)
    {
        string userName = Context.GetHttpContext().Request.Query["userName"];
        string connectionId = this.Context.ConnectionId;
        userName = (userName ?? "").ToLower();

        _HubDict.TryRemove(userName, out HubCallerContext _context);
        
        return base.OnDisconnectedAsync(exception);
    }
    
    public async Task SendMessage(string receiverUserName, string message, string senderUserName)
    {
        try
        {
            receiverUserName = (receiverUserName ?? "").ToLower();
            if (_HubDict.TryGetValue(receiverUserName, out HubCallerContext _receiverContext))
            {
                await Clients.Client(_receiverContext.ConnectionId).SendAsync("ReceiveMessage", senderUserName, message);
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message);
        }
    }
}