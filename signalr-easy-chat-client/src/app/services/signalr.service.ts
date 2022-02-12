import { Injectable } from '@angular/core';
import { environment } from 'src/environments/environment';
import * as signalR from '@microsoft/signalr';
import { BehaviorSubject, catchError, Observable, Subject } from 'rxjs';
import { HttpClient } from '@angular/common/http';

interface Message {
  messageOf: MessageOfEnum,
  messageText: string,
  senderUserName: string
}

export enum MessageOfEnum {
  Sender,
  Receiver
}

@Injectable({
  providedIn: 'root'
})
export class SignalRService {
  public connection: signalR.HubConnection | undefined;
  private messages: BehaviorSubject<Message[]> = new BehaviorSubject<Message[]>([]);
  public messages$: Observable<Message[]> = this.messages.asObservable();

  constructor(
    private http: HttpClient
  ) { }

  async connect(userName: string) {
    if (!userName) {
      return;
    }

    this.connection = new signalR.HubConnectionBuilder()
      .configureLogging(signalR.LogLevel.Information)
      .withUrl(environment.signalRHost + `?userName=${userName}`)
      .withAutomaticReconnect()
      .build();

    this.connection.start()
      .then(function () {
        console.log('SignalR Connected!');
        window.alert("Connect success!")
      }).catch(function (err: any) {
        console.error(err.toString());
        window.alert("Connect Error!")
      });
  }

  async disconnect() {
    await this.connection?.stop();
  }


  async sendMessage(receiverUserName: string, message: string, senderUserName: string) {
    await this.connection?.invoke("SendMessage", receiverUserName, message, senderUserName).catch(ex => console.error(ex));
    const _message: Message = {
      messageOf: MessageOfEnum.Sender,
      messageText: message,
      senderUserName: senderUserName
    }
    this.messages.next([...this.messages.value, _message])
  }

  async sendMessageByCallAPI(receiverUserName: string, message: string, senderUserName: string) {
    const param = {
      receiverUserName: receiverUserName,
      message: message,
      senderUserName: senderUserName
    }
    this.http.post<any>(environment.apiHost + "/SendMessage", param)
      .pipe(catchError(async (ex) => console.error(ex)))
      .subscribe(data => {
        const _message: Message = {
          messageOf: MessageOfEnum.Sender,
          messageText: message,
          senderUserName: senderUserName
        }
        this.messages.next([...this.messages.value, _message])
      });
  }

  addMessageListener() {
    this.connection?.on("ReceiveMessage", (senderUserName: string, message: string) => {
      console.log(message)
      const _message: Message = {
        messageOf: MessageOfEnum.Receiver,
        messageText: message,
        senderUserName: senderUserName
      }
      this.messages.next([...this.messages.value, _message]
      )
    });
  }
}
