import { Injectable } from '@angular/core';
import { Observable, Subject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class UserService {

  private userName: Subject<string> = new Subject<string>();
  public userName$: Observable<string> = this.userName.asObservable();

  constructor() { }

  setUserName(userName: string) {
    this.userName.next(userName)
  }

}
