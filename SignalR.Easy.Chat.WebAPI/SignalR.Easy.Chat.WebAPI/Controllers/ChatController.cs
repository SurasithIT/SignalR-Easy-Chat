using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using SignalR.Easy.Chat.WebAPI.Models.Chats;
using SignalR.Easy.Chat.WebAPI.SignalRHub;

namespace SignalR.Easy.Chat.WebAPI.Controllers;

public class ChatController : Controller
{
    private readonly IHubContext<ChatHub> _hubContext;
    public ChatController(IHubContext<ChatHub> hubContext)
    {
        _hubContext = hubContext;
    }
    // GET
    [HttpPost("SendMessage")]
    public async Task<IActionResult> SendMessage([FromBody]ChatReq req)
    {
        var _hubDict = ChatHub._HubDict;
        req.ReceiverUserName = (req.ReceiverUserName ?? "").ToLower();
        if (_hubDict.TryGetValue(req.ReceiverUserName, out HubCallerContext _receiverContext))
        {
            await _hubContext.Clients.Client(_receiverContext.ConnectionId).SendAsync("ReceiveMessage", req.SenderUserName, req.Message);
        }
        return Ok();
    }
}