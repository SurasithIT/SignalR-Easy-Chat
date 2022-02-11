using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace SignalR.Easy.Chat.WebAPI.Models.Chats;

public class ChatReq
{
    [Required]
    [JsonPropertyName("receiverUserName")]
    public string ReceiverUserName { get; set; }
    [Required]
    [JsonPropertyName("message")]
    public string Message { get; set; }
    [Required]
    [JsonPropertyName("senderUserName")]
    public string SenderUserName { get; set; }
}