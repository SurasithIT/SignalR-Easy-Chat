import { Component, OnDestroy, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { catchError, Subscription } from 'rxjs';
import { environment } from 'src/environments/environment';
import { MessageOfEnum, SignalRService } from './services/signalr.service';
import { UserService } from './services/user.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit, OnDestroy {
  subscriptions: Subscription[] = []
  messageOfEnum = MessageOfEnum;
  userNameForm: FormGroup;
  sendMessageForm: FormGroup;
  userName: string = '';

  constructor(
    public signalRService: SignalRService,
    private userService: UserService,
    private formBuilder: FormBuilder,
    private http: HttpClient
  ) {
    this.userNameForm = this.formBuilder.group({
      userName: ['', Validators.required]
    });

    this.sendMessageForm = this.formBuilder.group({
      receiverUserName: ['', Validators.required],
      message: ['', Validators.required]
    });

    const userNameSubscription = this.userService.userName$.subscribe(async userName => {

      await this.signalRService.disconnect();
      this.signalRService.connect(userName)
        .then(resp => {
          this.signalRService.addMessageListener();
        })
      this.userName = userName
    })
    this.subscriptions.push(userNameSubscription);

    const messageSubscription = this.signalRService.messages$.subscribe(messages => {
      console.log(messages)
    })
    this.subscriptions.push(messageSubscription);
  }

  ngOnInit(): void {

  }

  connect() {
    if (this.userNameForm.invalid) {
      window.alert("You have to set your Username before start Chat!")
      return;
    }
    const userName = this.userNameForm.get("userName")?.value;
    this.userService.setUserName(userName);
  }

  async sendMessage() {
    if (this.userNameForm.invalid) {
      window.alert("You have to set your Username before start Chat!")
      return;
    }
    if (this.sendMessageForm.controls["receiverUserName"].invalid) {
      window.alert("You have to set your Reciever Username before start Chat!")
      return;
    }
    if (this.sendMessageForm.controls["message"].invalid) {
      window.alert("You have to input message!")
      return
    }
    const receiverUserName = this.sendMessageForm.get("receiverUserName")?.value;
    const message = this.sendMessageForm.get("message")?.value;

    await this.signalRService.sendMessage(receiverUserName, message, this.userName)
    this.sendMessageForm.get("message")?.setValue(null);
  }

  async sendMessageByAPI() {
    if (this.userNameForm.invalid) {
      window.alert("You have to set your Username before start Chat!")
      return;
    }
    if (this.sendMessageForm.controls["receiverUserName"].invalid) {
      window.alert("You have to set your Reciever Username before start Chat!")
      return;
    }
    if (this.sendMessageForm.controls["message"].invalid) {
      window.alert("You have to input message!")
      return
    }

    const receiverUserName = this.sendMessageForm.get("receiverUserName")?.value;
    const message = this.sendMessageForm.get("message")?.value;

    const param = {
      receiverUserName: receiverUserName,
      message: message,
      senderUserName: this.userName
    }

    this.http.post<any>(environment.apiHost + "/SendMessage", param)
      .subscribe(data => {
        console.log(data)
        this.sendMessageForm.get("message")?.setValue(null);
      });
  }

  ngOnDestroy(): void {
    this.subscriptions.map(subscription => subscription.unsubscribe())
  }

}
